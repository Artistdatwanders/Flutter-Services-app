class User {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String role;
  final String location;
  final double rating;
  final bool isOnline;

  User({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    required this.location,
    required this.rating,
    required this.isOnline,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      role: json['role'],
      location: json['location'],
      rating: (json['rating'] ?? 0).toDouble(),
      isOnline: json['isOnline'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'location': location,
      'rating': rating,
      'isOnline': isOnline,
    };
  }
}