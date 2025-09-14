import 'package:news_app/feature/home/domain/enum/home_page_section_enum.dart';
import 'package:news_app/generated/locales.g.dart';

extension HomePageSectionExtension on HomePageSectionEnum {
  String get localized {
    switch (this) {
      case HomePageSectionEnum.game:
        return LocaleKeys.home_game.tr;
      case HomePageSectionEnum.audio:
        return LocaleKeys.home_audio.tr;
      case HomePageSectionEnum.wirecutter:
        return LocaleKeys.home_wirecutter.tr;
      case HomePageSectionEnum.cooking:
        return LocaleKeys.home_cooking.tr;
      case HomePageSectionEnum.theAthletic:
        return LocaleKeys.home_theAthletic.tr;
      case HomePageSectionEnum.home:
        return LocaleKeys.home_today.tr;
      case HomePageSectionEnum.lifestyle:
        return LocaleKeys.home_lifestyle.tr;
      case HomePageSectionEnum.greatReads:
        return LocaleKeys.home_greatReads.tr;
      case HomePageSectionEnum.option:
        return LocaleKeys.home_option.tr;
      case HomePageSectionEnum.sections:
        return LocaleKeys.home_sections.tr;
    }
  }
}
