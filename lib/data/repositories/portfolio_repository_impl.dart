import '../../domain/entities/certification_entry.dart';
import '../../domain/entities/education_entry.dart';
import '../../domain/entities/experience_entry.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/skill.dart';
import '../../domain/entities/social_link.dart';
import '../../domain/entities/workflow_overview.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../datasources/portfolio_content.dart';

/// Serves the compile-time content in portfolio_content.dart. There's no
/// storage layer on purpose — the content is static and nothing persists, so
/// this interface (not a local DB) is the seam where a CMS/JSON source would
/// plug in later.
class PortfolioRepositoryImpl implements PortfolioRepository {
  @override
  Profile getProfile() => portfolioProfile;

  @override
  List<SocialLink> getSocialLinks() => portfolioSocialLinks;

  @override
  List<SkillGroup> getSkillGroups() => portfolioSkillGroups;

  @override
  WorkflowOverview getWorkflow() => portfolioWorkflow;

  @override
  List<ExperienceEntry> getExperience() => portfolioExperience;

  @override
  List<EducationEntry> getEducation() => portfolioEducation;

  @override
  List<CertificationEntry> getCertifications() => portfolioCertifications;

  @override
  List<Project> getProjects({ProjectCategory? category}) => category == null
      ? portfolioProjects
      : portfolioProjects.where((p) => p.category == category).toList();
}
