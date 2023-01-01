import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:webfeed/webfeed.dart';

final feedRepositoryProvider = Provider.autoDispose<FeedRepository>(
  (ref) => FeedRepository(ref),
);

/// データソースの隠蔽
/// 抽象化済みFeedを返す
class FeedRepository {
  // ignore: unused_field
  final Ref _ref;
  const FeedRepository(this._ref);

  Future<Feed> fetchZennFeed() async {
    final response = await Dio().get('https://zenn.dev/topics/flutter/feed');
    final rssFeed = RssFeed.parse(response.data);
    return _rssToFeed(rssFeed);
  }

  Future<Feed> fetchQiitaFeed() async {
    final response = await Dio().get('https://qiita.com/tags/flutter/feed');
    final atomFeed = AtomFeed.parse(response.data);
    return _atomToFeed(atomFeed);
  }

  Future<Feed> fetchMediumFeed() async {
    final response = await Dio().get('https://medium.com/feed/flutter-jp');
    final rssFeed = RssFeed.parse(response.data);
    return _rssToFeed(rssFeed);
  }

  /// RSSFeedをFeedに変換する
  Future<Feed> _rssToFeed(RssFeed rss) async {
    final articleList = await Future.wait(
      (rss.items ?? []).map(
        (item) async {
          final url = item.link;
          if (url == null) return FeedArticle.rss(item, null);
          final imageUrl = await _fetchImageUrl(
            url,
          );
          return FeedArticle.rss(item, imageUrl);
        },
      ),
    );

    return Feed(
      articleList: articleList,
      updatedAt: _parseRfc822(rss.lastBuildDate ?? '') ?? DateTime.now(),
    );
  }

  /// AtomFeedをFeedに変換する
  Future<Feed> _atomToFeed(AtomFeed atom) async {
    final articleList = await Future.wait(
      (atom.items ?? []).map(
        (entry) async {
          final url = entry.links?.first.href;
          if (url == null) return FeedArticle.atom(entry, null);
          final imageUrl = await _fetchImageUrl(
            url,
          );
          return FeedArticle.atom(entry, imageUrl);
        },
      ),
    );

    return Feed(
      articleList: articleList,
      updatedAt: atom.updated ?? DateTime.now(),
    );
  }

  /// 記事URLからOGP画像を取得する
  Future<String?> _fetchImageUrl(String articleUrl) async {
    final metadata = await MetadataFetch.extract(articleUrl);
    return metadata?.image;
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
  const FeedArticle._(
    this.title,
    this.url,
    this.publishedAt,
    this.imageUrl,
  );

  factory FeedArticle.rss(RssItem item, String? imageUrl) {
    return FeedArticle._(
      item.title,
      item.link,
      item.pubDate,
      imageUrl,
    );
  }

  factory FeedArticle.atom(AtomItem item, String? imageUrl) {
    return FeedArticle._(
      item.title,
      item.links?.firstOrNull?.href,
      DateTime.tryParse(item.published ?? ''),
      imageUrl,
    );
  }

  /// 経過時間
  String get elapsedTime {
    final now = DateTime.now();
    final diff = now.difference(publishedAt ?? now);
    if (diff.inDays > 0) {
      return '${diff.inDays}日前';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}時間前';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}分前';
    } else {
      return 'たった今';
    }
  }
}

const _months = {
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

/// RFC822の日付をパースする
/// https://stackoverflow.com/questions/62289404/parse-rfc-822-date-and-make-timezones-work
DateTime? _parseRfc822(String input) {
  input = input.replaceFirst('GMT', '+0000');

  final splits = input.split(' ');

  final splitYear = splits[3];

  final splitMonth = _months[splits[2]];
  if (splitMonth == null) return null;

  var splitDay = splits[1];
  if (splitDay.length == 1) {
    splitDay = '0$splitDay';
  }

  final splitTime = splits[4], splitZone = splits[5];

  var reformatted = '$splitYear-$splitMonth-$splitDay $splitTime $splitZone';

  return DateTime.tryParse(reformatted);
}
