class HistoryContent {
  HistoryContent({
    required this.id,
    required this.type,
    required this.publishedDate,
    required this.title,
    required this.pictureUrl,
    required this.bigPictureUrl,
    required this.url,
  });
  HistoryContent.fromJson(Map<String, dynamic> j)
      : id = j['id'].toString(),
        publishedDate = DateTime.parse(j['publishedDate'].toString()),
        type = NotificationType.values
            .firstWhere((e) => e.name == j['type'].toString()),
        title = j['title'].toString(),
        pictureUrl =
            (j['pictureUrl'] == null) ? null : j['pictureUrl'].toString(),
        bigPictureUrl =
            (j['bigPictureUrl'] == null) ? null : j['bigPictureUrl'].toString(),
        url = j['url'].toString();

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'publishedDate': publishedDate.toIso8601String(),
        'title': title,
        'type': type.name,
        if (pictureUrl != null) 'pictureUrl': pictureUrl,
        if (bigPictureUrl != null) 'bigPictureUrl': bigPictureUrl,
        'url': url,
      };

  /// SHA-256
  final String id;

  /// Type
  final NotificationType  type;
  ///  配信時刻
  final DateTime publishedDate;

  /// smallPic
  final String? pictureUrl;

  /// bigPic
  final String? bigPictureUrl;

  /// タイトル
  final String title;

  ///

  /// Payload url
  final String url;
}

enum NotificationType {
  eew,
  vxse51,
  vxse52,
  vxse53,
  vxse56,
  vxse60,
  vxse61,
  vxse62,
  vyse50,
  vyse51,
  vyse52,
  vtse41,
  vtse51,
  vtse52,
  wepa60,
  vzse40,
}
