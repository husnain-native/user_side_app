import 'package:flutter/material.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/features/marketplace/domain/models/listing.dart';
import 'package:park_chatapp/features/marketplace/presentation/widgets/listing_card.dart';
import 'package:park_chatapp/features/marketplace/presentation/screens/new_listing_screen.dart';
import 'package:park_chatapp/features/marketplace/presentation/screens/listing_detail_screen.dart';
import 'package:park_chatapp/features/marketplace/domain/store/marketplace_store.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Listing> _listings = <Listing>[
    Listing(
      id: '1',
      title: '2-seater Sofa',
      description: 'Comfortable sofa in good condition.',
      price: 18000,
      negotiable: true,
      category: ListingCategory.furniture,
      condition: ListingCondition.used,
      imageUrls: const ['assets/images/sofa.jpg'],
      sellerName: 'Ahmed',
      sellerId: 'u1',
      location: 'Block C',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      status: ListingStatus.active,
    ),
    Listing(
      id: '2',
      title: 'iPhone 12 (128GB)',
      description: 'Like new, with box and charger.',
      price: 185000,
      negotiable: false,
      category: ListingCategory.electronics,
      condition: ListingCondition.likeNew,
      imageUrls: const ['assets/images/iphone.jpg'],
      sellerName: 'Hina',
      sellerId: 'u2',
      location: 'Main Boulevard',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      status: ListingStatus.active,
    ),
    Listing(
      id: '3',
      title: 'Leather Jacket',
      description: 'Genuine leather, size M, worn only twice.',
      price: 8500,
      negotiable: true,
      category: ListingCategory.clothing,
      condition: ListingCondition.likeNew,
      imageUrls: const ['assets/images/jacket.jpeg'],
      sellerName: 'Fatima',
      sellerId: 'u4',
      location: 'DHA Phase 5',
      createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
      status: ListingStatus.active,
    ),
    Listing(
      id: '4',
      title: 'Coffee Table',
      description: 'Solid wood, excellent condition.',
      price: 12500,
      negotiable: false,
      category: ListingCategory.furniture,
      condition: ListingCondition.used,
      imageUrls: const ['assets/images/table.jpg'],
      sellerName: 'Omar',
      sellerId: 'u5',
      location: 'Bahria Town',
      createdAt: DateTime.now().subtract(const Duration(days: 4, hours: 7)),
      status: ListingStatus.active,
    ),
    Listing(
      id: '5',
      title: 'Harry Potter Collection',
      description: 'Complete set of 7 books, like new.',
      price: 6000,
      negotiable: true,
      category: ListingCategory.books,
      condition: ListingCondition.likeNew,
      imageUrls: const ['assets/images/harrypotter.jpg'],
      sellerName: 'Zainab',
      sellerId: 'u6',
      location: 'Model Town',
      createdAt: DateTime.now().subtract(const Duration(days: 5, hours: 1)),
      status: ListingStatus.active,
    ),
    Listing(
      id: '6',
      title: 'Yoga Mat',
      description: 'Eco-friendly, non-slip, used only a few times.',
      price: 2500,
      negotiable: true,
      category: ListingCategory.sports,
      condition: ListingCondition.likeNew,
      imageUrls: const ['assets/images/yogamat.jpg'],
      sellerName: 'Ayesha',
      sellerId: 'u7',
      location: 'Johar Town',
      createdAt: DateTime.now().subtract(const Duration(days: 6, hours: 3)),
      status: ListingStatus.active,
    ),
    Listing(
      id: '7',
      title: 'Honda Civic 2018',
      description: 'Well maintained, low mileage, all original.',
      price: 2850000,
      negotiable: true,
      category: ListingCategory.vehicles,
      condition: ListingCondition.used,
      imageUrls: const ['assets/images/civic.avif'],
      sellerName: 'Bilal',
      sellerId: 'u8',
      location: 'Cantt',
      createdAt: DateTime.now().subtract(const Duration(days: 7, hours: 12)),
      status: ListingStatus.active,
    ),
  ];

  final List<Listing> _myListings = <Listing>[];
  String _searchText = '';
  ListingCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // seed shared store so Favorites screen can read the same list
    MarketplaceStore.instance.setAllListings(_listings);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: Text(
          'Marketplace',
          style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          labelStyle: AppTextStyles.bodyMediumBold.copyWith(fontSize: 16),
          unselectedLabelStyle: AppTextStyles.bodyMedium.copyWith(fontSize: 16),
          tabs: const [Tab(text: 'Browse'), Tab(text: 'My Listings')],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [_buildBrowseTab(context), _buildMyListingsTab(context)],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryRed,
        onPressed: () => _openCreateListing(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBrowseTab(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search listings...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: const Color.fromARGB(38, 175, 153, 131),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged:
                (v) => setState(() => _searchText = v.trim().toLowerCase()),
          ),
        ),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _categoryBlock(
                label: 'All',
                selected: _selectedCategory == null,
                onTap: () => setState(() => _selectedCategory = null),
              ),
              _categoryBlock(
                label: ListingCategory.furniture.label,
                selected: _selectedCategory == ListingCategory.furniture,
                onTap:
                    () => setState(
                      () => _selectedCategory = ListingCategory.furniture,
                    ),
              ),
              _categoryBlock(
                label: ListingCategory.electronics.label,
                selected: _selectedCategory == ListingCategory.electronics,
                onTap:
                    () => setState(
                      () => _selectedCategory = ListingCategory.electronics,
                    ),
              ),
              _categoryBlock(
                label: ListingCategory.vehicles.label,
                selected: _selectedCategory == ListingCategory.vehicles,
                onTap:
                    () => setState(
                      () => _selectedCategory = ListingCategory.vehicles,
                    ),
              ),
              _categoryBlock(
                label: ListingCategory.services.label,
                selected: _selectedCategory == ListingCategory.services,
                onTap:
                    () => setState(
                      () => _selectedCategory = ListingCategory.services,
                    ),
              ),
              _categoryBlock(
                label: ListingCategory.other.label,
                selected: _selectedCategory == ListingCategory.other,
                onTap:
                    () => setState(
                      () => _selectedCategory = ListingCategory.other,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredListings.length,
            itemBuilder: (context, index) {
              final listing = _filteredListings[index];
              return ListingCard(
                listing: listing,
                onTap: () => _openDetail(context, listing),
                onFavorite:
                    () => MarketplaceStore.instance.toggleFavorite(listing.id),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMyListingsTab(BuildContext context) {
    if (_myListings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.storefront, size: 56, color: Colors.grey),
              const SizedBox(height: 8),
              Text('No listings yet', style: AppTextStyles.bodyMediumBold),
              const SizedBox(height: 4),
              const Text('Tap + to create your first listing'),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myListings.length,
      itemBuilder: (context, index) {
        final listing = _myListings[index];
        return ListingCard(
          listing: listing,
          onTap: () => _openDetail(context, listing),
        );
      },
    );
  }

  List<Listing> get _filteredListings {
    return _listings.where((l) {
      final bool matchesText =
          _searchText.isEmpty ||
          l.title.toLowerCase().contains(_searchText) ||
          l.description.toLowerCase().contains(_searchText) ||
          l.location.toLowerCase().contains(_searchText);
      final bool matchesCategory =
          _selectedCategory == null || l.category == _selectedCategory;
      return matchesText && matchesCategory;
    }).toList();
  }

  // chips replaced by category TabBar

  void _openCreateListing(BuildContext context) async {
    final Listing? created = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NewListingScreen()),
    );
    if (created != null) {
      setState(() {
        _myListings.add(created);
        _listings.insert(0, created);
      });
      MarketplaceStore.instance.addListing(created);
    }
  }

  void _openDetail(BuildContext context, Listing listing) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: listing)),
    );
  }

  Widget _categoryBlock({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? AppColors.primaryRed : Colors.grey.shade400,
              width: 1.2,
            ),
            // color: Colors.white,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: selected ? AppColors.primaryRed : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}