import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AppChatService {
  static FirebaseAuth get _auth => FirebaseAuth.instance;
  static FirebaseDatabase get _db => FirebaseDatabase.instance;

  static String? get currentUid => _auth.currentUser?.uid;

  static DatabaseReference get _threadsCol => _db.ref('threads');
  static DatabaseReference get _adminsCol => _db.ref('admins');

  // Pick an admin UID (first document in admins collection)
  static Future<String> _getAnyAdminUid() async {
    final DataSnapshot snap = await _adminsCol.limitToFirst(1).get();
    if (!snap.exists || snap.value == null) {
      throw Exception('No admin available');
    }
    // admins is stored as admins/<uid>: {...}
    if (snap.value is Map) {
      final Map<dynamic, dynamic> map = snap.value as Map<dynamic, dynamic>;
      final String firstKey = map.keys.first.toString();
      return firstKey;
    }
    throw Exception('Invalid admins data');
  }

  // Ensure a DM thread exists between current user and an admin
  static Future<String> createOrGetDmThreadWithAdmin() async {
    final String? userId = currentUid;
    if (userId == null) throw Exception('Not signed in');
    final String adminId = await _getAnyAdminUid();

    // RTDB cannot query array-contains easily; fetch and filter client-side
    final DataSnapshot allSnap = await _threadsCol.get();
    if (allSnap.exists && allSnap.value is Map) {
      final Map<dynamic, dynamic> all = allSnap.value as Map<dynamic, dynamic>;
      for (final entry in all.entries) {
        final String threadId = entry.key.toString();
        final Map<dynamic, dynamic> t = Map<dynamic, dynamic>.from(entry.value);
        final bool isGroup = (t['isGroup'] as bool?) ?? false;
        if (isGroup) continue;
        final participantsRaw = t['participants'];
        List<String> participants = [];
        if (participantsRaw is List) {
          participants = participantsRaw.map((e) => e.toString()).toList();
        } else if (participantsRaw is Map) {
          participants = (participantsRaw as Map)
              .keys
              .map((e) => e.toString())
              .toList();
        }
        if (participants.contains(userId) && participants.contains(adminId)) {
          // Ensure legacy threads are labelled as admin threads with a display name
          final bool hasFlag = (t['isAdminThread'] as bool?) == true;
          final String? adminName = t['adminName'] as String?;
          if (!hasFlag || (adminName == null || adminName.isEmpty)) {
            try {
              await _threadsCol.child(threadId).update({
                'isAdminThread': true,
                'adminName': 'Park View City',
              });
            } catch (_) {}
          }
          return threadId;
        }
      }
    }

    final DatabaseReference newRef = _threadsCol.push();
    final String defaultMessage = "Do you have any query? We are here to help you";
    
    // Create the thread
    await newRef.set({
      'isGroup': false,
      'isAdminThread': true,
      'adminName': 'Park View City',
      'participants': <String>[userId, adminId],
      'createdAt': ServerValue.timestamp,
      'lastMessage': defaultMessage,
      'lastMessageAt': ServerValue.timestamp,
      'unreadCounts': {userId: 1, adminId: 0}, // User has 1 unread (the default message)
    });
    
    // Add the default message
    final DatabaseReference msgRef = newRef.child('messages').push();
    await msgRef.set({
      'text': defaultMessage,
      'senderId': adminId,
      'createdAt': ServerValue.timestamp,
    });
    
    return newRef.key!;
  }

  static Stream<List<Map<String, dynamic>>> streamThreadMessages(
    String threadId,
  ) {
    final DatabaseReference ref = _threadsCol.child('$threadId/messages');
    return ref.onValue.map((DatabaseEvent event) {
      if (!event.snapshot.exists || event.snapshot.value == null) return <Map<String, dynamic>>[];
      final Map<dynamic, dynamic> raw = event.snapshot.value as Map<dynamic, dynamic>;
      final List<Map<String, dynamic>> messages = raw.entries.map((e) {
        final Map<String, dynamic> m = Map<String, dynamic>.from(e.value as Map);
        m['messageId'] = e.key.toString();
        return m;
      }).toList();
      messages.sort((a, b) {
        final int at = (a['createdAt'] ?? 0) is int ? a['createdAt'] as int : 0;
        final int bt = (b['createdAt'] ?? 0) is int ? b['createdAt'] as int : 0;
        return at.compareTo(bt);
      });
      return messages;
    });
  }

  static Future<void> sendMessageToThread(String threadId, String text) async {
    final String? senderId = currentUid;
    if (senderId == null) throw Exception('Not signed in');

    final DatabaseReference threadRef = _threadsCol.child(threadId);
    final DataSnapshot threadSnap = await threadRef.get();
    if (!threadSnap.exists || threadSnap.value == null) {
      throw Exception('Thread not found');
    }
    final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(threadSnap.value as Map);
    List<String> participants = [];
    final pr = data['participants'];
    if (pr is List) {
      participants = pr.map((e) => e.toString()).toList();
    } else if (pr is Map) {
      participants = (pr as Map).keys.map((e) => e.toString()).toList();
    }

    final DatabaseReference msgRef = threadRef.child('messages').push();
    await msgRef.set({
      'text': text,
      'senderId': senderId,
      'createdAt': ServerValue.timestamp,
    });

    final Map<dynamic, dynamic> unreadRaw = Map<dynamic, dynamic>.from(
      data['unreadCounts'] ?? {},
    );
    for (final pid in participants) {
      if (pid == senderId) continue;
      final int current = int.tryParse('${unreadRaw[pid] ?? 0}') ?? 0;
      unreadRaw[pid] = current + 1;
    }

    await threadRef.update({
      'lastMessage': text,
      'lastMessageAt': ServerValue.timestamp,
      'unreadCounts': unreadRaw,
    });
  }

  // Create or get a DM thread with a seller
  static Future<String> createOrGetDmThreadWithSeller(String sellerId, String sellerName) async {
    final String? userId = currentUid;
    if (userId == null) throw Exception('Not signed in');

    // Check if thread already exists
    final DataSnapshot allSnap = await _threadsCol.get();
    if (allSnap.exists && allSnap.value is Map) {
      final Map<dynamic, dynamic> all = allSnap.value as Map<dynamic, dynamic>;
      for (final entry in all.entries) {
        final String threadId = entry.key.toString();
        final Map<dynamic, dynamic> t = Map<dynamic, dynamic>.from(entry.value);
        final bool isGroup = (t['isGroup'] as bool?) ?? false;
        if (isGroup) continue;
        final participantsRaw = t['participants'];
        List<String> participants = [];
        if (participantsRaw is List) {
          participants = participantsRaw.map((e) => e.toString()).toList();
        } else if (participantsRaw is Map) {
          participants = (participantsRaw as Map)
              .keys
              .map((e) => e.toString())
              .toList();
        }
        if (participants.contains(userId) && participants.contains(sellerId)) {
          // Ensure sellerName is saved on legacy threads
          final String? existingSellerName = (t['sellerName'] as String?);
          if (existingSellerName == null || existingSellerName.isEmpty) {
            try {
              await _threadsCol.child(threadId).update({'sellerName': sellerName});
            } catch (_) {}
          }
          return threadId;
        }
      }
    }

    // Create new thread with seller
    final DatabaseReference newRef = _threadsCol.push();
    await newRef.set({
      'isGroup': false,
      'participants': <String>[userId, sellerId],
      'createdAt': ServerValue.timestamp,
      'lastMessage': null,
      'lastMessageAt': ServerValue.timestamp,
      'unreadCounts': {userId: 0, sellerId: 0},
      'sellerName': sellerName, // Store seller name for easy access
    });
    return newRef.key!;
  }

  // Mark messages as read for current user in a thread
  static Future<void> markThreadAsRead(String threadId) async {
    final String? userId = currentUid;
    if (userId == null) return;

    final DatabaseReference threadRef = _threadsCol.child(threadId);
    final DataSnapshot threadSnap = await threadRef.get();
    if (!threadSnap.exists || threadSnap.value == null) return;

    final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(threadSnap.value as Map);
    final Map<dynamic, dynamic> unreadRaw = Map<dynamic, dynamic>.from(
      data['unreadCounts'] ?? {},
    );
    unreadRaw[userId] = 0;

    await threadRef.update({
      'unreadCounts': unreadRaw,
    });
  }
}
