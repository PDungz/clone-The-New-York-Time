import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:news_app/core/theme/theme_manager.dart';
import 'package:news_app/feature/home/domain/entities/article.dart';
import 'package:news_app/feature/home/presentation/bloc/top_stories_bloc/top_stories_bloc.dart';
import 'package:news_app/gen/assets.gen.dart';
import 'package:packages/widget/divider_widget/divider_widget.dart';
import 'package:packages/widget/image_widget/cached_image_widget.dart';
import 'package:packages/widget/list_view/list_view_widget.dart';
import 'package:packages/widget/shimmer/shimmer_widget.dart';

class HomeTheAthleticWidget extends StatelessWidget {
  const HomeTheAthleticWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 80),
      child: BlocBuilder<TopStoriesBloc, TopStoriesState>(
        builder: (context, state) {
          return ListViewWidgetExtension.withRefresh<Article>(
            data: state.articles,
            isLoading: state.isLoading && !state.hasData,
            refreshIndicatorDisplacement: 8,
            onRefresh: () async {
              context.read<TopStoriesBloc>().add(
                RefreshTopStoriesEvent(section: 'home'),
              );
            },
            refreshWidget: LottieBuilder.asset(
              $AssetsAnimationGen().loading.loadingJson,
              backgroundLoading: false,
              height: 32,
              delegates: LottieDelegates(
                values: [
                  ValueDelegate.color(const [
                    '**',
                  ], value: AppThemeManager.primary),
                ],
              ),
            ),

            itemBuilder:
                (context, item, index) => _ArticleListItem(article: item),
            loadingWidget: ArticleListItemShimmer(),
          );
        },
      ),
    );
  }
}

class _ArticleListItem extends StatelessWidget {
  final Article article;

  const _ArticleListItem({required this.article});

  @override
  Widget build(BuildContext context) {
    final hasImage = article.multimedia?.isNotEmpty == true;

    return GestureDetector(
      onTap: () {
        print('Tapped on: ${article.title}');
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 40, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              article.title ?? 'No title',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            if (article.abstract != null) ...[
              const SizedBox(height: 8),
              Text(
                article.abstract!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppThemeManager.nightModeText,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (hasImage) ...[
              const SizedBox(height: 12),
              CachedImageWidget(
                imageUrl: article.multimedia!.first.url ?? '',
                originalWidth: article.multimedia!.first.width?.toDouble(),
                originalHeight: article.multimedia!.first.height?.toDouble(),
              ),
            ],
            if (article.byline != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    article.byline!,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(fontSize: 8),
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 8),
              child: DividerWidget(
                color: AppThemeManager.divider,
                thickness: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArticleListItemShimmer extends StatelessWidget {
  const ArticleListItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 40, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerWidget(
            height: 20,
            borderRadius: 0,
            baseColor: AppThemeManager.nightModeText,
            highlightColor: AppThemeManager.nightModeText,
          ),
          const SizedBox(height: 8),
          ShimmerWidget(
            height: 14,
            borderRadius: 0,
            highlightColor: AppThemeManager.nightModeText,
            baseColor: AppThemeManager.nightModeText,
          ),
          const SizedBox(height: 12),
          ShimmerWidget(
            height: 180,
            borderRadius: 0,
            highlightColor: AppThemeManager.nightModeText,
            baseColor: AppThemeManager.nightModeText,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ShimmerWidget(
              height: 10,
              width: 80,
              borderRadius: 0,
              highlightColor: AppThemeManager.nightModeText,
              baseColor: AppThemeManager.nightModeText,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 12.0, bottom: 8),
            child: Divider(color: AppThemeManager.nightModeText, thickness: 2),
          ),
        ],
      ),
    );
  }
}
