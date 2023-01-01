import 'package:flutter/material.dart';
import 'package:flutter_feed_viewer/feature/feed/feed_category.dart';
import 'package:flutter_feed_viewer/feature/feed/ui/feed_app_bar.dart';
import 'package:flutter_feed_viewer/feature/feed/ui/feed_body.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FeedScreen extends HookConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController =
        useTabController(initialLength: FeedCategory.values.length);

    return Scaffold(
      appBar: FeedAppBar(
        tabController: tabController,
      ),
      body: FeedBody(
        tabController: tabController,
      ),
    );
  }
}
