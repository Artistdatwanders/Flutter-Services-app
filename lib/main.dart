import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/job_provider.dart';
import 'screens/job_creation_screen.dart';
import 'models/service.dart';

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
        home: const MainNavigation(),
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
  bool _isProviderMode = false;

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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isProviderMode ? 'Provider Panel' : 'HandyHelp'),
        actions: [
          // Role Toggle for Demo Purposes
          Row(
            children: [
              Text(_isProviderMode ? 'Pro' : 'User', style: const TextStyle(fontSize: 12)),
              Switch(
                value: _isProviderMode,
                onChanged: (val) => setState(() {
                  _isProviderMode = val;
                  _selectedIndex = 0; // Reset index when switching roles
                }),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _isProviderMode ? _providerPages : _consumerPages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF1A56DB),
        unselectedItemColor: Colors.grey,
        items: _isProviderMode
            ? const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Stats'),
                BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Leads'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
              ]
            : const [
                BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
                BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Bookings'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
              ],
      ),
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
              ),

              // Categories Grid
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text("All Services", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    gradient: const LinearGradient(colors: [Color(0xFF1A56DB), Color(0xFF1E40AF)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Summer AC Special", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      Text("Get 20% off on complete AC servicing", style: TextStyle(color: Colors.white70)),
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
      case 'ac_repair':
        icon = Icons.ac_unit;
        break;
      case 'cleaning':
        icon = Icons.cleaning_services;
        break;
      case 'plumbing':
        icon = Icons.plumbing;
        break;
      case 'electric':
        icon = Icons.electric_bolt;
        break;
      case 'fumigation':
        icon = Icons.pest_control;
        break;
      case 'carpentry':
        icon = Icons.carpenter;
        break;
      case 'painting':
        icon = Icons.format_paint;
        break;
      default:
        icon = Icons.more_horiz;
    }

    return ElevatedButton(
      onPressed: () {
        // Navigate to job creation with selected service
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
        padding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Icon(icon),
          const SizedBox(height: 4),
          Text(service.name, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
            child: ListTile(
              leading: const Icon(Icons.circle, color: Colors.green),
              title: const Text("Status: Online"),
              subtitle: const Text("Receiving jobs in Clifton & DHA"),
              trailing: Switch(value: true, onChanged: (v) {}),
            ),
          ),
          const SizedBox(height: 20),
          
          const Text("Earnings Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildStatCard("Today", "PKR 4,500", Colors.blue),
              const SizedBox(width: 12),
              _buildStatCard("This Week", "PKR 28,200", Colors.green),
            ],
          ),
          
          const SizedBox(height: 24),
          const Text("Recent Performance", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    if (authProvider.token != null) {
      jobProvider.loadLeads(authProvider.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JobProvider>(
      builder: (context, jobProvider, child) {
        if (jobProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (jobProvider.leads.isEmpty) {
          return const Center(child: Text('No job leads available'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: jobProvider.leads.length,
          itemBuilder: (context, index) {
            final job = jobProvider.leads[index];
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "NEW",
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
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Location: ${job.location}",
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      "Description: ${job.description}",
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final authProvider = Provider.of<AuthProvider>(context, listen: false);
                              try {
                                await jobProvider.declineJob(authProvider.token!, job.id);
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
                              final authProvider = Provider.of<AuthProvider>(context, listen: false);
                              try {
                                await jobProvider.acceptJob(authProvider.token!, job.id);
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
      },
    );
  }
}

// --- PLACEHOLDER PAGES ---
class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text("Active and Past Bookings"));
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const UserAccountsDrawerHeader(
          accountName: Text("Ahmed Khan"),
          accountEmail: Text("+92 300 1234567"),
          currentAccountPicture: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, color: Color(0xFF1A56DB))),
          decoration: BoxDecoration(color: Color(0xFF1A56DB)),
        ),
        ListTile(leading: const Icon(Icons.verified_user), title: const Text("Verification Status"), trailing: const Text("Verified", style: TextStyle(color: Colors.green))),
        const ListTile(leading: const Icon(Icons.payment), title: const Text("Payment Methods")),
        const ListTile(leading: const Icon(Icons.security), title: const Text("Safety Settings (SOS)")),
        const ListTile(leading: const Icon(Icons.help_outline), title: const Text("Support & Dispute Resolution")),
        const ListTile(leading: const Icon(Icons.logout), title: const Text("Logout")),
      ],
    );
  }
}