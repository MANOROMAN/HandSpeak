import 'package:flutter/material.dart';
import 'package:hand_speak/features/learn/screens/video_list_screen.dart';

class DailyWordsScreen extends StatelessWidget {
  const DailyWordsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const VideoListScreen(categoryId: 'daily_words');
  }
}
