class NewsModel {
  final String title;
  final String description;
  final String date;
  final String link;
  final String? imageUrl;

  const NewsModel({
    required this.title,
    this.description = '',
    required this.date,
    this.link = '',
    this.imageUrl,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) => NewsModel(
        title: (json['title'] ?? '').toString(),
        description: (json['description'] ?? '').toString(),
        date: (json['date'] ?? '').toString(),
        link: (json['link'] ?? '').toString(),
        imageUrl: json['imageUrl']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'date': date,
        'link': link,
        'imageUrl': imageUrl,
      };
}