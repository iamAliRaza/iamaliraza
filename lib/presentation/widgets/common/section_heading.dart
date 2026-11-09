import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';

class SectionHeading extends StatelessWidget {
  final String text;

  const SectionHeading(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.sectionHeading);
  }
}
