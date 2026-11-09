import 'package:get/get.dart';

import '../constants/app_strings.dart';

/// GetX translation source. UI text is looked up as `'key'.tr` anywhere in
/// presentation widgets, backed by the locale maps registered here.
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {'en_US': appStringsEnUS};
}
