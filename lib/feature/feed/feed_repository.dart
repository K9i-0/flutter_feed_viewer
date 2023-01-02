import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_feed_viewer/local/shared_preferences.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:webfeed/webfeed.dart';

final feedRepositoryProvider = Provider.autoDispose<FeedRepository>(
  (ref) => FeedRepository(ref),
);

final atomFeedProviderFamily = Provider.family.autoDispose<AtomFeed, String>(
  (ref, xmlString) => AtomFeed.parse(xmlString),
);

final rssFeedProviderFamily = Provider.family.autoDispose<RssFeed, String>(
  (ref, xmlString) => RssFeed.parse(xmlString),
);

final dioProvider = Provider.autoDispose<Dio>(
  (ref) => Dio(),
);

/// 記事URLからOGP画像URLを取得する
final ogpImageUrlProviderFamily =
    FutureProvider.family.autoDispose<String?, String>(
  (ref, articleUrl) =>
      MetadataFetch.extract(articleUrl).then((value) => value?.image),
);

typedef Rfc822Parser = DateTime? Function(String rfc822String);

/// RFC822の日付をパースする
/// https://stackoverflow.com/questions/62289404/parse-rfc-822-date-and-make-timezones-work
final rfc822ParserProvider = Provider<Rfc822Parser>(
  (ref) {
    const months = {
      'Jan': '01',
      'Feb': '02',
      'Mar': '03',
      'Apr': '04',
      'May': '05',
      'Jun': '06',
      'Jul': '07',
      'Aug': '08',
      'Sep': '09',
      'Oct': '10',
      'Nov': '11',
      'Dec': '12',
    };

    return (String input) {
      input = input.replaceFirst('GMT', '+0000');

      final splits = input.split(' ');

      final splitYear = splits[3];

      final splitMonth = months[splits[2]];
      if (splitMonth == null) return null;

      var splitDay = splits[1];
      if (splitDay.length == 1) {
        splitDay = '0$splitDay';
      }

      final splitTime = splits[4], splitZone = splits[5];

      var reformatted =
          '$splitYear-$splitMonth-$splitDay $splitTime $splitZone';

      return DateTime.tryParse(reformatted);
    };
  },
);

typedef IsNewChecker = bool Function({
  required DateTime? publishedAt,
  required DateTime? lastUpdatedAt,
});

/// 記事の新着判定
final isNewCheckerProvider = Provider<IsNewChecker>(
  (ref) {
    return ({
      required DateTime? publishedAt,
      required DateTime? lastUpdatedAt,
    }) {
      // 初回なので、全て新しい記事として扱う
      if (lastUpdatedAt == null) {
        return true;
      }

      // publishedAtがnullの場合は新しい記事として扱わない
      if (publishedAt == null) {
        return false;
      }

      return publishedAt.isAfter(lastUpdatedAt);
    };
  },
);

/// データソースの隠蔽
/// 抽象化済みFeedを返す
class FeedRepository {
  // ignore: unused_field
  final Ref _ref;
  const FeedRepository(this._ref);

  Future<Feed> fetchZennFeed() async {
    // 前回取得時の最終更新日時を取得
    const lastUpdatedAtKey = SharedPreferencesKeys.lastZennFeedUpdatedAt;
    final lastUpdatedAt = _getLastUpdatedAt(lastUpdatedAtKey);

    // ZennのRSSを取得
    final response = await _ref
        .read(dioProvider)
        .get('https://zenn.dev/topics/flutter/feed');
    final rssFeed = _ref.read(rssFeedProviderFamily(response.data));
    final feed = await _rssToFeed(rssFeed, lastUpdatedAt);

    // 最終更新日時を保存
    await _setLastUpdatedAt(lastUpdatedAtKey, feed.updatedAt);

    return feed;
  }

  Future<Feed> fetchQiitaFeed() async {
    const lastUpdatedAtKey = SharedPreferencesKeys.lastQiitaFeedUpdatedAt;
    final lastUpdatedAt = _getLastUpdatedAt(lastUpdatedAtKey);

    final response =
        await _ref.read(dioProvider).get('https://qiita.com/tags/flutter/feed');
    final atomFeed = _ref.read(atomFeedProviderFamily(response.data));
    final feed = await _atomToFeed(atomFeed, lastUpdatedAt);

    await _setLastUpdatedAt(lastUpdatedAtKey, feed.updatedAt);

    return feed;
  }

