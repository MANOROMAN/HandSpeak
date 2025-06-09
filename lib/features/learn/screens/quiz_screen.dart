// filepath: lib/features/learn/screens/quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hand_speak/models/quiz_category_model.dart';
import 'package:hand_speak/providers/sign_language_provider.dart';
import 'package:hand_speak/features/learn/models/sign_language_video.dart';
import 'dart:math' as math;
import 'dart:async';

class QuizQuestion {
  final String id;
  final String word;
  final String description;
  final String gestureDescription;
  final String difficulty;
  final List<String> options;
  final int correctAnswerIndex;
  final String category;
  final String? imageUrl;
  final String? videoUrl;

  QuizQuestion({
    required this.id,
    required this.word,
    required this.description,
    required this.gestureDescription,
    required this.difficulty,
    required this.options,
    required this.correctAnswerIndex,
    required this.category,
    this.imageUrl,
    this.videoUrl,
  });
}

class QuizResult {
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final double accuracyPercentage;
  final Duration totalTime;
  final List<QuizQuestion> wrongQuestions;
  final String performance;

  QuizResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.accuracyPercentage,
    required this.totalTime,
    required this.wrongQuestions,
    required this.performance,
  });
}

class ModernQuizScreen extends ConsumerStatefulWidget {
  final String? categoryId;

  const ModernQuizScreen({Key? key, this.categoryId}) : super(key: key);

  @override
  ConsumerState<ModernQuizScreen> createState() => _ModernQuizScreenState();
}

