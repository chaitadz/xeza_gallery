# Poppins Font Setup

## What was added:

### 1. Font Files
Added 4 weights of Google Font **Poppins** to `assets/fonts/`:
- `Poppins-Regular.ttf` (weight 400) - Regular text
- `Poppins-Medium.ttf` (weight 500) - Medium text
- `Poppins-SemiBold.ttf` (weight 600) - Semi-bold headings
- `Poppins-Bold.ttf` (weight 700) - Bold headings

### 2. pubspec.yaml Updates
Added font registration under `flutter:` section:
```yaml
fonts:
  - family: Poppins
    fonts:
      - asset: assets/fonts/Poppins-Regular.ttf
        weight: 400
      - asset: assets/fonts/Poppins-Medium.ttf
        weight: 500
      - asset: assets/fonts/Poppins-SemiBold.ttf
        weight: 600
      - asset: assets/fonts/Poppins-Bold.ttf
        weight: 700
```

### 3. Theme Configuration (app_theme.dart)
Updated `AppTheme.getDarkTheme()` to:
- Set `fontFamily: 'Poppins'` as the default font for the entire app
- Configured `textTheme` for all text styles:
  - Display styles (displayLarge, displayMedium, displaySmall) → Bold weight
  - Headline styles (headlineLarge, headlineMedium, headlineSmall) → Bold weight
  - Title styles (titleLarge, titleMedium, titleSmall) → SemiBold weight
  - Body styles (bodyLarge, bodyMedium, bodySmall) → Regular weight
  - Label styles (labelLarge, labelMedium, labelSmall) → Medium/SemiBold weight

### 4. Seed Color Fixed
Changed seed color from red to **deepPurple** (as per project specification in CLAUDE.md)

## Usage:
The font is now applied globally to all text in the app. No additional configuration needed.
To use specific font weights, use `FontWeight` parameter:
```dart
Text(
  'Hello',
  style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
)
```

Or use theme's textTheme:
```dart
Text(
  'Hello',
  style: Theme.of(context).textTheme.headlineSmall,
)
```
