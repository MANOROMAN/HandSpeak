import 'package:flutter/material.dart';
import 'package:hand_speak/features/learn/screens/video_list_screen.dart';

class NumbersScreen extends StatelessWidget {
  const NumbersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ModernVideoListScreen(categoryId: 'numbers');
  }
}
