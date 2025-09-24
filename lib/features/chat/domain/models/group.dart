class Group {
  final String id;
  String name;
  final List<String> members;
  final bool isAuthor;
  final List<GroupMessage> messages;

  Group({
    required this.id,
    required this.name,
    required this.members,
    required this.isAuthor,
    List<GroupMessage>? messages,
  }) : messages = messages ?? <GroupMessage>[];

  Group copyWith({
    String? name,
    List<String>? members,
    List<GroupMessage>? messages,
  }) {
    return Group(
      id: id,
      name: name ?? this.name,
      members: members ?? List<String>.from(this.members),
      isAuthor: isAuthor,
      messages: messages ?? List<GroupMessage>.from(this.messages),
    );
  }
}

class GroupMessage {
  final String text;
  final String sender;
  final DateTime timestamp;

  const GroupMessage({
    required this.text,
    required this.sender,
    required this.timestamp,
  });
}
