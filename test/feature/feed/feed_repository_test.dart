import 'package:dio/dio.dart';
import 'package:flutter_feed_viewer/feature/feed/feed_repository.dart';
import 'package:flutter_feed_viewer/local/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webfeed/webfeed.dart';

import 'feed_repository_test.mocks.dart';

class MockResponse extends Mock implements Response {
  MockResponse._();

  factory MockResponse({
    required String data,
  }) {
    final mockResponse = MockResponse._();
    when(mockResponse.data).thenReturn(data);
    return mockResponse;
  }
}

class MockAtomFeed extends Mock implements AtomFeed {
  MockAtomFeed._();

  factory MockAtomFeed({
    required List<AtomItem> items,
    required DateTime updatedAt,
  }) {
    final mockAtomFeed = MockAtomFeed._();
    when(mockAtomFeed.items).thenReturn(items);
    when(mockAtomFeed.updated).thenReturn(updatedAt);
    return mockAtomFeed;
  }
}

class MockAtomItem extends Mock implements AtomItem {
  MockAtomItem._();

  factory MockAtomItem({
    required String title,
    required String url,
    required DateTime publishedAt,
  }) {
    final mockAtomItem = MockAtomItem._();
    when(mockAtomItem.title).thenReturn(title);
    final mockAtomLink = MockAtomLink();
    when(mockAtomLink.href).thenReturn(url);
    when(mockAtomItem.links).thenReturn([
      mockAtomLink,
    ]);
    when(mockAtomItem.published).thenReturn(publishedAt.toIso8601String());
    return mockAtomItem;
  }
}

class MockAtomLink extends Mock implements AtomLink {}

class MockRssFeed extends Mock implements RssFeed {
  MockRssFeed._();

  factory MockRssFeed({
    required List<RssItem> items,
  }) {
    final mockRssFeed = MockRssFeed._();
    when(mockRssFeed.items).thenReturn(items);
    return mockRssFeed;
  }
}

class MockRssItem extends Mock implements RssItem {
  MockRssItem._();

  factory MockRssItem({
    required String title,
    required String url,
    required DateTime publishedAt,
  }) {
    final mockRssItem = MockRssItem._();
    when(mockRssItem.title).thenReturn(title);
    when(mockRssItem.link).thenReturn(url);
    when(mockRssItem.pubDate).thenReturn(publishedAt);
    return mockRssItem;
  }
}

