import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../domain/entities/project.dart';
import '../../../domain/repositories/portfolio_repository.dart';
import '../common/section_heading.dart';
import 'project_category_row.dart';

class ProjectsSection extends StatelessWidget {
  const ProjectsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = Get.find<PortfolioRepository>();
    final featured = repository.getProjects(category: ProjectCategory.featured);
    final earlier = repository.getProjects(category: ProjectCategory.earlier);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceXxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading('my_projects_heading'.tr),
          const SizedBox(height: AppDimensions.spaceLg),
          if (featured.isNotEmpty)
            ProjectCategoryRow(
              heading: 'featured_projects_heading'.tr,
              projects: featured,
            ),
          if (featured.isNotEmpty && earlier.isNotEmpty)
            const SizedBox(height: AppDimensions.spaceLg),
          if (earlier.isNotEmpty)
            ProjectCategoryRow(
              heading: 'earlier_work_heading'.tr,
              projects: earlier,
            ),
        ],
      ),
    );
  }
}
