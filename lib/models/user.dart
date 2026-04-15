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
      // 1. Safe ID mapping
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      
      // 2. Add '??' fallbacks to EVERY non-nullable string
      name: json['name'] ?? 'Unknown User',
      phone: json['phone'] ?? 'No Phone',
      role: json['role'] ?? 'consumer', // This was likely the one crashing!
      location: json['location'] ?? 'No Location',
      
      // 3. Email is already nullable (String?), so this is fine
      email: json['email'], 
      
      // 4. Numbers and Booleans need safe defaults too
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