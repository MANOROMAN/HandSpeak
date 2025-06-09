import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class LearningScreen extends StatelessWidget {
  const LearningScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrenme Merkezi'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'İşaret Dili Öğrenin',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Türk İşaret Dili\'ni adım adım öğrenin',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24.h),
              _buildCategoryGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    final categories = [
      {
        'id': 'alphabet',
        'title': 'Alfabe',
        'description': 'A-Z harflerini öğrenin',
        'icon': Icons.sign_language,
        'color': Colors.blue.shade600,
        'route': '/learn/alphabet',
      },
      {
        'id': 'numbers',
        'title': 'Sayılar',
        'description': '0-9 sayılarını öğrenin',
        'icon': Icons.format_list_numbered,
        'color': Colors.green.shade600,
        'route': '/learn/numbers',
      },
      {
        'id': 'phrases',
        'title': 'Yaygın İfadeler',
        'description': 'Günlük kullanılan ifadeler',
        'icon': Icons.chat_bubble_outline,
        'color': Colors.orange.shade600,
        'route': '/learn/phrases',
      },
      {
        'id': 'daily_words',
        'title': 'Günlük Kelimeler',
        'description': 'Her gün yeni kelimeler',
        'icon': Icons.calendar_today,
        'color': Colors.purple.shade600,
        'route': '/learn/daily-words',
      },
      {
        'id': 'research',
        'title': 'Araştırma',
        'description': 'İşaret dili araştırmaları',
        'icon': Icons.public,
        'color': Colors.teal.shade600,
        'route': '/learn/research',
      },
      {
        'id': 'quiz',
        'title': 'Test',
        'description': 'Bilginizi test edin',
        'icon': Icons.quiz,
        'color': Colors.red.shade600,
        'route': '/learn/quiz',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 0.9,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryCard(context, category);
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () => context.push(category['route']),
      child: Container(
        decoration: BoxDecoration(
          color: (category['color'] as Color).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: (category['color'] as Color).withOpacity(0.5), 
            width: 1
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              category['icon'] as IconData,
              size: 48.sp,
              color: category['color'] as Color,
            ),
            SizedBox(height: 12.h),
            Text(
              category['title'] as String,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                category['description'] as String,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
