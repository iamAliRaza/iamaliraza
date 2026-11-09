class Skill {
  final String name;

  /// Null for concepts with no logo, such as "Multi-tenancy".
  final String? iconAssetPath;

  const Skill({required this.name, this.iconAssetPath});
}

/// How prominently a group is shown: a highlighted card, logo tiles, or a
/// plain text list.
enum SkillGroupDisplay { spotlight, tiles, list }

class SkillGroup {
  final String title;
  final SkillGroupDisplay display;
  final List<Skill> skills;

  const SkillGroup({
    required this.title,
    required this.display,
    required this.skills,
  });
}
