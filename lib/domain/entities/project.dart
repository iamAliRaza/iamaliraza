enum ProjectCategory { featured, earlier }

enum StorePlatform { googlePlay, appStore }

class Project {
  final String title;
  final ProjectCategory category;
  final String summary;
  final List<String> tech;

  /// Short descriptor, e.g. "Final Year Project". Optional.
  final String? label;

  /// Everything a clickable image card and its details dialog need. Null for
  /// projects with no images or store listing (Earlier Work), so a project is
  /// either fully showcased or a plain text card, never half-filled.
  final ProjectShowcase? showcase;

  const Project({
    required this.title,
    required this.category,
    required this.summary,
    required this.tech,
    this.label,
    this.showcase,
  });
}

class ProjectShowcase {
  final String coverAssetPath;

  /// One short line of evidence shown on the card, e.g. "50K+ downloads".
  final String proofLine;
  final List<String> highlights;
  final List<String> screenshotAssetPaths;
  final List<StoreLink> storeLinks;

  /// True when the store listings only exist to demo a B2B product, so the
  /// store links are labelled as demos rather than as the app itself.
  final bool isDemoListing;

  /// Short status shown beside the store links, e.g. a release still in
  /// review. Remove it once the release is live and add its [StoreLink].
  final String? availabilityNote;

  const ProjectShowcase({
    required this.coverAssetPath,
    required this.proofLine,
    required this.highlights,
    required this.screenshotAssetPaths,
    required this.storeLinks,
    this.isDemoListing = false,
    this.availabilityNote,
  });
}

class StoreLink {
  final StorePlatform platform;
  final String url;
  final String qrAssetPath;

  const StoreLink({
    required this.platform,
    required this.url,
    required this.qrAssetPath,
  });
}
