import 'user.dart';

class Job {
  final String id;
  final String consumerId;
  final String? providerId;
  final String serviceCategory;
  final String description;
  final String location;
  final DateTime preferredDate;
  final String status;
  final Map<String, dynamic>? contactDetails;
  final String paymentMethod;
  final String paymentStatus;
  final double price;
  final DateTime createdAt;
  final User? consumer;
  final User? provider;

  Job({
    required this.id,
    required this.consumerId,
    this.providerId,
    required this.serviceCategory,
    required this.description,
    required this.location,
    required this.preferredDate,
    required this.status,
    this.contactDetails,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.price,
    required this.createdAt,
    this.consumer,
    this.provider,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    // Helper function: Extracts the string ID regardless of whether 
    // Mongoose sent a plain string or a populated JSON object.
    String getObjectId(dynamic field) {
      if (field is Map<String, dynamic>) {
        return field['_id']?.toString() ?? field['id']?.toString() ?? '';
      }
      return field?.toString() ?? '';
    }

    return Job(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      
      // Safely extract just the string ID for these fields
      consumerId: getObjectId(json['consumerId']),
      providerId: json['providerId'] != null ? getObjectId(json['providerId']) : null,
      
      // Standard string fields with safe fallbacks in case of nulls
      serviceCategory: json['serviceCategory'] ?? 'Unknown',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      
      // Safely parse dates
      preferredDate: json['preferredDate'] != null 
          ? DateTime.parse(json['preferredDate']) 
          : DateTime.now(),
          
      status: json['status'] ?? 'pending',
      contactDetails: json['contactDetails'],
      paymentMethod: json['paymentMethod'] ?? 'cod',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      price: (json['price'] ?? 0).toDouble(),
      
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
          
      // Populate the nested User objects if the backend sent them
      consumer: json['consumerId'] is Map<String, dynamic> 
          ? User.fromJson(json['consumerId']) 
          : null,
      provider: json['providerId'] is Map<String, dynamic> 
          ? User.fromJson(json['providerId']) 
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'consumerId': consumerId,
      'providerId': providerId,
      'serviceCategory': serviceCategory,
      'description': description,
      'location': location,
      'preferredDate': preferredDate.toIso8601String(),
      'status': status,
      'contactDetails': contactDetails,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'price': price,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}