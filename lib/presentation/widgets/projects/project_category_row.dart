import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/project.dart';
import '../common/glass_card.dart';
import '../common/horizontal_scroll_list.dart';
import 'earlier_project_card.dart';
import 'project_card.dart';

/// One outlined container holding a category heading ("Featured Projects" /
/// "Earlier Work") and its horizontally-scrollable row of cards. A project
/// with a showcase gets an image card; one without gets a text card.
class ProjectCategoryRow extends StatelessWidget {
  final String heading;
  final List<Project> projects;

  const ProjectCategoryRow({
    super.key,
    required this.heading,
    required this.projects,
  });

  Widget _card(Project project) {
    final showcase = project.showcase;
    return showcase == null
        ? EarlierProjectCard(project: project)
        : ProjectCard(project: project, showcase: showcase);
  }

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < projects.length; i++)
          Padding(
            padding: EdgeInsets.only(
              right: i == projects.length - 1 ? 0 : AppDimensions.spaceMd,
            ),
            child: _card(projects[i]),
          ),
      ],
    );

    // width: double.infinity guards against this card sizing to its own
    // (possibly narrower) scrollable content instead of matching the full
    // section width — see the same fix on AboutSection's Skills card.
    return SizedBox(
      width: double.infinity,
      child: GlassCard(
        // Horizontal padding is dropped from the card and re-applied inside
        // the scrollable below, so cards slide right up to the card border and
        // clip there rather than vanishing at an inset gutter. The vertical
        // inset stays, which also keeps the row clear of the rounded corners.
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spaceMd,
              ),
              child: Text(heading, style: AppTextStyles.cardHeading),
            ),
            const SizedBox(height: AppDimensions.spaceMd),
            HorizontalScrollList(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spaceMd,
              ),
              child: row,
            ),
          ],
        ),
      ),
    );
  }
}
