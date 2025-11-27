class OnboardPage {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int order;

  OnboardPage({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.order,
  });

  factory OnboardPage.fromJson(Map<String, dynamic> json) {
    return OnboardPage(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'order': order,
    };
  }
}
