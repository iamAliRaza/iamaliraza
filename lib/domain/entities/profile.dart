/// The portfolio owner's identity and bio content (real data — lives in the
/// data layer's portfolio_content.dart, never in app_strings.dart).
class Profile {
  final String name;
  final String roleTitle;
  final String headline;
  final String heroBio;
  final String aboutBio;
  final String email;
  final String profileImageAsset;

  const Profile({
    required this.name,
    required this.roleTitle,
    required this.headline,
    required this.heroBio,
    required this.aboutBio,
    required this.email,
    required this.profileImageAsset,
  });
}
