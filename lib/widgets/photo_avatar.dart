import 'dart:io';
import 'package:flutter/material.dart';

class PhotoAvatar extends StatelessWidget {
  final String? path;
  final double radius;
  final String fallbackText;

  const PhotoAvatar({
    super.key,
    required this.path,
    this.radius = 30,
    this.fallbackText = '?',
  });

  @override
  Widget build(BuildContext context) {
    final valid = path != null && path!.isNotEmpty && File(path!).existsSync();
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      backgroundImage: valid ? FileImage(File(path!)) : null,
      child: valid
          ? null
          : Text(
              fallbackText.isEmpty ? '?' : fallbackText[0].toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontSize: radius * .65,
              ),
            ),
    );
  }
}
