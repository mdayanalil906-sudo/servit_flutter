class Category {
  final String id;
  final String name;
  final String icon;
  final String iconUrl;

  Category({
    required this.id,
    required this.name,
    this.icon = '',
    this.iconUrl = '',
  });

  factory Category.fromMap(Map<String, dynamic> map, String id) {
    return Category(
      id: id,
      name: map['name'] ?? '',
      icon: map['icon'] ?? '',
      iconUrl: map['iconUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'iconUrl': iconUrl,
    };
  }
}
