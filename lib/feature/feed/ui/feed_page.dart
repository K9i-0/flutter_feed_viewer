import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feed_viewer/common_widget/common_label.dart';
import 'package:flutter_feed_viewer/common_widget/error_text_with_retry_button.dart';
import 'package:flutter_feed_viewer/feature/feed/feed_category.dart';
import 'package:flutter_feed_viewer/feature/feed/feed_repository.dart';
import 'package:flutter_feed_viewer/util/build_context_extension.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

final feedProviderFamily =
    FutureProvider.family.autoDispose<Feed, FeedCategory>(
  (ref, category) {
    switch (category) {
      case FeedCategory.zenn:
        return ref.watch(feedRepositoryProvider).fetchZennFeed();
      case FeedCategory.qiita:
        return ref.watch(feedRepositoryProvider).fetchQiitaFeed();
      case FeedCategory.medium:
        return ref.watch(feedRepositoryProvider).fetchMediumFeed();
    }
  },
);

class FeedPage extends HookConsumerWidget {
  final FeedCategory category;
  const FeedPage({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // タブ切り替え時の状態保持
    useAutomaticKeepAlive();

    return ref.watch(feedProviderFamily(category)).when(
          data: (data) {
            final articleList = data.articleList;
            return RefreshIndicator(
              onRefresh: () async => Future.wait([
                // 再読み込み感を出すために1秒待つ
                Future.delayed(const Duration(seconds: 1)),
                ref.refresh(feedProviderFamily(category).future),
              ]),
              child: ListView.separated(
                padding: EdgeInsets.only(
                  top: 8,
                  // SafeAreaがない場合は8、ある場合はSafeAreaのpaddingを使う
                  bottom: MediaQuery.of(context).padding.bottom == 0
                      ? 8
                      : MediaQuery.of(context).padding.bottom,
                ),
                itemCount: articleList.length,
                itemBuilder: (context, index) => ArticleItem(
                  article: articleList[index],
                ),
                separatorBuilder: (context, index) => const Gap(4),
              ),
            );
          },
          error: (e, st) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ErrorTextWithRetryButton(
                error: e,
                stackTrace: st,
                onRetry: () => ref.invalidate(feedProviderFamily(category)),
              ),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        );
  }
}

class ArticleItem extends HookConsumerWidget {
  final FeedArticle article;
  const ArticleItem({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => _launch(article.url ?? ''),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Stack(
          // シャアボタンのRippleがはみ出るようにする
          clipBehavior: Clip.none,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  child: CachedNetworkImage(
                    height: 94,
                    width: 168,
                    fit: BoxFit.fitWidth,
                    imageUrl: article.imageUrl ?? '',
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(4),
                      Text(
                        article.title ?? '',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(4),
                      Row(
                        children: [
                          // 新着表示
                          const CommonLabel(
                            label: '新着',
                            tooltip: '前回アプリを開いてからの新着記事',
                          ),
                          const Gap(4),
                          // n日前
                          Expanded(
                            child: Text(
                              article.elapsedTime,
                              style: context.textTheme.labelSmall,
                            ),
                          ),
                          // シェアボタンとの間隔
                          const Gap(4),
                          // シェアボタンと表示が被らなくするためのダミー
                          const Gap(24),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // 常に右下にシェアボタンを表示するためStackさせる
            Positioned(
              bottom: -12,
              right: -12,
              child: IconButton(
                icon: Icon(Icons.adaptive.share, size: 16),
                tooltip: 'シェア',
                // TODO(K9i-0): 実装
                onPressed: () => throw UnimplementedError(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// URLを開く
  Future<void> _launch(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
