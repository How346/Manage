import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/school_provider.dart';
import '../widgets/photo_avatar.dart';

class BirthdayScreen extends StatelessWidget {
  const BirthdayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SchoolProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text("Today's birthdays")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (p.birthdays.isEmpty)
            const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('No birthdays today.'))),
          ...p.birthdays.map(
            (s) => Card(
              child: ListTile(
                leading: PhotoAvatar(path: s.photoPath, fallbackText: s.name),
                title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text('${s.standardClass} • ${s.dob}'),
                trailing: FilledButton(
                  onPressed: s.whatsappNumber.isEmpty
                      ? null
                      : () async {
                          final ok = await p.sendBirthdayWish(s);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(ok ? 'WhatsApp opened.' : 'Could not open WhatsApp.')),
                          );
                        },
                  child: const Text('Wish'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
