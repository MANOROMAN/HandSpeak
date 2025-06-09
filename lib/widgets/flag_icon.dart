import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FlagIcon extends StatelessWidget {
  final ImageProvider imageProvider;
  final double size;

  const FlagIcon({
    Key? key,
    required this.imageProvider,
    this.size = 24,
  }) : super(key: key);

  /// Creates a FlagIcon from an asset path
  static FlagIcon fromLanguageType({required bool isTurkish, double size = 24}) {
    return FlagIcon(
      imageProvider: AssetImage(isTurkish ? 'assets/images/tr.png' : 'assets/images/en.png'),
      size: size,
    );
  }

  /// Creates a FlagIcon from an asset path
  factory FlagIcon.fromAsset(String assetPath, {double size = 24}) {
    return FlagIcon(
      imageProvider: AssetImage(assetPath),
      size: size,
    );
  }

  /// Creates a FlagIcon from a network URL
  factory FlagIcon.fromNetwork(String url, {double size = 24}) {
    return FlagIcon(
      imageProvider: NetworkImage(url),
      size: size,
    );
  }

  /// Creates a FlagIcon from a file path
  factory FlagIcon.fromFile(String filePath, {double size = 24}) {
    return FlagIcon(
      imageProvider: FileImage(File(filePath)),
      size: size,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
