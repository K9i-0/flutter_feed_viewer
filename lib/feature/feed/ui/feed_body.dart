import 'package:flutter/material.dart';
import 'package:flutter_feed_viewer/feature/feed/feed_category.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FeedBody extends HookConsumerWidget {
  final TabController tabController;
  const FeedBody({
    super.key,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TabBarView(
      controller: tabController,
      children: FeedCategory.values
          .map(
            (e) => Center(
              child: Text(e.label),
            ),
          )
          .toList(),
    );
  }
}
