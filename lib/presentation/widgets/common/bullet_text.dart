import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

/// One bulleted line that wraps with a hanging indent. Includes its own
/// bottom spacing, so a list is just a run of these.
class BulletText extends StatelessWidget {
  final String text;

  const BulletText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•  ', style: AppTextStyles.bodyRegular),
          Expanded(child: Text(text, style: AppTextStyles.bodyRegular)),
        ],
      ),
    );
  }
}
