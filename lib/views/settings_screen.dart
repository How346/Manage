import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/school_provider.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController school;

  @override
  void initState() {
    super.initState();
    school = TextEditingController(text: context.read<SchoolProvider>().schoolName);
  }

  @override
  void dispose() {
    school.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.read<SchoolProvider>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('School profile', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  TextField(controller: school, decoration: const InputDecoration(labelText: 'School name')),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: () {
                      p.schoolName = school.text.trim().isEmpty ? 'My School' : school.text.trim();
                      p.notifyListeners();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('School name updated.')));
                    },
                    child: const Text('Save school name'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.notifications_active),
                  title: Text('Local reminders'),
                  subtitle: Text('Notifications are generated on this device.'),
                ),
                ListTile(
                  leading: const Icon(Icons.delete_sweep),
                  title: const Text('Cancel scheduled reminders'),
                  onTap: () async {
                    await NotificationService.instance.cancelAll();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Scheduled notifications cancelled.')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                'Privacy: the app does not include a cloud backend. SQLite records and selected images are stored in the app sandbox. WhatsApp is opened only when you explicitly request a message.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
