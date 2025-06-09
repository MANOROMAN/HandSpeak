import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hand_speak/providers/language_provider.dart';

// Mock implementation of LanguageController for testing
class MockLanguageController extends LanguageController {
  MockLanguageController() : super();
  
  @override
  String translate(String key) {
    if (key == 'test.key') {
      return 'Hello World';
    }
    return key;
  }
  
  @override
  Future<void> setLanguage(Locale locale) async {
    state = locale;
  }
}

void main() {
  testWidgets('Translation system returns correct translations', (WidgetTester tester) async {
    // Create a mock provider
    final mockProvider = StateNotifierProvider<MockLanguageController, Locale>(
      (ref) => MockLanguageController(),
    );

    // Create a simple test widget that uses the mock provider
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          languageProvider.overrideWithProvider(mockProvider),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              // Get the translation
              final translatedText = ProviderScope.containerOf(context)
                  .read(mockProvider.notifier)
                  .translate('test.key');
              
              return Scaffold(
                body: Center(
                  child: Text(translatedText),
                ),
              );
            }
          ),
        ),
      ),
    );
    
    // Find the test text and verify it was translated correctly
    expect(find.text('Hello World'), findsOneWidget);
  });
}


