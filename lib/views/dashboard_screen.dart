import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/school_provider.dart';
import '../widgets/photo_avatar.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';
import 'student_form_screen.dart';
import 'fee_payment_screen.dart';
import 'salary_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String money(double value) => NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: 0,
      ).format(value);

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SchoolProvider>();
    return RefreshIndicator(
      onRefresh: p.refreshAll,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Good evening 👋',
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 3),
                    Text(
                      p.schoolName,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.school),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: MediaQuery.sizeOf(context).width > 700 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              StatCard(
                title: 'Students',
                value: '${p.stats.students}',
                icon: Icons.school,
              ),
              StatCard(
                title: 'Teachers',
                value: '${p.stats.teachers}',
                icon: Icons.groups,
              ),
              StatCard(
                title: 'Pending fees',
                value: money(p.stats.pendingFees),
                icon: Icons.account_balance_wallet,
                color: Colors.orange,
              ),
              StatCard(
                title: 'Collected',
                value: money(p.stats.collectedThisMonth),
                icon: Icons.trending_up,
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: "Today's birthdays",
            subtitle: '${p.stats.birthdaysToday} student(s) today',
          ),
          const SizedBox(height: 10),
          if (p.birthdays.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No student birthdays today.'),
              ),
            )
          else
            ...p.birthdays.map(
              (s) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: PhotoAvatar(path: s.photoPath, fallbackText: s.name),
                  title: Text(s.name,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('${s.standardClass}${s.section.isEmpty ? '' : ' • ${s.section}'}'),
                  trailing: FilledButton.icon(
                    onPressed: s.whatsappNumber.trim().isEmpty
                        ? null
                        : () async {
                            final ok = await p.sendBirthdayWish(s);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(ok
                                    ? 'WhatsApp opened.'
                                    : 'WhatsApp could not be opened.'),
                              ),
                            );
                          },
                    icon: const Icon(Icons.chat, size: 17),
                    label: const Text('Wish'),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
          SectionHeader(title: 'Quick actions'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StudentFormScreen()),
                ),
                icon: const Icon(Icons.person_add),
                label: const Text('Add admission'),
              ),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FeePaymentScreen()),
                ),
                icon: const Icon(Icons.payments),
                label: const Text('Fee payment'),
              ),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SalaryScreen()),
                ),
                icon: const Icon(Icons.receipt_long),
                label: const Text('Pay salary'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const Icon(Icons.lock, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Offline-first: records and photos stay on this device. WhatsApp opens only when you explicitly tap a message action.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
