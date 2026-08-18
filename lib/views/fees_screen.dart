import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/school_provider.dart';
import '../widgets/photo_avatar.dart';
import 'fee_payment_screen.dart';

class FeesScreen extends StatelessWidget {
  const FeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SchoolProvider>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Fee management',
            style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FeePaymentScreen()),
            ),
            icon: const Icon(Icons.add_card),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Outstanding fees',
                            style: TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 3),
                        Text('₹${p.stats.pendingFees.toStringAsFixed(0)} currently due'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text('Defaulters',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          if (p.defaulters.isEmpty)
            const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('No pending fee records.')))
          else
            ...p.defaulters.map(
              (row) {
                final name = row['student_name'] as String? ?? 'Student';
                final due = (row['due_amount'] as num?)?.toDouble() ?? 0;
                return Card(
                  margin: const EdgeInsets.only(bottom: 9),
                  child: ListTile(
                    leading: PhotoAvatar(path: row['photo_path'] as String?, fallbackText: name),
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text('${row['month_year']} • Due ₹${due.toStringAsFixed(0)}'),
                    trailing: FilledButton.icon(
                      onPressed: (row['whatsapp_number'] as String? ?? '').isEmpty
                          ? null
                          : () async {
                              final ok = await p.sendFeeReminder(row);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(ok ? 'WhatsApp opened.' : 'WhatsApp unavailable.')),
                              );
                            },
                      icon: const Icon(Icons.chat, size: 16),
                      label: const Text('Remind'),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
