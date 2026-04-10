import 'package:flutter/material.dart';
import '../models/job.dart';
import '../models/service.dart';
import '../services/api_service.dart';

class JobProvider with ChangeNotifier {
  List<Job> _jobs = [];
  List<Job> _leads = [];
  List<Service> _services = [];
  bool _isLoading = false;

  List<Job> get jobs => _jobs;
  List<Job> get leads => _leads;
  List<Service> get services => _services;
  bool get isLoading => _isLoading;

  final ApiService _apiService = ApiService();

  Future<void> loadServices() async {
    _isLoading = true;
    notifyListeners();

    try {
      _services = await _apiService.getServices();
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadJobs(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      _jobs = await _apiService.getJobs(token);
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadLeads(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      _leads = await _apiService.getJobLeads(token);
    } catch (e) {
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
        _leads[index] = job;
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
}