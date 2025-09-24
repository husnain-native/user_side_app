import 'package:firebase_database/firebase_database.dart';
import 'package:park_chatapp/features/marketplace/domain/models/market_item.dart';

class MarketItemService {
  static DatabaseReference get _root =>
      FirebaseDatabase.instance.ref('market_items');

  static Stream<List<MarketItem>> streamAllItems() {
    return _root.onValue.map((DatabaseEvent event) {
      final Object? raw = event.snapshot.value;
      if (raw == null) return <MarketItem>[];
      final Map<dynamic, dynamic> map = raw as Map<dynamic, dynamic>;
      final List<MarketItem> items = [];
      map.forEach((key, value) {
        try {
          items.add(
            MarketItem.fromMap(
              key.toString(),
              Map<String, dynamic>.from(value as Map),
            ),
          );
        } catch (_) {}
      });
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    });
  }

  static Future<void> addItem(MarketItem item) async {
    final DatabaseReference ref = _root.child(item.id);
    await ref.set({
      'type': item.type,
      'category': item.category,
      'subCategory': item.subCategory,
      'title': item.title,
      'description': item.description,
      'price': item.price,
      'currency': item.currency,
      'negotiable': item.negotiable,
      'condition': item.condition,
      'location': item.location,
      'imageUrls': item.imageUrls,
      'sellerId': item.sellerId,
      'sellerName': item.sellerName,
      'createdAt': item.createdAt.millisecondsSinceEpoch,
      'status': item.status.name,
      'attributes': item.attributes,
    });
  }
}