// Futureを返す関数をMockするためにはこうする必要がある
@GenerateMocks([Dio])
void main() {
  const testResponseData = 'testResponseData';

  const testNewArticleTitle = 'newArticleTitle';
  const testNewArticleUrl = 'newArticleUrl';
  final testNewArticlePublishedAt = DateTime(2022, 1, 1);
  const testNewArticleImageUrl = 'newArticleImageUrl';

  const testOldArticleTitle = 'oldArticleTitle';
  const testOldArticleUrl = 'oldArticleUrl';
  final testOldArticlePublishedAt = DateTime(2020, 1, 1);
  const testOldArticleImageUrl = 'oldArticleImageUrl';

  final testFeedUpdatedAt = DateTime(2023, 1, 1);

  setUp(() {
    // テスト毎にSharedPreferencesの値を初期化する
    final initDateTimeString = DateTime(2021, 1, 1).toIso8601String();
    SharedPreferences.setMockInitialValues({
      SharedPreferencesKeys.lastZennFeedUpdatedAt.name: initDateTimeString,
      SharedPreferencesKeys.lastQiitaFeedUpdatedAt.name: initDateTimeString,
      SharedPreferencesKeys.lastMediumFeedUpdatedAt.name: initDateTimeString,
    });
  });

  test('ZennFeedを取得できる', () async {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(
          await SharedPreferences.getInstance(),
        ),
        dioProvider.overrideWithValue(
          _genDio(
            url: 'https://zenn.dev/topics/flutter/feed',
            responseData: testResponseData,
          ),
        ),
        rssFeedProviderFamily(testResponseData).overrideWithValue(
          MockRssFeed(
            items: [
              MockRssItem(
                title: testNewArticleTitle,
                url: testNewArticleUrl,
                publishedAt: testNewArticlePublishedAt,
              ),
              MockRssItem(
                title: testOldArticleTitle,
                url: testOldArticleUrl,
                publishedAt: testOldArticlePublishedAt,
              ),
            ],
          ),
        ),
        ogpImageUrlProviderFamily(testNewArticleUrl).overrideWith(
          (ref) => testNewArticleImageUrl,
        ),
        ogpImageUrlProviderFamily(testOldArticleUrl).overrideWith(
          (ref) => testOldArticleImageUrl,
        ),
        rfc822ParserProvider.overrideWithValue(
          (_) => testFeedUpdatedAt,
        ),
      ],
    );

    final feed = await container.read(feedRepositoryProvider).fetchZennFeed();

    expect(feed.updatedAt, testFeedUpdatedAt);

    final newArticle = feed.articleList[0];
    _expectArticle(
      article: newArticle,
      title: testNewArticleTitle,
      url: testNewArticleUrl,
      publishedAt: testNewArticlePublishedAt,
      imageUrl: testNewArticleImageUrl,
      isNew: true,
    );

    final oldArticle = feed.articleList[1];
    _expectArticle(
      article: oldArticle,
      title: testOldArticleTitle,
      url: testOldArticleUrl,
      publishedAt: testOldArticlePublishedAt,
      imageUrl: testOldArticleImageUrl,
      isNew: false,
    );
  });

  test('QiitaFeedを取得できる', () async {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(
          await SharedPreferences.getInstance(),
        ),
        dioProvider.overrideWithValue(
          _genDio(
            url: 'https://qiita.com/tags/flutter/feed',
            responseData: testResponseData,
          ),
        ),
        atomFeedProviderFamily(testResponseData).overrideWithValue(
          MockAtomFeed(
            items: [
              MockAtomItem(
                title: testNewArticleTitle,
                url: testNewArticleUrl,
                publishedAt: testNewArticlePublishedAt,
              ),
              MockAtomItem(
                title: testOldArticleTitle,
                url: testOldArticleUrl,
                publishedAt: testOldArticlePublishedAt,
              ),
            ],
            updatedAt: testFeedUpdatedAt,
          ),
        ),
        ogpImageUrlProviderFamily(testNewArticleUrl).overrideWith(
          (ref) => testNewArticleImageUrl,
        ),
        ogpImageUrlProviderFamily(testOldArticleUrl).overrideWith(
          (ref) => testOldArticleImageUrl,
        ),
      ],
    );

    final feed = await container.read(feedRepositoryProvider).fetchQiitaFeed();

    expect(feed.updatedAt, testFeedUpdatedAt);

    final newArticle = feed.articleList[0];
    _expectArticle(
      article: newArticle,
      title: testNewArticleTitle,
      url: testNewArticleUrl,
      publishedAt: testNewArticlePublishedAt,
      imageUrl: testNewArticleImageUrl,
      isNew: true,
    );

    final oldArticle = feed.articleList[1];
    _expectArticle(
      article: oldArticle,
      title: testOldArticleTitle,
      url: testOldArticleUrl,
      publishedAt: testOldArticlePublishedAt,
      imageUrl: testOldArticleImageUrl,
      isNew: false,
    );
  });

  test('MediumFeedを取得できる', () async {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(
          await SharedPreferences.getInstance(),
        ),
        dioProvider.overrideWithValue(
          _genDio(
            url: 'https://medium.com/feed/flutter-jp',
            responseData: testResponseData,
          ),
        ),
        rssFeedProviderFamily(testResponseData).overrideWithValue(
          MockRssFeed(
            items: [
              MockRssItem(
                title: testNewArticleTitle,
                url: testNewArticleUrl,
                publishedAt: testNewArticlePublishedAt,
              ),
              MockRssItem(
                title: testOldArticleTitle,
                url: testOldArticleUrl,
                publishedAt: testOldArticlePublishedAt,
              ),
            ],
          ),
        ),
        ogpImageUrlProviderFamily(testNewArticleUrl).overrideWith(
          (ref) => testNewArticleImageUrl,
        ),
        ogpImageUrlProviderFamily(testOldArticleUrl).overrideWith(
          (ref) => testOldArticleImageUrl,
        ),
        rfc822ParserProvider.overrideWithValue(
          (_) => testFeedUpdatedAt,
        ),
      ],
    );

    final feed = await container.read(feedRepositoryProvider).fetchMediumFeed();

    expect(feed.updatedAt, testFeedUpdatedAt);

    final newArticle = feed.articleList[0];
    _expectArticle(
      article: newArticle,
      title: testNewArticleTitle,
      url: testNewArticleUrl,
      publishedAt: testNewArticlePublishedAt,
      imageUrl: testNewArticleImageUrl,
      isNew: true,
    );

    final oldArticle = feed.articleList[1];
    _expectArticle(
      article: oldArticle,
      title: testOldArticleTitle,
      url: testOldArticleUrl,
      publishedAt: testOldArticlePublishedAt,
      imageUrl: testOldArticleImageUrl,
      isNew: false,
    );
  });

  test('最終取得日時がない場合のテスト', () {
    final container = ProviderContainer();
    final isNewChecker = container.read(feedRepositoryProvider).checkIsNew;

    expect(
      isNewChecker(
        publishedAt: testNewArticlePublishedAt,
        lastUpdatedAt: null,
      ),
      true,
    );
    expect(
      isNewChecker(
        publishedAt: testOldArticlePublishedAt,
        lastUpdatedAt: null,
      ),
      true,
    );
    expect(
      isNewChecker(
        publishedAt: DateTime(0),
        lastUpdatedAt: null,
      ),
      true,
    );
    expect(
      isNewChecker(
        publishedAt: DateTime(10000),
        lastUpdatedAt: null,
      ),
      true,
    );
    expect(
      isNewChecker(
        publishedAt: null,
        lastUpdatedAt: null,
      ),
      true,
    );
  });

  test('最終取得日時があるときのテスト', () {
    final container = ProviderContainer();
    final isNewChecker = container.read(feedRepositoryProvider).checkIsNew;
    final lastUpdatedAt = DateTime(2021, 1, 1);

    expect(
      isNewChecker(
        publishedAt: testNewArticlePublishedAt,
        lastUpdatedAt: lastUpdatedAt,
      ),
      true,
    );
    expect(
      isNewChecker(
        publishedAt: testOldArticlePublishedAt,
        lastUpdatedAt: lastUpdatedAt,
      ),
      false,
    );
    expect(
      isNewChecker(
        publishedAt: DateTime(0),
        lastUpdatedAt: lastUpdatedAt,
      ),
      false,
    );
    expect(
      isNewChecker(
        publishedAt: DateTime(10000),
        lastUpdatedAt: lastUpdatedAt,
      ),
      true,
    );
    expect(
      isNewChecker(
        publishedAt: null,
        lastUpdatedAt: lastUpdatedAt,
      ),
      false,
    );
  });
}

/// 生成コードを使ってるのでfactoryの代用
MockDio _genDio({
  required String url,
  required String responseData,
}) {
  final mockDio = MockDio();
  when(mockDio.get(url)).thenAnswer(
    (_) async => MockResponse(
      data: responseData,
    ),
  );

  return mockDio;
}

/// 記事の比較をまとめた処理
void _expectArticle({
  required FeedArticle article,
  required String title,
  required String url,
  required DateTime publishedAt,
  required String imageUrl,
  required bool isNew,
}) {
  expect(article.title, title);
  expect(article.url, url);
  expect(article.publishedAt, publishedAt);
  expect(article.imageUrl, imageUrl);
  expect(article.isNew, isNew);
}
