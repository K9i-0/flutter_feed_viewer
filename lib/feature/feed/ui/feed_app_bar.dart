import 'package:flutter/material.dart';
import 'package:flutter_feed_viewer/feature/feed/feed_category.dart';

class FeedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;
  const FeedAppBar({
    super.key,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Flutter最新記事'),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.of(context).pushNamed('/settings');
          },
        ),
      ],
      bottom: TabBar(
        controller: tabController,
        tabs: FeedCategory.values
            .map(
              (e) => Tab(
                text: e.label,
              ),
            )
            .toList(),
      ),
    );
  }

  // toolbarの高さ + tabの高さ
  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight +
            const Tab(
              text: '',
            ).preferredSize.height,
      );
}
