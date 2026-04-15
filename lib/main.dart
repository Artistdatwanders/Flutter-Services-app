import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/job_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/job_creation_screen.dart';
import 'models/service.dart';
import 'models/job.dart';

void main() {
  runApp(const HandymanApp());
}

class HandymanApp extends StatelessWidget {
  const HandymanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => JobProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'HandyHelp Service App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1A56DB),
            primary: const Color(0xFF1A56DB),
            secondary: const Color(0xFF10B981),
          ),
          fontFamily: 'Inter',
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return authProvider.isAuthenticated
                ? const MainNavigation()
                : const AuthScreen();
          },
        ),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // View Switching Logic
  final List<Widget> _consumerPages = [
    const HomePage(),
    const BookingsPage(),
    const ProfilePage(),
  ];

  final List<Widget> _providerPages = [
    const ProviderDashboard(),
    const ProviderLeads(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final isProvider = authProvider.user?.role == 'provider';
        return Scaffold(
          appBar: AppBar(
            title: Text(isProvider ? 'Provider Panel' : 'HandyHelp'),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {},
              ),
            ],
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: isProvider ? _providerPages : _consumerPages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            selectedItemColor: const Color(0xFF1A56DB),
            unselectedItemColor: Colors.grey,
            items: isProvider
                ? const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.dashboard),
                      label: 'Stats',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.work),
                      label: 'Leads',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'Account',
                    ),
                  ]
                : const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.search),
                      label: 'Explore',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.calendar_today),
                      label: 'Bookings',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'Profile',
                    ),
                  ],
          ),
        );
      },
    );
  }
}

// --- CONSUMER: HOME PAGE ---
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    jobProvider.loadServices();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JobProvider>(
      builder: (context, jobProvider, child) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Geolocation Banner
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade50,
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Serving: DHA Phase 6, Karachi",
                        style: TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(onPressed: () {}, child: const Text("Change")),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search for AC Repair, Cleaning...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
              ),

              // Categories Grid
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "All Services",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              if (jobProvider.services.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  childAspectRatio: 0.8,
                  padding: const EdgeInsets.all(16),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  children: jobProvider.services.map((service) {
                    return _buildCategoryItem(context, service);
                  }).toList(),
                ),

              // Promotional Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A56DB), Color(0xFF1E40AF)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Summer AC Special",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Get 20% off on complete AC servicing",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

 Widget _buildCategoryItem(BuildContext context, Service service) {
  IconData icon;
  switch (service.icon) {
    case 'ac_repair': icon = Icons.ac_unit; break;
    case 'cleaning': icon = Icons.cleaning_services; break;
    case 'plumbing': icon = Icons.plumbing; break;
    case 'electric': icon = Icons.electric_bolt; break;
    case 'fumigation': icon = Icons.pest_control; break;
    case 'carpentry': icon = Icons.carpenter; break;
    case 'painting': icon = Icons.format_paint; break;
    default: icon = Icons.more_horiz;
  }

  return ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JobCreationScreen(selectedService: service.name),
        ),
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.grey.shade100,
      foregroundColor: Colors.blue.shade800,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min, // Added: Keeps the column compact
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Flexible( // Changed from Expanded to Flexible
          child: Text(
            service.name,
            style: const TextStyle(fontSize: 10, height: 1.1), // height 1.1 tightens line spacing
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    ),
  );
}
}