  Future<Feed> fetchMediumFeed() async {
    const lastUpdatedAtKey = SharedPreferencesKeys.lastMediumFeedUpdatedAt;
    final lastUpdatedAt = _getLastUpdatedAt(lastUpdatedAtKey);

    final response =
        await _ref.read(dioProvider).get('https://medium.com/feed/flutter-jp');
    final rssFeed = _ref.read(rssFeedProviderFamily(response.data));
    final feed = await _rssToFeed(rssFeed, lastUpdatedAt);

    await _setLastUpdatedAt(lastUpdatedAtKey, feed.updatedAt);

    return feed;
  }

  /// RSSFeedをFeedに変換する
  Future<Feed> _rssToFeed(RssFeed rss, DateTime? lastUpdatedAt) async {
    final isNewChecker = _ref.read(isNewCheckerProvider);
    final articleList = await Future.wait(
      (rss.items ?? []).map(
        (item) async {
          final url = item.link;
          if (url == null) {
            return FeedArticle.rss(item, null, lastUpdatedAt, isNewChecker);
          }
          final imageUrl =
              await _ref.read(ogpImageUrlProviderFamily(url).future);
          return FeedArticle.rss(item, imageUrl, lastUpdatedAt, isNewChecker);
        },
      ),
    );
    final rfc822Parser = _ref.read(rfc822ParserProvider);

    return Feed(
      articleList: articleList,
      updatedAt: rfc822Parser(rss.lastBuildDate ?? '') ?? DateTime.now(),
    );
  }

  /// AtomFeedをFeedに変換する
  Future<Feed> _atomToFeed(AtomFeed atom, DateTime? lastUpdatedAt) async {
    final isNewChecker = _ref.read(isNewCheckerProvider);
    final articleList = await Future.wait(
      (atom.items ?? []).map(
        (entry) async {
          final url = entry.links?.firstOrNull?.href;
          if (url == null) {
            return FeedArticle.atom(entry, null, lastUpdatedAt, isNewChecker);
          }
          final imageUrl =
              await _ref.read(ogpImageUrlProviderFamily(url).future);
          return FeedArticle.atom(entry, imageUrl, lastUpdatedAt, isNewChecker);
        },
      ),
    );

    return Feed(
      articleList: articleList,
      updatedAt: atom.updated ?? DateTime.now(),
    );
  }

  DateTime? _getLastUpdatedAt(SharedPreferencesKeys key) {
    final lastFetchTimeString =
        _ref.read(sharedPreferencesProvider).getString(key.name);
    if (lastFetchTimeString == null) return null;

    return DateTime.tryParse(lastFetchTimeString);
  }

  Future<void> _setLastUpdatedAt(
    SharedPreferencesKeys key,
    DateTime updatedAt,
  ) async {
    await _ref.read(sharedPreferencesProvider).setString(
          key.name,
          updatedAt.toIso8601String(),
        );
  }
}

/// 記事と更新日時をまとめたクラス
class Feed {
  final List<FeedArticle> articleList;
  final DateTime updatedAt;
  const Feed({
    required this.articleList,
    required this.updatedAt,
  });
}

/// 記事の抽象化
class FeedArticle {
  final String? title;
  final String? url;
  final DateTime? publishedAt;
  final String? imageUrl;
  final bool isNew;
  const FeedArticle._(
    this.title,
    this.url,
    this.publishedAt,
    this.imageUrl,
    this.isNew,
  );

  factory FeedArticle.rss(RssItem item, String? imageUrl,
      DateTime? lastUpdatedAt, IsNewChecker checker) {
    final publishedAt = item.pubDate;
    return FeedArticle._(
      item.title,
      item.link,
      publishedAt,
      imageUrl,
      checker(publishedAt: publishedAt, lastUpdatedAt: lastUpdatedAt),
    );
  }

  factory FeedArticle.atom(AtomItem item, String? imageUrl,
      DateTime? lastUpdatedAt, IsNewChecker checker) {
    final publishedAt = DateTime.tryParse(item.published ?? '');
    return FeedArticle._(
      item.title,
      item.links?.firstOrNull?.href,
      publishedAt,
      imageUrl,
      checker(publishedAt: publishedAt, lastUpdatedAt: lastUpdatedAt),
    );
  }
}
