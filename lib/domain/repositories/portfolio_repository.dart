import '../entities/certification_entry.dart';
import '../entities/education_entry.dart';
import '../entities/experience_entry.dart';
import '../entities/profile.dart';
import '../entities/project.dart';
import '../entities/skill.dart';
import '../entities/social_link.dart';
import '../entities/workflow_overview.dart';

/// Contract for reading the portfolio owner's real content. Implemented by
/// the data layer — this layer stays plain Dart with zero
/// third-party dependencies.
abstract class PortfolioRepository {
  Profile getProfile();
  List<SocialLink> getSocialLinks();
  List<SkillGroup> getSkillGroups();
  WorkflowOverview getWorkflow();
  List<ExperienceEntry> getExperience();
  List<EducationEntry> getEducation();
  List<CertificationEntry> getCertifications();
  List<Project> getProjects({ProjectCategory? category});
}
