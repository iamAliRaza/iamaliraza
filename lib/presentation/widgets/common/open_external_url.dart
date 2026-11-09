import 'package:url_launcher/url_launcher.dart';

/// Opens [url] outside the app (a new browser tab on web, or the mail client
/// for `mailto:`). Does nothing if the URL can't be launched.
Future<void> openExternalUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
