/// フィードのカテゴリー
enum FeedCategory {
  zenn('Zenn'),
  qiita('Qiita'),
  medium('Medium');

  final String label;
  const FeedCategory(this.label);
}
