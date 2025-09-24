// lib/config/onboarding_config.dart

import '../models/onboarding_data.dart';

class OnboardingConfig {
  static const String logoPath = 'assets/images/logo2.png'; // Adjust your logo path
  
  static const List<OnboardingData> pages = [
    // Screen 1 - Sofa/Furniture
    OnboardingData(
      logoAssetPath: logoPath,
      imageAssetPath: 'assets/images/onboarding_utility.jpg',
      subHeading: "Manage Bills Easily",
      mainHeading: "All Payments, One Place",
      description: "From monthly utility bills to property installments and possession charges—manage everything in one place",
      buttonText: "Next",
    ),
    
    // Screen 2 - General Products
    OnboardingData(
      logoAssetPath: logoPath,
      imageAssetPath: 'assets/images/onboarding_marketplace.jpg',
      subHeading: "Everything You Need",
      mainHeading: "Buy & Sell Easily",
      description: "From daily essentials to unique finds, explore a marketplace designed for your convenience and trust.",
      buttonText: "Next",
    ),
    
    // Screen 3 - Electronics/iPhone
    OnboardingData(
      logoAssetPath: logoPath,
      imageAssetPath: 'assets/images/onboarding_complaints.png',
      subHeading: "Report. Track. Resolve.",
      mainHeading: "Complaints Made Simple",
      description: "Submit complaints about services, payments, or facilities and get timely updates until resolution.",
      buttonText: "Let's Get Started",
    ),
  ];
  
  // Helper methods
  static int get totalPages => pages.length;
  
  static OnboardingData getPage(int index) {
    if (index >= 0 && index < pages.length) {
      return pages[index];
    }
    throw IndexError(index, pages);
  }
}