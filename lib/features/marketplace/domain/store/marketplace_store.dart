import 'package:flutter/foundation.dart';
import 'package:park_chatapp/features/marketplace/domain/models/listing.dart';

class MarketplaceStore {
  MarketplaceStore._internal();
  static final MarketplaceStore instance = MarketplaceStore._internal();

  final ValueNotifier<List<Listing>> listingsNotifier =
      ValueNotifier<List<Listing>>(<Listing>[]);
  final ValueNotifier<Set<String>> favoriteIdsNotifier =
      ValueNotifier<Set<String>>(<String>{});

  List<Listing> get allListings => listingsNotifier.value;
  Set<String> get favoriteIds => favoriteIdsNotifier.value;

  void setAllListings(List<Listing> listings) {
    listingsNotifier.value = List<Listing>.from(listings);
  }

  void addListing(Listing listing) {
    final List<Listing> updated = List<Listing>.from(listingsNotifier.value);
    updated.insert(0, listing);
    listingsNotifier.value = updated;
  }

  bool isFavorited(String listingId) {
    return favoriteIdsNotifier.value.contains(listingId);
  }

  void toggleFavorite(String listingId) {
    final Set<String> updated = Set<String>.from(favoriteIdsNotifier.value);
    if (updated.contains(listingId)) {
      updated.remove(listingId);
    } else {
      updated.add(listingId);
    }
    favoriteIdsNotifier.value = updated;
  }

  List<Listing> get favoriteListings {
    final Set<String> favs = favoriteIdsNotifier.value;
    return listingsNotifier.value.where((l) => favs.contains(l.id)).toList();
  }
}