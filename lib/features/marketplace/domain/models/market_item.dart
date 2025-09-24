// No Flutter imports needed here; keep model pure.

/// A unified item that can represent properties, vehicles, electronics, etc.
/// Stored in Realtime Database under `market_items/{id}`.
///
/// Schema (RTDB JSON example):
/// {
///   "id": "auto-generated-or-timestamp",
///   "type": "property|vehicle|general",
///   "category": "properties|electronics|vehicles|home_furniture|...",
///   "subCategory": "phones|laptops|apartment|plot|sedan|...", // optional
///   "title": "iPhone 12",
///   "description": "...",
///   "price": 185000,
///   "currency": "PKR",
///   "negotiable": true,
///   "condition": "new|like_new|used",
///   "location": "Block C",
///   "imageUrls": ["https://...", "assets/images/..."] ,
///   "sellerId": "uid",
///   "sellerName": "Hina",
///   "createdAt": 1716660000000, // ms since epoch or ISO string
///   "status": "active|sold|draft",
///   "attributes": {
///     // category-specific attributes (flexible):
///     "bedrooms": 3, "bathrooms": 2, "area": 1650,
///     "brand": "Apple", "model": "iPhone 12", "storage": "128GB",
///     "year": 2018, "km": 58000,
///   }
/// }

enum MarketItemStatus { active, sold, draft }

class MarketItem {
  final String id;
  final String type; // property | vehicle | general
  final String category; // top-level category
  final String? subCategory;
  final String title;
  final String description;
  final double price;
  final String currency;
  final bool negotiable;
  final String? condition; // new | like_new | used
  final String location;
  final List<String> imageUrls;
  final String sellerId;
  final String sellerName;
  final DateTime createdAt;
  final MarketItemStatus status;
  final Map<String, dynamic> attributes; // flexible per category

  const MarketItem({
    required this.id,
    required this.type,
    required this.category,
    this.subCategory,
    required this.title,
    required this.description,
    required this.price,
    this.currency = 'PKR',
    this.negotiable = false,
    this.condition,
    required this.location,
    required this.imageUrls,
    required this.sellerId,
    required this.sellerName,
    required this.createdAt,
    this.status = MarketItemStatus.active,
    this.attributes = const {},
  });

  factory MarketItem.fromMap(String id, Map<String, dynamic> map) {
    return MarketItem(
      id: id,
      type: (map['type'] ?? 'general').toString(),
      category: (map['category'] ?? 'other').toString(),
      subCategory: (map['subCategory'] as String?)?.toString(),
      title: (map['title'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      price: _toDouble(map['price']),
      currency: (map['currency'] ?? 'PKR').toString(),
      negotiable: map['negotiable'] == true,
      condition: (map['condition'] as String?)?.toString(),
      location: (map['location'] ?? '').toString(),
      imageUrls: List<String>.from(map['imageUrls'] ?? const <String>[]),
      sellerId: (map['sellerId'] ?? '').toString(),
      sellerName: (map['sellerName'] ?? 'Seller').toString(),
      createdAt: _parseDateTime(map['createdAt']),
      status: _parseStatus(map['status']),
      attributes: Map<String, dynamic>.from(
        map['attributes'] ?? const <String, dynamic>{},
      ),
    );
  }

  static MarketItemStatus _parseStatus(dynamic value) {
    final String v = (value ?? 'active').toString().toLowerCase();
    switch (v) {
      case 'sold':
        return MarketItemStatus.sold;
      case 'draft':
        return MarketItemStatus.draft;
      default:
        return MarketItemStatus.active;
    }
  }

  static DateTime _parseDateTime(dynamic value) {
    try {
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      if (value is String && value.isNotEmpty) return DateTime.parse(value);
    } catch (_) {}
    return DateTime.now();
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  String get formattedPrice {
    final double p = price;
    String short;
    if (p >= 1000000) {
      short = '${(p / 1000000).toStringAsFixed(1)}M';
    } else if (p >= 1000) {
      short = '${(p / 1000).toStringAsFixed(0)}K';
    } else {
      short = p.toStringAsFixed(p.truncateToDouble() == p ? 0 : 2);
    }
    return '$currency $short${negotiable ? ' (nego)' : ''}';
  }

  String get timeAgo {
    final Duration d = DateTime.now().difference(createdAt);
    if (d.inDays > 0) return '${d.inDays}d ago';
    if (d.inHours > 0) return '${d.inHours}h ago';
    if (d.inMinutes > 0) return '${d.inMinutes}m ago';
    return 'Just now';
  }
}
