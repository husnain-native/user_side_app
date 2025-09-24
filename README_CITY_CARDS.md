# Park View City App - City Cards Guide

## Overview
This app now uses local images instead of Firebase Storage for city cards. All images are stored locally in the `assets/images/` folder.

## How to Add New City Cards

### 1. Add Images to Assets
1. Place your new images in the `assets/images/` folder
2. Supported formats: `.jpg`, `.jpeg`, `.png`, `.gif`
3. Recommended image size: 400x300 pixels or similar aspect ratio

### 2. Update LocalCityCardService
Edit `lib/services/local_city_card_service.dart` and add new city cards to the `getLocalCityCards()` method:

```dart
CityCard(
  id: 'unique_id_here',
  title: 'City Name',
  subtitle: 'Description of the city or project',
  buttonText: 'Button Text',
  imagePath: 'assets/images/your_image.jpg',
  imageUrl: '', // Keep empty for local images
  isActive: true,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
),
```

### 3. Update pubspec.yaml (if adding new images)
Make sure your new images are included in the assets section:

```yaml
flutter:
  assets:
    - assets/images/
```

## Current City Cards

1. **Park View City Lahore** - `lhr.jpeg`
2. **Park View City Islamabad** - `logoisl.jpg`
3. **Lahore Premium Plots** - `logolhr.jpeg`
4. **City Overview** - `logocity.jpg`
5. **Premium Showcase** - `slider1.jpg`
6. **Modern Living** - `slider2.jpg`
7. **Luxury Amenities** - `slider3.jpeg`
8. **New Development** - `new2.jpeg`

## Benefits of Local Images

- ✅ No network dependency
- ✅ Faster loading
- ✅ No Firebase Storage errors
- ✅ Works offline
- ✅ Consistent user experience

## File Structure

```
park_chatapp/
├── assets/
│   └── images/
│       ├── lhr.jpeg
│       ├── logoisl.jpg
│       ├── logolhr.jpeg
│       ├── logocity.jpg
│       ├── slider1.jpg
│       ├── slider2.jpg
│       ├── slider3.jpeg
│       └── new2.jpeg
├── lib/
│   ├── services/
│   │   └── local_city_card_service.dart
│   ├── view/
│   │   ├── home_screen/
│   │   │   └── home_screen.dart
│   │   └── custom_widgets/
│   │       └── cities_card.dart
│   └── models/
│       └── city_card.dart
```

## Troubleshooting

### Image Not Loading
1. Check if the image path is correct in `local_city_card_service.dart`
2. Verify the image exists in `assets/images/` folder
3. Ensure the image is included in `pubspec.yaml`

### App Not Building
1. Run `flutter clean`
2. Run `flutter pub get`
3. Check for any syntax errors in the service file

## Adding More Features

You can extend the `LocalCityCardService` class to add:
- Filtering by city name
- Categorization of projects
- Search functionality
- Admin controls for enabling/disabling cards

## Example: Adding a New City

```dart
// In local_city_card_service.dart
CityCard(
  id: 'karachi_001',
  title: 'Park View City Karachi',
  subtitle: 'Experience coastal luxury living in Pakistan\'s largest city.',
  buttonText: 'Explore Karachi',
  imagePath: 'assets/images/karachi.jpg',
  imageUrl: '',
  isActive: true,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
),
```

Remember to add the corresponding image file `karachi.jpg` to your assets folder! 