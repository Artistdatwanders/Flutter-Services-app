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
    return Job(
      id: json['_id'] ?? json['id'],
      consumerId: json['consumerId'],
      providerId: json['providerId'],
      serviceCategory: json['serviceCategory'],
      description: json['description'],
      location: json['location'],
      preferredDate: DateTime.parse(json['preferredDate']),
      status: json['status'],
      contactDetails: json['contactDetails'],
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      price: (json['price'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      consumer: json['consumer'] != null ? User.fromJson(json['consumer']) : null,
      provider: json['provider'] != null ? User.fromJson(json['provider']) : null,
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