// filepath: lib/models/quiz_category_model.dart
import 'package:flutter/material.dart';
import 'package:hand_speak/features/learn/models/sign_language_video.dart';

class QuizExample {
  final String word;
  final String description;
  final String gestureDescription;
  final String difficulty; // 'easy', 'medium', 'hard'

  const QuizExample({
    required this.word,
    required this.description,
    required this.gestureDescription,
    required this.difficulty,
  });
}

class QuizCategory {
  final String id;
  final String nameKey; // Translation key for the category name
  final String descriptionKey; // Translation key for the description
  final IconData icon;
  final Color color;
  final List<String> questionTypes;
  final Map<SignLanguageType, List<QuizExample>>? examples;
  final int? estimatedQuestions;
  final String? difficultyLevel;
  final List<String>? skills; // What skills this category helps develop

  const QuizCategory({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    required this.icon,
    required this.color,
    required this.questionTypes,
    this.examples,
    this.estimatedQuestions,
    this.difficultyLevel,
    this.skills,
  });
}

// Define quiz categories with complete data
final List<QuizCategory> quizCategories = [
  QuizCategory(
    id: 'all',
    nameKey: 'Tüm Kategoriler',
    descriptionKey: 'Tüm kategorilerden karışık sorular',
    icon: Icons.category,
    color: Colors.purple,
    questionTypes: ['letters', 'numbers', 'daily_words', 'greetings', 'time_expressions'],
    estimatedQuestions: 50,
    difficultyLevel: 'mixed',
    skills: ['Genel bilgi', 'Hızlı tanıma', 'Kategori geçişleri'],
    examples: {
      SignLanguageType.turkish: [
        QuizExample(word: 'A', description: 'Alfabenin ilk harfi', gestureDescription: 'Yumruk yapıp başparmağı yana doğru uzatın', difficulty: 'easy'),
        QuizExample(word: '5', description: 'Beş sayısı', gestureDescription: 'Beş parmağınızı açık tutun', difficulty: 'easy'),
        QuizExample(word: 'Merhaba', description: 'Selamlama ifadesi', gestureDescription: 'Açık el ile hafif sallama hareketi', difficulty: 'easy'),
      ],
      SignLanguageType.american: [
        QuizExample(word: 'A', description: 'First letter of alphabet', gestureDescription: 'Make a fist with thumb on the side', difficulty: 'easy'),
        QuizExample(word: '5', description: 'Number five', gestureDescription: 'Show all five fingers spread', difficulty: 'easy'),
        QuizExample(word: 'Hello', description: 'Greeting expression', gestureDescription: 'Open hand wave motion', difficulty: 'easy'),
      ],
    },
  ),
  QuizCategory(
    id: 'letters',
    nameKey: 'Harfler',
    descriptionKey: 'Alfabedeki harfleri öğrenin',
    icon: Icons.text_fields,
    color: Colors.blue,
    questionTypes: ['letters'],
    estimatedQuestions: 29,
    difficultyLevel: 'easy',
    skills: ['Alfabe bilgisi', 'Harf tanıma', 'El şekilleri'],
    examples: {
      SignLanguageType.turkish: [
        QuizExample(word: 'A', description: 'Alfabenin ilk harfi', gestureDescription: 'Yumruk yapıp başparmağı yana doğru uzatın', difficulty: 'easy'),
        QuizExample(word: 'B', description: 'Alfabenin ikinci harfi', gestureDescription: 'Düz avuç içi, başparmak içe kıvrık', difficulty: 'easy'),
        QuizExample(word: 'C', description: 'Alfabenin üçüncü harfi', gestureDescription: 'C şekli oluşturacak şekilde kavisli el', difficulty: 'easy'),
        QuizExample(word: 'D', description: 'Alfabenin dördüncü harfi', gestureDescription: 'İşaret parmağı yukarı, diğerleri başparmakla birleşik', difficulty: 'easy'),
        QuizExample(word: 'E', description: 'Alfabenin beşinci harfi', gestureDescription: 'Tüm parmaklar kıvrık, başparmak önde', difficulty: 'medium'),
        QuizExample(word: 'F', description: 'Alfabenin altıncı harfi', gestureDescription: 'Başparmak ve işaret parmağı halka, diğerleri açık', difficulty: 'medium'),
      ],
      SignLanguageType.american: [
        QuizExample(word: 'A', description: 'First letter', gestureDescription: 'Fist with thumb on side', difficulty: 'easy'),
        QuizExample(word: 'B', description: 'Second letter', gestureDescription: 'Flat palm, thumb folded in', difficulty: 'easy'),
        QuizExample(word: 'C', description: 'Third letter', gestureDescription: 'Curved hand forming C shape', difficulty: 'easy'),
        QuizExample(word: 'D', description: 'Fourth letter', gestureDescription: 'Index finger up, others meet thumb', difficulty: 'easy'),
        QuizExample(word: 'E', description: 'Fifth letter', gestureDescription: 'All fingers curved, thumb in front', difficulty: 'medium'),
        QuizExample(word: 'F', description: 'Sixth letter', gestureDescription: 'Thumb and index circle, others extended', difficulty: 'medium'),
      ],
    },
  ),
  QuizCategory(
    id: 'numbers',
    nameKey: 'Sayılar',
    descriptionKey: 'Sayıları işaret diliyle ifade edin',
    icon: Icons.pin,
    color: Colors.green,
    questionTypes: ['numbers'],
    estimatedQuestions: 20,
    difficultyLevel: 'easy',
    skills: ['Sayı sayma', 'Matematik temelleri', 'Parmak koordinasyonu'],
    examples: {
      SignLanguageType.turkish: [
        QuizExample(word: '1', description: 'Bir sayısı', gestureDescription: 'İşaret parmağını yukarı kaldırın', difficulty: 'easy'),
        QuizExample(word: '2', description: 'İki sayısı', gestureDescription: 'İşaret ve orta parmağı yukarı kaldırın', difficulty: 'easy'),
        QuizExample(word: '3', description: 'Üç sayısı', gestureDescription: 'İşaret, orta ve yüzük parmağını kaldırın', difficulty: 'easy'),
        QuizExample(word: '4', description: 'Dört sayısı', gestureDescription: 'Başparmak hariç dört parmağı kaldırın', difficulty: 'easy'),
        QuizExample(word: '5', description: 'Beş sayısı', gestureDescription: 'Tüm parmakları açık tutun', difficulty: 'easy'),
        QuizExample(word: '10', description: 'On sayısı', gestureDescription: 'Başparmağı sallayın veya A harfi yapın', difficulty: 'medium'),
      ],
      SignLanguageType.american: [
        QuizExample(word: '1', description: 'Number one', gestureDescription: 'Index finger up', difficulty: 'easy'),
        QuizExample(word: '2', description: 'Number two', gestureDescription: 'Index and middle finger up', difficulty: 'easy'),
        QuizExample(word: '3', description: 'Number three', gestureDescription: 'Thumb, index and middle up', difficulty: 'easy'),
        QuizExample(word: '4', description: 'Number four', gestureDescription: 'Four fingers up, thumb down', difficulty: 'easy'),
        QuizExample(word: '5', description: 'Number five', gestureDescription: 'All fingers spread', difficulty: 'easy'),
        QuizExample(word: '10', description: 'Number ten', gestureDescription: 'Shake thumb or make A sign', difficulty: 'medium'),
      ],
    },
  ),
  QuizCategory(
    id: 'daily_words',
    nameKey: 'Günlük Kelimeler',
    descriptionKey: 'Günlük hayatta kullanılan temel kelimeler',
    icon: Icons.chat_bubble,
    color: Colors.orange,
    questionTypes: ['daily_words'],
    estimatedQuestions: 25,
    difficultyLevel: 'medium',
    skills: ['Günlük iletişim', 'Temel kelime bilgisi', 'Pratik kullanım'],
    examples: {
      SignLanguageType.turkish: [
        QuizExample(word: 'Su', description: 'İçecek', gestureDescription: 'W harfi yapıp ağza doğru götürün', difficulty: 'easy'),
        QuizExample(word: 'Ekmek', description: 'Temel gıda', gestureDescription: 'Dilim kesme hareketi yapın', difficulty: 'easy'),
        QuizExample(word: 'Anne', description: 'Ebeveyn', gestureDescription: 'Açık el ile yanağa dokunun', difficulty: 'easy'),
        QuizExample(word: 'Baba', description: 'Ebeveyn', gestureDescription: 'Açık el ile alına dokunun', difficulty: 'easy'),
        QuizExample(word: 'Ev', description: 'Yaşanılan yer', gestureDescription: 'İki eli çatı şeklinde birleştirin', difficulty: 'medium'),
        QuizExample(word: 'Okul', description: 'Eğitim yeri', gestureDescription: 'İki eli alkış pozisyonunda iki kez vurun', difficulty: 'medium'),
      ],
      SignLanguageType.american: [
        QuizExample(word: 'Water', description: 'Drink', gestureDescription: 'W sign to mouth', difficulty: 'easy'),
        QuizExample(word: 'Bread', description: 'Food', gestureDescription: 'Slicing motion', difficulty: 'easy'),
        QuizExample(word: 'Mother', description: 'Parent', gestureDescription: 'Open hand to chin', difficulty: 'easy'),
        QuizExample(word: 'Father', description: 'Parent', gestureDescription: 'Open hand to forehead', difficulty: 'easy'),
        QuizExample(word: 'Home', description: 'Living place', gestureDescription: 'Hands form roof shape', difficulty: 'medium'),
        QuizExample(word: 'School', description: 'Education place', gestureDescription: 'Clap hands twice', difficulty: 'medium'),
      ],
    },
  ),
  QuizCategory(
    id: 'greetings',
    nameKey: 'Selamlaşma',
    descriptionKey: 'Selamlaşma ve nezaket ifadeleri',
    icon: Icons.waving_hand,
    color: Colors.red,
    questionTypes: ['greetings'],
    estimatedQuestions: 15,
    difficultyLevel: 'easy',
    skills: ['Sosyal iletişim', 'Nezaket kuralları', 'Günlük selamlaşma'],
    examples: {
      SignLanguageType.turkish: [
        QuizExample(word: 'Merhaba', description: 'Selamlama', gestureDescription: 'Açık el ile sallama hareketi', difficulty: 'easy'),
        QuizExample(word: 'Günaydın', description: 'Sabah selamı', gestureDescription: 'Güneş işareti sonra selam', difficulty: 'easy'),
        QuizExample(word: 'İyi akşamlar', description: 'Akşam selamı', gestureDescription: 'Akşam işareti sonra selam', difficulty: 'medium'),
        QuizExample(word: 'Hoşça kal', description: 'Vedalaşma', gestureDescription: 'El sallama hareketi', difficulty: 'easy'),
        QuizExample(word: 'Teşekkürler', description: 'Minnettarlık', gestureDescription: 'Çeneden dışarı doğru açık el', difficulty: 'easy'),
        QuizExample(word: 'Rica ederim', description: 'Nezaket', gestureDescription: 'Açık eller aşağı hareket', difficulty: 'medium'),
      ],
      SignLanguageType.american: [
        QuizExample(word: 'Hello', description: 'Greeting', gestureDescription: 'Wave with open hand', difficulty: 'easy'),
        QuizExample(word: 'Good morning', description: 'Morning greeting', gestureDescription: 'Sun sign then wave', difficulty: 'easy'),
        QuizExample(word: 'Good evening', description: 'Evening greeting', gestureDescription: 'Evening sign then wave', difficulty: 'medium'),
        QuizExample(word: 'Goodbye', description: 'Farewell', gestureDescription: 'Wave motion', difficulty: 'easy'),
        QuizExample(word: 'Thank you', description: 'Gratitude', gestureDescription: 'Open hand from chin outward', difficulty: 'easy'),
        QuizExample(word: 'You\'re welcome', description: 'Politeness', gestureDescription: 'Open hands move down', difficulty: 'medium'),
      ],
    },
  ),
  QuizCategory(
    id: 'time_expressions',
    nameKey: 'Zaman İfadeleri',
    descriptionKey: 'Zamanla ilgili kelime ve ifadeler',
    icon: Icons.access_time,
    color: Colors.teal,
    questionTypes: ['time_expressions'],
    estimatedQuestions: 18,
    difficultyLevel: 'medium',
    skills: ['Zaman kavramı', 'Takvim bilgisi', 'Saat okuma'],
    examples: {
      SignLanguageType.turkish: [
        QuizExample(word: 'Şimdi', description: 'Şu an', gestureDescription: 'İki eli aşağı doğru hareket ettirin', difficulty: 'easy'),
        QuizExample(word: 'Yarın', description: 'Gelecek gün', gestureDescription: 'Başparmağı yanaktan ileri itin', difficulty: 'easy'),
        QuizExample(word: 'Dün', description: 'Geçmiş gün', gestureDescription: 'Başparmağı geriye doğru hareket ettirin', difficulty: 'easy'),
        QuizExample(word: 'Saat', description: 'Zaman birimi', gestureDescription: 'Bileğe dokunma hareketi', difficulty: 'medium'),
        QuizExample(word: 'Dakika', description: 'Zaman birimi', gestureDescription: 'İşaret parmağı ile saat hareketi', difficulty: 'medium'),
        QuizExample(word: 'Hafta', description: 'Yedi gün', gestureDescription: 'Bir el diğer elin üzerinde kayar', difficulty: 'hard'),
      ],
      SignLanguageType.american: [
        QuizExample(word: 'Now', description: 'Present time', gestureDescription: 'Both hands move down', difficulty: 'easy'),
        QuizExample(word: 'Tomorrow', description: 'Next day', gestureDescription: 'Thumb forward from cheek', difficulty: 'easy'),
        QuizExample(word: 'Yesterday', description: 'Previous day', gestureDescription: 'Thumb backward motion', difficulty: 'easy'),
        QuizExample(word: 'Hour', description: 'Time unit', gestureDescription: 'Touch wrist motion', difficulty: 'medium'),
        QuizExample(word: 'Minute', description: 'Time unit', gestureDescription: 'Index finger clock motion', difficulty: 'medium'),
        QuizExample(word: 'Week', description: 'Seven days', gestureDescription: 'One hand slides over other', difficulty: 'hard'),
      ],
    },
  ),
];