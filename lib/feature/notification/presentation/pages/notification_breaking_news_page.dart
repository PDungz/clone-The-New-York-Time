import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:news_app/core/theme/app_dimension.dart';
import 'package:news_app/core/theme/theme_manager.dart';
import 'package:news_app/feature/notification/domain/entities/notification.dart';
import 'package:news_app/feature/notification/domain/enum/category_enum.dart';
import 'package:news_app/feature/notification/presentation/bloc/notification_bloc/notification_bloc.dart';
import 'package:news_app/feature/notification/presentation/widget/loading_notification_widget.dart';
import 'package:news_app/gen/assets.gen.dart';
import 'package:packages/core/utils/format_date.dart';
import 'package:packages/widget/button/icon_button_widget.dart';
import 'package:packages/widget/image_widget/cached_image_widget.dart';
import 'package:packages/widget/list_view/list_view_widget.dart';

class NotificationBreakingNewsPage extends StatefulWidget {
  const NotificationBreakingNewsPage({super.key});

  @override
  State<NotificationBreakingNewsPage> createState() => _NotificationBreakingNewsPageState();
}

class _NotificationBreakingNewsPageState extends State<NotificationBreakingNewsPage>
    with AutomaticKeepAliveClientMixin {
  bool _hasInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      _hasInitialized = true;
      context.read<NotificationBloc>().add(
        GetUserNotificationsEvent(
          page: 0,
          size: 20,
          categoryName: CategoryEnum.breaking_news.name,
        ),
      );
    }
  }

  Future<void> _onRefresh() async {
    if (mounted) {
      context.read<NotificationBloc>().add(
        GetUserNotificationsEvent(
          page: 0,
          size: 20,
          categoryName: CategoryEnum.breaking_news.name,
        ),
      );
    }
  }

  Future<void> _onLoadMore() async {
    if (mounted) {
      final bloc = context.read<NotificationBloc>();
      final currentState = bloc.state;

      // Chỉ load more nếu đang ở trạng thái loaded và chưa đạt max
      if (currentState is NotificationLoaded && !currentState.hasReachedMax) {
        bloc.add(LoadMoreNotificationsEvent());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        return ListViewWidgetExtension.withPagination<NotificationEntity>(
          data: state.notifications ?? [],
          isLoading: state.isLoading && !state.isLoaded,
          refreshIndicatorDisplacement: 8,
          onRefresh: _onRefresh,
          onLoadMore: _onLoadMore,
          alwaysAllowRefresh: true,
          alwaysAllowLoadMore: true,
          enableLoadMoreOnEmpty: true,
          minimumItemsForLoadMore: 0,
          isLoadingMore: state is NotificationLoadingMore,
          loadMoreWidget: LottieBuilder.asset(
            $AssetsAnimationGen().loading.loadMore,
            backgroundLoading: false,
            height: 32,
            delegates: LottieDelegates(
              values: [
                ValueDelegate.color(const ['**'], value: AppThemeManager.primary),
              ],
            ),
          ),
          refreshWidget: LottieBuilder.asset(
            $AssetsAnimationGen().loading.loadingJson,
            backgroundLoading: false,
            height: 32,
            delegates: LottieDelegates(
              values: [
                ValueDelegate.color(const ['**'], value: AppThemeManager.primary),
              ],
            ),
          ),
          itemBuilder:
              (context, item, index) => GestureDetector(
                onTap: () {
                  if (!item.isRead) {
                    context.read<NotificationBloc>().add(
                      MarkNotificationAsReadEvent(notificationId: item.id ?? ''),
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsets.only(
                    top: index == 0 ? AppDimensions.inset24 : 0.0,
                    left: AppDimensions.inset20,
                    right: AppDimensions.inset20,
                    bottom: AppDimensions.inset20,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.inset16),
                    decoration: BoxDecoration(
                      color: AppThemeManager.card,
                      boxShadow: [
                        BoxShadow(
                          color: AppThemeManager.divider,
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppDimensions.inset12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${FormatDate.formatDDMMYYYY(DateTime.parse(item.createdAt ?? ''))} - ${FormatDate.formatHHMM(DateTime.parse(item.createdAt ?? ''))}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppThemeManager.textPrimary,
                                ),
                              ),
                              item.isRead
                                  ?
                                IconButtonWidget(
                                    svgPath: $AssetsIconsFilledGen().checkmark,
                                    size: 20,
                                    padding: EdgeInsets.zero,
                                    color: AppThemeManager.icon,
                                  )
                                  : SizedBox(height: 20),
                            ],
                          ),
                        ),
                        CachedImageWidget(
                          imageUrl: item.imageUrl ?? '',
                          originalWidth: 2048,
                          originalHeight: 1152,
                        ),
                        SizedBox(height: AppDimensions.space12),
                        Text(
                          item.title ?? '',
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(color: AppThemeManager.textPrimary),
                        ),
                        SizedBox(height: AppDimensions.space8),
                        Text(
                          item.body ?? '',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: AppThemeManager.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          loadingWidget: const LoadingNotificationWidget(),
        );
      },
    );
  }
}