// --- PROVIDER: DASHBOARD ---
class ProviderDashboard extends StatelessWidget {
  const ProviderDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Availability Toggle
          Card(
            elevation: 0,
            color: Colors.grey.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              leading: const Icon(Icons.circle, color: Colors.green),
              title: const Text("Status: Online"),
              subtitle: const Text("Receiving jobs in Clifton & DHA"),
              trailing: Switch(value: true, onChanged: (v) {}),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            "Earnings Summary",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildStatCard("Today", "PKR 4,500", Colors.blue),
              const SizedBox(width: 12),
              _buildStatCard("This Week", "PKR 28,200", Colors.green),
            ],
          ),

          const SizedBox(height: 24),
          const Text(
            "Recent Performance",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const ListTile(
            leading: Icon(Icons.star, color: Colors.amber),
            title: Text("4.9 Rating"),
            subtitle: Text("Based on 124 completed jobs"),
          ),
          const ListTile(
            leading: Icon(Icons.timer, color: Colors.blue),
            title: Text("98% On-Time"),
            subtitle: Text("Excellent punctuality record"),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// --- PROVIDER: LEADS ---
class ProviderLeads extends StatefulWidget {
  const ProviderLeads({super.key});

  @override
  State<ProviderLeads> createState() => _ProviderLeadsState();
}

class _ProviderLeadsState extends State<ProviderLeads> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      if (authProvider.token != null && authProvider.user != null) {
        jobProvider.loadLeads(authProvider.token!, authProvider.user!.id);
        jobProvider.loadJobs(authProvider.token!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JobProvider>(
      builder: (context, jobProvider, child) {
        if (jobProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final availableLeads = jobProvider.leads;
        final myActiveJobs = jobProvider.jobs
            .where((job) => job.status == 'accepted')
            .toList();
        final myPastJobs = jobProvider.jobs
            .where((job) => job.status == 'completed')
            .toList();

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Job Management'),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Available Leads'),
                  Tab(text: 'Active Jobs'),
                  Tab(text: 'Past Jobs'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildLeadsList(availableLeads, 'No job leads available'),
                _buildJobsList(myActiveJobs, 'No active jobs'),
                _buildJobsList(myPastJobs, 'No completed jobs'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeadsList(List<Job> leads, String emptyMessage) {
    if (leads.isEmpty) {
      return Center(child: Text(emptyMessage));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: leads.length,
      itemBuilder: (context, index) {
        final job = leads[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: const Text(
                        "NEW LEAD",
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      "Est: PKR 1,500 - 2,500",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  job.serviceCategory,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Location: ${job.location}",
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                Text(
                  "Description: ${job.description}",
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                Text(
                  "Preferred Date: ${job.preferredDate.day}/${job.preferredDate.month}/${job.preferredDate.year}",
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                if (job.consumer != null) ...[
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        "Client: ${job.consumer!.name}",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.phone, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(job.consumer!.phone ?? 'N/A'),
                    ],
                  ),
                ],
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final authProvider = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );
                          final jobProvider = Provider.of<JobProvider>(
                            context,
                            listen: false,
                          );
                          try {
                            await jobProvider.declineJob(
                              authProvider.token!,
                              job.id,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Job declined')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        },
                        child: const Text("Decline"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A56DB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                        onPressed: () async {
                          final authProvider = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );
                          final jobProvider = Provider.of<JobProvider>(
                            context,
                            listen: false,
                          );
                          try {
                            await jobProvider.acceptJob(
                              authProvider.token!,
                              job.id,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Job accepted!')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        },
                        child: const Text("Accept Job"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildJobsList(List<Job> jobs, String emptyMessage) {
    if (jobs.isEmpty) {
      return Center(child: Text(emptyMessage));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(job.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getStatusColor(job.status).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        job.status.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(job.status),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${job.preferredDate.day}/${job.preferredDate.month}/${job.preferredDate.year}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  job.serviceCategory,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Location: ${job.location}",
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                Text(
                  "Description: ${job.description}",
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                if (job.consumer != null) ...[
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        "Client: ${job.consumer!.name}",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.phone, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(job.consumer!.phone ?? 'N/A'),
                    ],
                  ),
                ],
                if (job.status == 'accepted') ...[
                  const Divider(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      // For providers, they might need to mark job as completed
                      // But according to backend, only consumers can complete jobs
                      // So maybe show contact info or status
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Contact client to complete the job'),
                        ),
                      );
                    },
                    child: const Text('Contact Client'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'declined':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// --- CONSUMER: BOOKINGS PAGE ---
class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    if (authProvider.token != null) {
      jobProvider.loadJobs(authProvider.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JobProvider>(
      builder: (context, jobProvider, child) {
        if (jobProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final activeJobs = jobProvider.jobs
            .where((job) => job.status == 'pending' || job.status == 'accepted')
            .toList();
        final pastJobs = jobProvider.jobs
            .where(
              (job) => job.status == 'completed' || job.status == 'declined',
            )
            .toList();

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('My Bookings'),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Active'),
                  Tab(text: 'Past'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildJobsList(activeJobs, 'No active bookings'),
                _buildJobsList(pastJobs, 'No past bookings'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildJobsList(List<Job> jobs, String emptyMessage) {
    if (jobs.isEmpty) {
      return Center(child: Text(emptyMessage));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(job.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getStatusColor(job.status).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        job.status.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(job.status),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${job.preferredDate.day}/${job.preferredDate.month}/${job.preferredDate.year}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  job.serviceCategory,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Location: ${job.location}",
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                Text(
                  "Description: ${job.description}",
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                if (job.provider != null) ...[
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        "Provider: ${job.provider!.name}",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.phone, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(job.provider!.phone ?? 'N/A'),
                    ],
                  ),
                  if (job.provider!.rating != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${job.provider!.rating!.toStringAsFixed(1)} rating',
                        ),
                      ],
                    ),
                  ],
                ],
                if (job.status == 'accepted') ...[
                  const Divider(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      final jobProvider = Provider.of<JobProvider>(
                        context,
                        listen: false,
                      );
                      if (authProvider.token != null) {
                        try {
                          await jobProvider.completeJob(
                            authProvider.token!,
                            job.id,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Job marked as completed'),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      }
                    },
                    child: const Text('Mark as Completed'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'declined':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showDescription(
    BuildContext context,
    String title,
    String description,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showSafetySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Safety Toolkit",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              // 1. Emergency Call
              ListTile(
                leading: const Icon(Icons.emergency, color: Colors.red),
                title: const Text(
                  "Call Emergency Services",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text("Dial 911 immediately"),
                onTap: () {
                  // You would use the 'url_launcher' package here to dial
                },
              ),

              // 2. Share Location
              ListTile(
                leading: const Icon(Icons.share_location, color: Colors.blue),
                title: const Text("Share Live Location"),
                subtitle: const Text(
                  "Send your current trip/job location to contacts",
                ),
                onTap: () {
                  /* Logic for sharing location */
                },
              ),

              // 3. Trusted Contacts
              ListTile(
                leading: const Icon(Icons.people_outline, color: Colors.green),
                title: const Text("Notify Trusted Contacts"),
                subtitle: const Text("Alert your pre-saved emergency contacts"),
                onTap: () {
                  /* Logic to send SMS/Push to contacts */
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        if (user == null) {
          return const Center(child: Text('No user data'));
        }

        return ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user.name),
              accountEmail: Text(user.phone ?? 'No phone'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: const Color(0xFF1A56DB)),
              ),
              decoration: const BoxDecoration(color: Color(0xFF1A56DB)),
            ),
            ListTile(
              leading: const Icon(Icons.badge),
              title: const Text("Role"),
              trailing: Text(
                user.role == 'provider' ? 'Service Provider' : 'Customer',
              ),
            ),
            if (user.email != null)
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text("Email"),
                trailing: Text(user.email!),
              ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text("Location"),
              trailing: Text(user.location),
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text("Rating"),
              trailing: Text(user.rating.toStringAsFixed(1)),
            ),
            if (user.role == 'provider')
              ListTile(
                leading: Icon(
                  user.isOnline ? Icons.circle : Icons.circle_outlined,
                  color: user.isOnline ? Colors.green : Colors.grey,
                ),
                title: const Text("Online Status"),
                trailing: Text(user.isOnline ? 'Online' : 'Offline'),
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.verified_user),
              title: const Text("Verification Status"),
              trailing: const Text(
                "Verified",
                style: TextStyle(color: Colors.green),
              ),
              onTap: () => _showDescription(
                context,
                "Verification Status",
                "Your account has been verified by our team. This ensures trust within our community.",
              ),
            ),
            // const ListTile(
            //   leading: Icon(Icons.payment),
            //   title: Text("Payment Methods"),
            // ),
            ListTile(
              leading: const Icon(
                Icons.security,
                color: Colors.redAccent,
              ), // Red accent for safety
              title: const Text("Safety Settings (SOS)"),
              onTap: () => _showSafetySheet(context),
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text("Support & Dispute Resolution"),
              onTap: () => _showDescription(
                context,
                "Support",
                "Need help? You can reach our 24/7 support team via the email servicehelp@example.com. or Whatsapp 0123456789",
              ),
            ),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {
                authProvider.logout();
              },
            ),
          ],
        );
      },
    );
  }
}
