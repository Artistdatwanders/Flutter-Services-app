import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/job.dart';
import '../models/service.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  // Auth methods
  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    String? email,
    required String password,
    required String role,
    required String location,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'phone': phone,
        'email': email,
        'password': password,
        'role': role,
        'location': location,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  // User methods
  Future<User> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/profile'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<User> updateProfile(String token, Map<String, dynamic> updates) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/profile'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
      body: jsonEncode(updates),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  // Job methods
  Future<Job> createJob(String token, Map<String, dynamic> jobData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/jobs'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
      body: jsonEncode(jobData),
    );

    if (response.statusCode == 200) {
      return Job.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<List<Job>> getJobs(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/jobs'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jobsJson = jsonDecode(response.body);
      return jobsJson.map((json) => Job.fromJson(json)).toList();
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<List<Job>> getJobLeads(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/jobs/leads'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jobsJson = jsonDecode(response.body);
      return jobsJson.map((json) => Job.fromJson(json)).toList();
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<Job> acceptJob(String token, String jobId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/jobs/$jobId/accept'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
    );

    if (response.statusCode == 200) {
      return Job.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<Job> declineJob(String token, String jobId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/jobs/$jobId/decline'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
    );

    if (response.statusCode == 200) {
      return Job.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<Job> completeJob(String token, String jobId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/jobs/$jobId/complete'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
    );

    if (response.statusCode == 200) {
      return Job.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  // Service methods
  Future<List<Service>> getServices() async {
    final response = await http.get(Uri.parse('$baseUrl/services'));

    if (response.statusCode == 200) {
      final List<dynamic> servicesJson = jsonDecode(response.body);
      return servicesJson.map((json) => Service.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load services');
    }
  }
}