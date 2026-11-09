enum SocialPlatform { github, linkedIn, instagram, twitter, facebook }

class SocialLink {
  final SocialPlatform platform;
  final String url;
  final String iconAssetPath;

  const SocialLink({
    required this.platform,
    required this.url,
    required this.iconAssetPath,
  });
}
