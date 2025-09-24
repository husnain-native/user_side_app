import 'package:flutter/material.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/features/marketplace/domain/store/marketplace_store.dart';
import 'package:park_chatapp/features/marketplace/presentation/widgets/listing_card.dart';
import 'package:park_chatapp/features/marketplace/presentation/screens/listing_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:park_chatapp/core/widgets/sign_in_prompt.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: AppColors.primaryRed,
      ),
      body: SafeArea(
        child:
            user == null
                ? const SignInRequired(
                  message: 'Sign in to view your favorites',
                )
                : _FavoritesBody(),
      ),
    );
  }
}

class _FavoritesBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder(
        valueListenable: MarketplaceStore.instance.favoriteIdsNotifier,
        builder: (_, __, ___) {
          final items = MarketplaceStore.instance.favoriteListings;
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      size: 56,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No favorites yet',
                      style: AppTextStyles.bodyMediumBold,
                    ),
                    const SizedBox(height: 4),
                    const Text('Tap the heart on a listing to save it'),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder:
                (_, i) => ListingCard(
                  listing: items[i],
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ListingDetailScreen(listing: items[i]),
                      ),
                    );
                  },
                  onFavorite: () async {
                    if (!await ensureSignedIn(context)) return;
                    MarketplaceStore.instance.toggleFavorite(items[i].id);
                  },
                ),
          );
        },
      ),
    );
  }
}
