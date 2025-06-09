# HandSpeak Translation System

This document provides instructions on using and extending the HandSpeak app's translation system.

## Overview

HandSpeak supports multiple languages through a centralized translation system. Currently, English and Turkish are supported, with the ability to easily add more languages in the future.

## How to Use Translations in UI Components

### 1. Import the Translation Helper

```dart
import 'package:hand_speak/core/utils/translation_helper.dart' show TranslationHelper, T;
```

### 2. Use the Translation Function

You can use the short form `T()` function to translate text:

```dart
Text(T(context, 'settings.title')), // Translates to "Settings" in English or "Ayarlar" in Turkish
```

Or the full form with `TranslationHelper`:

```dart
Text(TranslationHelper.translate(context, 'settings.title')),
```

## Translation Keys Structure

Translation keys use dot notation to organize translations hierarchically:
- `home.translation`: Text for the Translation tab
- `settings.theme_mode`: Text for the theme mode setting

## How to Add a New Translation Key

1. Open both translation files:
   - `assets/translations/en.json` (English)
   - `assets/translations/tr.json` (Turkish)

2. Add the new key with appropriate translations:

```json
// English version
{
  "new_section": {
    "new_key": "New Feature"
  }
}

// Turkish version
{
  "new_section": {
    "new_key": "Yeni Özellik"
  }
}
```

3. Use the new key in your UI:

```dart
Text(T(context, 'new_section.new_key'))
```

## How to Add a New Language

1. Create a new JSON file in `assets/translations/` with the language code as the filename:
   - Example: `fr.json` for French

2. Copy the structure from `en.json` and translate all values.

3. Update the supported locales in `app.dart`:

```dart
supportedLocales: const [
  Locale('en'), // English
  Locale('tr'), // Turkish
  Locale('fr'), // French (newly added)
],
```

## Error Handling

The translation system includes robust error handling:
- If a translation key doesn't exist, the key itself is returned
- If a translation file can't be loaded, it falls back to English
- Debug logs are printed when translation issues occur

## Testing Translations

You can test translations using the included test file:
`test/translation_helper_test.dart`

Run the tests with:
```
flutter test test/translation_helper_test.dart
```

## Best Practices

1. Always use the translation system for user-visible text
2. Keep translation keys organized and hierarchical
3. Ensure all supported languages have the same keys
4. Document new sections and keys when adding them
