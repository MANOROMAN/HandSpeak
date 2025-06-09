import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:hand_speak/core/services/logging_service.dart';

class TranslationService {
  final OnDeviceTranslator _translator;
  
  TranslationService()
      : _translator = OnDeviceTranslator(
          sourceLanguage: TranslateLanguage.turkish,
          targetLanguage: TranslateLanguage.english,
        );

  Future<String> translate(String text, {
    String sourceLanguage = 'tr',
    String targetLanguage = 'en',
  }) async {
    try {
      // Dil modellerini kontrol et ve indir
      final modelManager = OnDeviceTranslatorModelManager();
      final isSourceDownloaded = await modelManager.isModelDownloaded(sourceLanguage);
      final isTargetDownloaded = await modelManager.isModelDownloaded(targetLanguage);

      if (!isSourceDownloaded) {
        await modelManager.downloadModel(sourceLanguage);
      }
      if (!isTargetDownloaded) {
        await modelManager.downloadModel(targetLanguage);
      }

      // Çeviriyi yap
      final translation = await _translator.translateText(text);
      return translation;
    } catch (e) {
      LoggingService.error('Translation failed', e);
      return text; // Hata durumunda orijinal metni döndür
    }
  }

  Future<bool> isLanguageDownloaded(String languageCode) async {
    try {
      final modelManager = OnDeviceTranslatorModelManager();
      return await modelManager.isModelDownloaded(languageCode);
    } catch (e) {
      LoggingService.error('Checking language download status failed', e);
      return false;
    }
  }

  Future<void> downloadLanguage(String languageCode) async {
    try {
      final modelManager = OnDeviceTranslatorModelManager();
      await modelManager.downloadModel(languageCode);
    } catch (e) {
      LoggingService.error('Language download failed', e);
      rethrow;
    }
  }

  Future<List<String>> getAvailableLanguages() async {
    try {
      final modelManager = OnDeviceTranslatorModelManager();
      // Common language pairs to check
      final commonLanguages = ['en', 'tr', 'de', 'fr', 'es', 'it'];
      final availableLanguages = <String>[];
      
      for (final lang in commonLanguages) {
        final isDownloaded = await modelManager.isModelDownloaded(
          TranslateLanguage.values.firstWhere(
            (l) => l.bcpCode == lang,
            orElse: () => TranslateLanguage.english,
          ).bcpCode,
        );
        if (isDownloaded) {
          availableLanguages.add(lang);
        }
      }
      
      return availableLanguages;
    } catch (e) {
      LoggingService.error('Getting available languages failed', e);
      return ['en', 'tr']; // Default fallback
    }
  }

  void dispose() {
    _translator.close();
  }
}
