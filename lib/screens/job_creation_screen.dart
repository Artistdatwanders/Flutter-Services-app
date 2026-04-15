import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/job_provider.dart';

class JobCreationScreen extends StatefulWidget {
  final String selectedService;

  const JobCreationScreen({super.key, required this.selectedService});

  @override
  State<JobCreationScreen> createState() => _JobCreationScreenState();
}

class _JobCreationScreenState extends State<JobCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  DateTime _preferredDate = DateTime.now().add(const Duration(days: 1));
  String _paymentMethod = 'cod';
  bool _isLoading = false;

  static const Map<String, double> serviceRates = {
    'AC Repair': 2500.0,
    'Cleaning': 1800.0,
    'Plumbing': 2200.0,
    'Electric': 2000.0,
    'Fumigation': 3000.0,
    'Carpentry': 2800.0,
    'Painting': 2600.0,
  };

  @override
  void initState() {
    super.initState();
    _priceController.text =
        serviceRates[widget.selectedService]?.toStringAsFixed(0) ?? '';
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _preferredDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _preferredDate) {
      setState(() {
        _preferredDate = picked;
      });
    }
  }

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final jobProvider = Provider.of<JobProvider>(context, listen: false);

    if (authProvider.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await jobProvider.createJob(authProvider.token!, {
        'serviceCategory': widget.selectedService,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'preferredDate': _preferredDate.toIso8601String(),
        'paymentMethod': _paymentMethod,
        'price': double.parse(_priceController.text),
        'contactDetails': {
          'name': authProvider.user?.name ?? '',
          'phone': authProvider.user?.phone ?? '',
          'email': authProvider.user?.email,
        },
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job created successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create ${widget.selectedService} Job'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Job Description',
                  hintText: 'Describe what needs to be done...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'Enter your location',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Price',
                  hintText: 'Enter estimated price',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Preferred Date'),
                subtitle: Text(_preferredDate.toString().split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              const Text('Payment Method'),
              RadioListTile<String>(
                title: const Text('Cash on Delivery'),
                value: 'cod',
                groupValue: _paymentMethod,
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Card Payment'),
                value: 'card',
                groupValue: _paymentMethod,
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitJob,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Create Job'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}