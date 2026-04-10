class Service {
  final String id;
  final String name;
  final String icon;
  final bool isActive;

  Service({
    required this.id,
    required this.name,
    required this.icon,
    required this.isActive,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      icon: json['icon'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'isActive': isActive,
    };
  }
}