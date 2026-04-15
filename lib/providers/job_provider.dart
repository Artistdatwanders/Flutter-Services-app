import 'package:flutter/material.dart';
import '../models/job.dart';
import '../models/service.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';

class JobProvider with ChangeNotifier {
  List<Job> _jobs = [];
  List<Job> _leads = [];
  List<Service> _services = [];
  bool _isLoading = false;
  bool _socketInitialized = false;

  List<Job> get jobs => _jobs;
  List<Job> get leads => _leads;
  List<Service> get services => _services;
  bool get isLoading => _isLoading;

  final ApiService _apiService = ApiService();
  final SocketService _socketService = SocketService();

  void initSocket(String userId) {
    if (_socketInitialized) return;
    _socketInitialized = true;
    _socketService.connect(userId);
    _socketService.on('newJob', (data) {
      // Add new job to leads if not already present
      final job = Job.fromJson(data);
      if (!_leads.any((j) => j.id == job.id)) {
        _leads.add(job);
        notifyListeners();
      }
    });

    _socketService.on('jobAccepted', (data) {
      // Update job status in jobs list
      final job = Job.fromJson(data);
      final index = _jobs.indexWhere((j) => j.id == job.id);
      if (index != -1) {
        _jobs[index] = job;
        notifyListeners();
      }
    });

    _socketService.on('jobCompleted', (data) {
      // Update job status in jobs list
      final job = Job.fromJson(data);
      final index = _jobs.indexWhere((j) => j.id == job.id);
      if (index != -1) {
        _jobs[index] = job;
        notifyListeners();
      }
    });
  }

  Future<void> loadServices() async {
    _isLoading = true;
    notifyListeners();

    try {
      _services = await _apiService.getServices();
    } catch (e, stackTrace) {
      print('🚨 ERROR IN loadServices: $e');
      print(stackTrace);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadJobs(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      _jobs = await _apiService.getJobs(token);
    } catch (e, stackTrace) {
      print('🚨 ERROR IN loadJobs: $e');
      print(stackTrace);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadLeads(String token, String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _leads = await _apiService.getJobLeads(token);
      // Initialize socket for real-time updates
      initSocket(userId);
    } catch (e, stackTrace) {
      print('🚨 ERROR IN loadLeads: $e');
      print(stackTrace);
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createJob(String token, Map<String, dynamic> jobData) async {
    try {
      final job = await _apiService.createJob(token, jobData);
      _jobs.add(job);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> acceptJob(String token, String jobId) async {
    try {
      final job = await _apiService.acceptJob(token, jobId);
      final index = _leads.indexWhere((j) => j.id == jobId);
      if (index != -1) {
        _leads.removeAt(index);
        _jobs.add(job);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> declineJob(String token, String jobId) async {
    try {
      // final job = await _apiService.declineJob(token, jobId);
      await _apiService.declineJob(token, jobId);
      _leads.removeWhere((j) => j.id == jobId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> completeJob(String token, String jobId) async {
    try {
      final job = await _apiService.completeJob(token, jobId);
      final index = _jobs.indexWhere((j) => j.id == jobId);
      if (index != -1) {
        _jobs[index] = job;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }
}