import 'package:flutter/material.dart';
import 'package:flutter_feed_viewer/common_widget/error_text_with_retry_button.dart';
import 'package:flutter_feed_viewer/feature/feed/feed_category.dart';
import 'package:flutter_feed_viewer/feature/feed/feed_repository.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
              child: ListView(
                children: articleList
                    .map(
                      (article) => ListTile(
                        title: Text(article.title ?? ''),
                      ),
                    )
                    .toList(),
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
