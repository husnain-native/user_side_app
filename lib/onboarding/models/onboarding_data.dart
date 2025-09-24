// lib/models/onboarding_data.dart

class OnboardingData {
  final String logoAssetPath;
  final String imageAssetPath;
  final String subHeading;
  final String mainHeading;
  final String description;
  final String buttonText;

  const OnboardingData({
    required this.logoAssetPath,
    required this.imageAssetPath,
    required this.subHeading,
    required this.mainHeading,
    required this.description,
    required this.buttonText,
  });
}