class _ModernQuizScreenState extends ConsumerState<ModernQuizScreen>
    with TickerProviderStateMixin {
  late QuizCategory selectedCategory;
  late AnimationController _animationController;
  late AnimationController _progressController;
  late AnimationController _questionController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Quiz State
  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  int? _selectedAnswerIndex;
  bool _quizStarted = false;
  bool _isLoading = false;
  Timer? _questionTimer;
  int _timeLeft = 30; // 30 seconds per question
  DateTime? _quizStartTime;
  List<QuizQuestion> _wrongQuestions = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _findSelectedCategory();
    _generateQuestions();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _questionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _questionController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  void _findSelectedCategory() {
    selectedCategory = quizCategories.firstWhere(
      (category) => category.id == widget.categoryId,
      orElse: () => quizCategories.first,
    );
  }

  void _generateQuestions() {
    final signLanguageType = ref.read(signLanguageProvider);
    List<QuizExample> examples = [];
    
    if (widget.categoryId == 'all') {
      // Mix questions from all categories
      for (var category in quizCategories) {
        if (category.id != 'all' && category.examples != null) {
          final categoryExamples = category.examples![signLanguageType] ?? [];
          examples.addAll(categoryExamples.map((e) => e));
        }
      }
      examples.shuffle();
    } else {
      examples = selectedCategory.examples?[signLanguageType] ?? [];
    }
    
    if (examples.isEmpty) return;

    _questions = [];
    
    // Create questions from examples with proper multiple choice options
    for (int i = 0; i < examples.length; i++) {
      final example = examples[i];
      final otherExamples = examples.where((e) => e.word != example.word).toList();
      
      // Generate wrong options
      List<String> wrongOptions = [];
      if (otherExamples.length >= 3) {
        otherExamples.shuffle();
        wrongOptions = otherExamples.take(3).map((e) => e.word).toList();
      } else {
        // Generate contextually relevant wrong options based on category
        wrongOptions = _generateContextualOptions(example.word, selectedCategory.id);
      }

      // Create all options and shuffle
      List<String> allOptions = [example.word, ...wrongOptions];
      allOptions.shuffle();
      
      final correctIndex = allOptions.indexOf(example.word);

      _questions.add(QuizQuestion(
        id: 'q_${i}_${selectedCategory.id}',
        word: example.word,
        description: example.description,
        gestureDescription: example.gestureDescription,
        difficulty: example.difficulty,
        options: allOptions,
        correctAnswerIndex: correctIndex,
        category: selectedCategory.id,
        imageUrl: 'assets/signs/${selectedCategory.id}/${example.word.toLowerCase()}.png',
        videoUrl: 'assets/videos/${selectedCategory.id}/${example.word.toLowerCase()}.mp4',
      ));
    }
    
    // Limit questions based on category
    final estimatedQuestions = selectedCategory.estimatedQuestions ?? 10;
    if (_questions.length > estimatedQuestions) {
      _questions.shuffle();
      _questions = _questions.take(estimatedQuestions).toList();
    }
  }

  List<String> _generateContextualOptions(String correctAnswer, String categoryId) {
    Map<String, List<String>> contextualOptions = {
      'letters': ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P'],
      'numbers': ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '15', '20', '25', '30', '50', '100'],
      'daily_words': ['Su', 'Ekmek', 'Anne', 'Baba', 'Ev', 'Okul', 'Kitap', 'Kalem', 'Masa', 'Sandalye'],
      'greetings': ['Merhaba', 'Günaydın', 'İyi Akşamlar', 'Hoşça Kal', 'Teşekkürler', 'Özür Dilerim'],
      'time_expressions': ['Şimdi', 'Yarın', 'Dün', 'Hafta', 'Ay', 'Yıl', 'Saat', 'Dakika'],
      'emotions': ['Mutlu', 'Üzgün', 'Kızgın', 'Şaşkın', 'Korkmuş', 'Heyecanlı', 'Sakin', 'Endişeli'],
    };

    List<String> options = contextualOptions[categoryId] ?? ['Seçenek 1', 'Seçenek 2', 'Seçenek 3'];
    options = options.where((option) => option != correctAnswer).toList();
    options.shuffle();
    return options.take(3).toList();
  }

  void _startQuiz() {
    if (_questions.isEmpty) {
      _showNoQuestionsDialog();
      return;
    }

    setState(() {
      _quizStarted = true;
      _currentQuestionIndex = 0;
      _score = 0;
      _isAnswered = false;
      _selectedAnswerIndex = null;
      _quizStartTime = DateTime.now();
      _wrongQuestions.clear();
    });

    _animationController.forward();
    _progressController.forward();
    _startQuestionTimer();
  }

  void _startQuestionTimer() {
    _timeLeft = 30;
    _questionTimer?.cancel();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0 && !_isAnswered) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _handleTimeUp();
      }
    });
  }

  void _handleTimeUp() {
    if (!_isAnswered) {
      _checkAnswer(-1); // Wrong answer due to timeout
    }
  }

  void _checkAnswer(int optionIndex) {
    if (_isAnswered) return;

    _questionTimer?.cancel();
    final currentQuestion = _questions[_currentQuestionIndex];
    
    setState(() {
      _selectedAnswerIndex = optionIndex;
      _isAnswered = true;
      
      if (optionIndex == currentQuestion.correctAnswerIndex) {
        _score++;
      } else {
        _wrongQuestions.add(currentQuestion);
      }
    });

    // Animate to next question
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      _moveToNextQuestion();
    });
  }

  void _moveToNextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _questionController.forward().then((_) {
        setState(() {
          _currentQuestionIndex++;
          _isAnswered = false;
          _selectedAnswerIndex = null;
        });
        _questionController.reset();
        _startQuestionTimer();
      });
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    _questionTimer?.cancel();
    final totalTime = DateTime.now().difference(_quizStartTime!);
    final result = QuizResult(
      totalQuestions: _questions.length,
      correctAnswers: _score,
      wrongAnswers: _questions.length - _score,
      accuracyPercentage: (_score / _questions.length) * 100,
      totalTime: totalTime,
      wrongQuestions: _wrongQuestions,
      performance: _getPerformanceLevel((_score / _questions.length) * 100),
    );
    
    _showResultDialog(result);
  }

  String _getPerformanceLevel(double percentage) {
    if (percentage >= 90) return 'Mükemmel';
    if (percentage >= 80) return 'Çok İyi';
    if (percentage >= 70) return 'İyi';
    if (percentage >= 60) return 'Orta';
    if (percentage >= 50) return 'Geliştirilmeli';
    return 'Tekrar Çalışmalı';
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressController.dispose();
    _questionController.dispose();
    _questionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signLanguageType = ref.watch(signLanguageProvider);
    
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF0D1117)
          : const Color(0xFFF8FAFC),
      body: _quizStarted ? _buildQuizBody() : _buildStartScreen(signLanguageType),
    );
  }

  Widget _buildStartScreen(SignLanguageType signLanguageType) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: selectedCategory.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: selectedCategory.color,
                      size: 20.sp,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [selectedCategory.color, selectedCategory.color.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    signLanguageType == SignLanguageType.turkish ? 'TİD' : 'ASL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 40.h),
            
            // Category Icon
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      selectedCategory.color,
                      selectedCategory.color.withOpacity(0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: selectedCategory.color.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Icon(
                  selectedCategory.icon,
                  size: 64.sp,
                  color: Colors.white,
                ),
              ),
            ),
            
            SizedBox(height: 32.h),
            
            // Category Name
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                selectedCategory.nameKey,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            SizedBox(height: 12.h),
            
            // Description
            Text(
              selectedCategory.descriptionKey,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 40.h),
            
            // Quiz Info Cards
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.quiz_rounded,
                    title: 'Sorular',
                    value: '${_questions.length}',
                    color: selectedCategory.color,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.timer_rounded,
                    title: 'Süre',
                    value: '${_questions.length * 30}s',
                    color: const Color(0xFFF59E0B),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildInfoCard(
                    icon: _getDifficultyIcon(selectedCategory.difficultyLevel ?? 'medium'),
                    title: 'Zorluk',
                    value: _getDifficultyText(selectedCategory.difficultyLevel ?? 'medium'),
                    color: _getDifficultyColor(selectedCategory.difficultyLevel ?? 'medium'),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 40.h),
            
            // Skills Section
            if (selectedCategory.skills != null && selectedCategory.skills!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black.withOpacity(0.3)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: selectedCategory.color.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.psychology_rounded,
                          color: selectedCategory.color,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Bu testte geliştireceğiniz beceriler',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: selectedCategory.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 6.h,
                      children: (selectedCategory.skills ?? []).map((skill) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: selectedCategory.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: selectedCategory.color.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            skill,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: selectedCategory.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            
            SizedBox(height: 40.h),
            
            // Start Button
            Container(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: _questions.isEmpty ? null : () {
                  _animationController.forward();
                  _startQuiz();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedCategory.color,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: selectedCategory.color.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded, size: 24.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Teste Başla',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizBody() {
    if (_questions.isEmpty) {
      return _buildNoQuestionsView();
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return SafeArea(
      child: Column(
        children: [
          // Quiz Header
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Progress and Timer Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Soru ${_currentQuestionIndex + 1}/${_questions.length}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: selectedCategory.color,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: _timeLeft <= 10 ? Colors.red : selectedCategory.color,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.timer_rounded, color: Colors.white, size: 16.sp),
                          SizedBox(width: 4.w),
                          Text(
                            '$_timeLeft',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                
                // Progress Bar
                Container(
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [selectedCategory.color, selectedCategory.color.withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Question Content
          Expanded(
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(_slideAnimation.value, 0),
                end: Offset.zero,
              ).animate(_questionController),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    // Question Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            selectedCategory.color.withOpacity(0.1),
                            selectedCategory.color.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                          color: selectedCategory.color.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Bu işaret hangi kelimeyi ifade eder?',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : const Color(0xFF1F2937),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24.h),
                          
                          // Sign Language Visual
                          Container(
                            width: 150.w,
                            height: 150.w,
                            decoration: BoxDecoration(
                              color: selectedCategory.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.sign_language_rounded,
                                  size: 80.sp,
                                  color: selectedCategory.color,
                                ),
                                SizedBox(height: 8.h),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: _getDifficultyColor(currentQuestion.difficulty),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    _getDifficultyText(currentQuestion.difficulty),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.h),
                          
                          Text(
                            currentQuestion.gestureDescription,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: selectedCategory.color,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          if (_isAnswered) ...[
                            SizedBox(height: 16.h),
                            Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: (_selectedAnswerIndex == currentQuestion.correctAnswerIndex 
                                    ? Colors.green 
                                    : Colors.red).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: _selectedAnswerIndex == currentQuestion.correctAnswerIndex 
                                      ? Colors.green 
                                      : Colors.red,
                                ),
                              ),
                              child: Text(
                                currentQuestion.description,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: _selectedAnswerIndex == currentQuestion.correctAnswerIndex 
                                      ? Colors.green 
                                      : Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 30.h),
                    
                    // Answer Options
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 2.5,
                      ),
                      itemCount: currentQuestion.options.length,
                      itemBuilder: (context, index) {
                        return _buildAnswerOption(currentQuestion, index);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Score Display
          Container(
            padding: EdgeInsets.all(20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.amber, size: 20.sp),
                    SizedBox(width: 4.w),
                    Text(
                      'Skor: $_score',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: selectedCategory.color,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${((_score / (_currentQuestionIndex + (_isAnswered ? 1 : 0))) * 100).toStringAsFixed(0)}% Doğru',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOption(QuizQuestion question, int index) {
    final isCorrect = index == question.correctAnswerIndex;
    final isSelected = _selectedAnswerIndex == index;
    final isWrong = _isAnswered && isSelected && !isCorrect;
    final shouldShowCorrect = _isAnswered && isCorrect;

    Color buttonColor;
    if (!_isAnswered) {
      buttonColor = selectedCategory.color.withOpacity(0.1);
    } else if (shouldShowCorrect) {
      buttonColor = Colors.green;
    } else if (isWrong) {
      buttonColor = Colors.red;
    } else {
      buttonColor = Colors.grey[300]!;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isAnswered ? null : () => _checkAnswer(index),
        borderRadius: BorderRadius.circular(16.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: !_isAnswered 
                  ? selectedCategory.color.withOpacity(0.3)
                  : (shouldShowCorrect ? Colors.green : (isWrong ? Colors.red : Colors.grey[400]!)),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isAnswered && (shouldShowCorrect || isWrong)) ...[
                Icon(
                  shouldShowCorrect ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
              ],
              Flexible(
                child: Text(
                  question.options[index],
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: _isAnswered 
                        ? Colors.white
                        : (Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white 
                            : const Color(0xFF1F2937)),
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoQuestionsView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 80.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 24.h),
            Text(
              'Bu kategoride henüz soru bulunmuyor',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              'Lütfen başka bir kategori seçin',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedCategory.color,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                ),
              ),
              child: Text(
                'Kategorilere Dön',
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoQuestionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24.sp),
            SizedBox(width: 8.w),
            const Text('Uyarı'),
          ],
        ),
        content: const Text('Bu kategoride henüz soru bulunmamaktadır. Lütfen başka bir kategori seçin.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showResultDialog(QuizResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: 300.w,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                selectedCategory.color.withOpacity(0.1),
                selectedCategory.color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Result Icon
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: result.accuracyPercentage >= 70 
                        ? [Colors.green, Colors.green.shade600]
                        : result.accuracyPercentage >= 50
                            ? [Colors.orange, Colors.orange.shade600]
                            : [Colors.red, Colors.red.shade600],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  result.accuracyPercentage >= 70 
                      ? Icons.emoji_events_rounded
                      : result.accuracyPercentage >= 50
                          ? Icons.thumb_up_rounded
                          : Icons.refresh_rounded,
                  color: Colors.white,
                  size: 40.sp,
                ),
              ),
              SizedBox(height: 20.h),
              
              // Performance Text
              Text(
                result.performance,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: selectedCategory.color,
                ),
              ),
              SizedBox(height: 8.h),
              
              // Accuracy
              Text(
                '%${result.accuracyPercentage.toStringAsFixed(0)} Doğru',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: 20.h),
              
              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem('Doğru', '${result.correctAnswers}', Colors.green),
                  _buildStatItem('Yanlış', '${result.wrongAnswers}', Colors.red),
                  _buildStatItem('Süre', '${result.totalTime.inMinutes}:${(result.totalTime.inSeconds % 60).toString().padLeft(2, '0')}', Colors.blue),
                ],
              ),
              SizedBox(height: 24.h),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.pop();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: const Text('Çıkış'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _restartQuiz();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedCategory.color,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: const Text('Tekrar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _restartQuiz() {
    setState(() {
      _quizStarted = false;
      _currentQuestionIndex = 0;
      _score = 0;
      _isAnswered = false;
      _selectedAnswerIndex = null;
      _wrongQuestions.clear();
    });
    _animationController.reset();
    _progressController.reset();
    _questionController.reset();
    _generateQuestions();
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty) {
      case 'easy': return Icons.sentiment_satisfied_rounded;
      case 'medium': return Icons.sentiment_neutral_rounded;
      case 'hard': return Icons.sentiment_very_dissatisfied_rounded;
      case 'mixed': return Icons.shuffle_rounded;
      default: return Icons.help_outline_rounded;
    }
  }

  String _getDifficultyText(String difficulty) {
    switch (difficulty) {
      case 'easy': return 'Kolay';
      case 'medium': return 'Orta';
      case 'hard': return 'Zor';
      case 'mixed': return 'Karma';
      default: return 'Bilinmiyor';
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy': return const Color(0xFF10B981);
      case 'medium': return const Color(0xFFF59E0B);
      case 'hard': return const Color(0xFFEF4444);
      case 'mixed': return const Color(0xFF8B5CF6);
      default: return Colors.grey;
    }
  }
}