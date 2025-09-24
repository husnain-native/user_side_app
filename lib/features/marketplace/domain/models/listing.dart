enum ListingStatus { active, sold, draft }

enum ListingCondition { newItem, likeNew, used }

enum ListingCategory { furniture, electronics, vehicles, services, clothing, books, sports, other }

class Listing {
  final String id;
  final String title;
  final String description;
  final double price;
  final bool negotiable;
  final ListingCategory category;
  final ListingCondition condition;
  final List<String> imageUrls;
  final String sellerName;
  final String sellerId;
  final String location;
  final DateTime createdAt;
  final ListingStatus status;
  final int favoritesCount;
  final int viewsCount;

  const Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.negotiable,
    required this.category,
    required this.condition,
    required this.imageUrls,
    required this.sellerName,
    required this.sellerId,
    required this.location,
    required this.createdAt,
    required this.status,
    this.favoritesCount = 0,
    this.viewsCount = 0,
  });

  Listing copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    bool? negotiable,
    ListingCategory? category,
    ListingCondition? condition,
    List<String>? imageUrls,
    String? sellerName,
    String? sellerId,
    String? location,
    DateTime? createdAt,
    ListingStatus? status,
    int? favoritesCount,
    int? viewsCount,
  }) {
    return Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      negotiable: negotiable ?? this.negotiable,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      imageUrls: imageUrls ?? this.imageUrls,
      sellerName: sellerName ?? this.sellerName,
      sellerId: sellerId ?? this.sellerId,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      viewsCount: viewsCount ?? this.viewsCount,
    );
  }

  String get formattedPrice {
    final String p = price.toStringAsFixed(
      price.truncateToDouble() == price ? 0 : 2,
    );
    return 'Rs $p${negotiable ? ' (nego)' : ''}';
  }

  String get timeAgo {
    final Duration d = DateTime.now().difference(createdAt);
    if (d.inDays > 0) return '${d.inDays}d ago';
    if (d.inHours > 0) return '${d.inHours}h ago';
    if (d.inMinutes > 0) return '${d.inMinutes}m ago';
    return 'Just now';
  }
}

extension ListingCategoryX on ListingCategory {
  String get label {
    switch (this) {
      case ListingCategory.furniture:
        return 'Furniture';
      case ListingCategory.electronics:
        return 'Electronics';
      case ListingCategory.vehicles:
        return 'Vehicles';
        case ListingCategory.services:
          return 'Services';
      case ListingCategory.clothing:
        return 'Clothing';
      case ListingCategory.books:
        return 'Books';
      case ListingCategory.sports:
        return 'Sports';
      case ListingCategory.other:
        return 'Other';
    }
  }
}

extension ListingConditionX on ListingCondition {
  String get label {
    switch (this) {
      case ListingCondition.newItem:
        return 'New';
      case ListingCondition.likeNew:
        return 'Like New';
      case ListingCondition.used:
        return 'Used';
    }
  }
}