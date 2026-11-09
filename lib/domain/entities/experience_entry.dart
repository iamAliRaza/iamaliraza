/// One company on the work history, holding every role held there.
class ExperienceEntry {
  final String company;
  final String location;

  /// Newest first.
  final List<ExperienceRole> roles;

  const ExperienceEntry({
    required this.company,
    required this.location,
    required this.roles,
  });
}

class ExperienceRole {
  final String title;
  final String period;
  final List<String> highlights;

  const ExperienceRole({
    required this.title,
    required this.period,
    required this.highlights,
  });
}
