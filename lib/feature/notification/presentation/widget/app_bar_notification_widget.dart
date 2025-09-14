import 'package:flutter/material.dart';
import 'package:news_app/core/theme/theme_manager.dart';
import 'package:news_app/feature/notification/domain/enum/category_enum.dart';
import 'package:news_app/feature/notification/domain/extension/category_extension.dart';
import 'package:news_app/gen/assets.gen.dart';
import 'package:news_app/generated/locales.g.dart';
import 'package:packages/widget/app_bar/app_bar_widget.dart';
import 'package:packages/widget/button/icon_button_widget.dart';
import 'package:packages/widget/tab_label/tab_label_widget.dart';
import 'package:packages/widget/text_field_widget/text_field_widget.dart';

class AppBarNotificationWidget extends StatefulWidget {
  const AppBarNotificationWidget({
    super.key,
    required this.selectedTabIndex,
    required this.pageController,
    required this.onTabSelected,
  });

  final int selectedTabIndex;
  final PageController pageController;
  final Function(int index) onTabSelected;

  @override
  State<AppBarNotificationWidget> createState() => _AppBarNotificationWidgetState();
}

class _AppBarNotificationWidgetState extends State<AppBarNotificationWidget> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBarWidget(
      backgroundColor: AppThemeManager.appBar,
      boxShadow: BoxShadow(
        color: AppThemeManager.shadow,
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
      leading: IconButtonWidget(
        onPressed: () => Navigator.pop(context),
        svgPath: $AssetsIconsFilledGen().backward,
        color: AppThemeManager.icon,
        padding: EdgeInsets.all(12.0),
      ),
      paddingTop: 0,
      paddingBottom: 0,
      title: Padding(
        padding: const EdgeInsets.only(left: 88, right: 88),
        child: Text(
          LocaleKeys.notification_title.tr,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppThemeManager.icon,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(24),
        child: Column(
          children: [
            TabLabelWidget(
              isScrollable: true,
              labels: [CategoryEnum.breaking_news.displayName, CategoryEnum.system.displayName],
              selectedTextStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppThemeManager.icon,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
              ),
              unselectedTextStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppThemeManager.unsetIcon,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
              ),
              fitIndicatorToText: true,
              paddingTabel: EdgeInsets.zero,
              touchAreaPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
              indicatorColor: AppThemeManager.icon,
              selectedIndex: widget.selectedTabIndex,
              onTap: widget.onTabSelected,
              spaceBetweenLabelAndIndicator: false,
              indicatorHeight: 4,
              showSelectedShadow: false,
              unselectedColor: AppThemeManager.unsetIcon,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 16, left: 16, right: 16),
              child: TextFieldWidget(
                controller: _searchController,
                borderRadius: BorderRadius.circular(4),
                focusNode: _searchFocusNode,
                svgPrefixIcon: $AssetsIconsFilledGen().search,
                prefixIconColor: AppThemeManager.unsetIcon,
                hint: LocaleKeys.notification_search.tr,
                hintStyle: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppThemeManager.unsetIcon),
                primaryColor: AppThemeManager.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
