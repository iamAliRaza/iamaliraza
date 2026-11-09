/// Single source of truth for spacing, radii, and layout sizing.
/// Values are pulled directly from the Figma design.
class AppDimensions {
  AppDimensions._();

  // Fixed desktop canvas width the Figma frame was designed at.
  static const double canvasWidth = 1440;

  // Spacing scale
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
  static const double spaceXxl = 48;

  // Radii
  static const double radiusSmall = 5;
  static const double radiusImage = 10;
  static const double radiusCard = 15;
  static const double radiusPill = 100;

  // Component sizing
  static const double navBarHeight = 78;
  static const double navLogoSize = 44;
  static const double socialIconSize = 22;
  static const double pillButtonIconSize = 18;
  static const double skillTileHeight = 120;
  static const double skillTileIconSize = 44;
  static const double skillListCardMinHeight = 284;
  // Inline footer glyphs (Flutter mark, flag) — sized to sit on the footer's
  // 16px text line without pushing its height around.
  static const double footerIconSize = 15;
  static const double footerFlagWidth = 19;
  static const double footerFlagHeight = 13;

  static const double projectCardWidth = 482;
  static const double projectImageHeight = 236;
  // Subtracted from the viewport so a card fits a phone screen with the next
  // card peeking in (page + row + card padding, plus the peek).
  static const double projectCardViewportInset = 96;
  static const double earlierProjectCardWidth = 340;
  static const double earlierProjectCardMinHeight = 320;
  static const double projectDialogMaxWidth = 860;
  static const double projectGalleryHeight = 380;
  static const double projectQrSize = 160;
  // Non-card width across a Featured row: page padding, row padding, the gaps
  // between cards and the row's border.
  static const double featuredRowChrome =
      (spaceXl * 2) + (spaceMd * 2) + (spaceMd * 2) + (borderRegular * 2);
  static const int featuredCardsPerRow = 3;
  static const double scrollArrowSize = 40;
  static const double workflowCardMinHeight = 256;

  static const double experienceTimelineDotSize = 9;
  // Lines the dot up with the first line of the role title.
  static const double experienceTimelineDotTop = 6;
  static const double experienceTimelineIndent = spaceMd;

  // Hero photo — three-tier by breakpoint (see ResponsiveContext).
  static const double heroPhotoSize = 552;
  static const double heroPhotoSizeTablet = 320;
  static const double heroPhotoSizeMobile = 220;

  // Borders
  static const double borderRegular = 1;
}
