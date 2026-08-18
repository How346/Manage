import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/school_provider.dart';
import '../widgets/section_header.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SchoolProvider>();
    final stats = provider.stats;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: provider.refreshDashboard,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            _WelcomeCard(
              schoolName: provider.schoolName,
            ),
            const SizedBox(height: 20),

            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.45,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _MetricCard(
                  title: 'Students',
                  value: '${stats.totalStudents}',
                  icon: Icons.school_rounded,
                  onTap: () {
                    Navigator.pushNamed(context, '/students');
                  },
                ),
                _MetricCard(
                  title: 'Teachers',
                  value: '${stats.totalTeachers}',
                  icon: Icons.groups_rounded,
                  onTap: () {
                    Navigator.pushNamed(context, '/teachers');
                  },
                ),
                _MetricCard(
                  title: 'Pending Fees',
                  value: '₹${stats.pendingFees.toStringAsFixed(0)}',
                  icon: Icons.payments_rounded,
                  onTap: () {
                    Navigator.pushNamed(context, '/fees');
                  },
                ),
                _MetricCard(
                  title: 'Today Attendance',
                  value: '${stats.todayAttendance}%',
                  icon: Icons.fact_check_rounded,
                  onTap: () {
                    Navigator.pushNamed(context, '/attendance');
                  },
                ),
              ],
            ),

            const SizedBox(height: 28),

            const SectionHeader(
              title: 'Quick Actions',
              subtitle: 'Common school operations',
            ),

            const SizedBox(height: 12),

            _QuickActionGrid(
              onAdmission: () {
                Navigator.pushNamed(context, '/students/add');
              },
              onFeePayment: () {
                Navigator.pushNamed(context, '/fees');
              },
              onSalary: () {
                Navigator.pushNamed(context, '/salaries');
              },
              onAttendance: () {
                Navigator.pushNamed(context, '/attendance');
              },
            ),

            const SizedBox(height: 28),

            SectionHeader(
              title: "Today's Birthdays",
              subtitle: '${stats.birthdaysToday} student(s) today',
              action: stats.birthdaysToday > 0 ? 'View all' : null,
              onAction: stats.birthdaysToday > 0
                  ? () {
                      Navigator.pushNamed(context, '/birthdays');
                    }
                  : null,
            ),

            const SizedBox(height: 12),

            if (provider.todayBirthdays.isEmpty)
              const _EmptyBirthdayCard()
            else
              ...provider.todayBirthdays.take(5).map(
                    (student) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 26,
                          backgroundImage: student.photoPath != null &&
                                  student.photoPath!.isNotEmpty
                              ? AssetImage(student.photoPath!)
                              : null,
                          child: student.photoPath == null ||
                                  student.photoPath!.isEmpty
                              ? const Icon(Icons.person_rounded)
                              : null,
                        ),
                        title: Text(
                          student.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          '${student.standardClass} • ${student.section}',
                        ),
                        trailing: IconButton(
                          tooltip: 'Send birthday wish',
                          icon: const Icon(
                            Icons.celebration_rounded,
                          ),
                          onPressed: () {
                            provider.sendBirthdayWish(student);
                          },
                        ),
                      ),
                    ),
                  ),

            const SizedBox(height: 28),

            SectionHeader(
              title: 'Fee Overview',
              subtitle: 'Current month',
              action: 'Open',
              onAction: () {
                Navigator.pushNamed(context, '/fees');
              },
            ),

            const SizedBox(height: 12),

            _FeeOverviewCard(
              collected: stats.currentMonthCollection,
              pending: stats.pendingFees,
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({
    required this.schoolName,
  });

  final String schoolName;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Icon(
                Icons.school_rounded,
                size: 30,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schoolName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'School Management Dashboard',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                size: 28,
                color: Theme.of(context).colorScheme.primary,
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionGrid extends StatelessWidget {
  const _QuickActionGrid({
    required this.onAdmission,
    required this.onFeePayment,
    required this.onSalary,
    required this.onAttendance,
  });

  final VoidCallback onAdmission;
  final VoidCallback onFeePayment;
  final VoidCallback onSalary;
  final VoidCallback onAttendance;

  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        'Add Admission',
        Icons.person_add_alt_1_rounded,
        onAdmission,
      ),
      (
        'Fee Payment',
        Icons.receipt_long_rounded,
        onFeePayment,
      ),
      (
        'Pay Salary',
        Icons.account_balance_wallet_rounded,
        onSalary,
      ),
      (
        'Attendance',
        Icons.fact_check_rounded,
        onAttendance,
      ),
    ];

    return GridView.builder(
      itemCount: actions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.8,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];

        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: action.$3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Icon(
                    action.$2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      action.$1,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyBirthdayCard extends StatelessWidget {
  const _EmptyBirthdayCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.cake_outlined,
              size: 42,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 10),
            const Text(
              'No birthdays today',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Birthday alerts will automatically appear here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeeOverviewCard extends StatelessWidget {
  const _FeeOverviewCard({
    required this.collected,
    required this.pending,
  });

  final double collected;
  final double pending;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _FeeValue(
                    label: 'Collected',
                    amount: collected,
                    icon: Icons.check_circle_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FeeValue(
                    label: 'Pending',
                    amount: pending,
                    icon: Icons.pending_actions_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: collected + pending <= 0
                    ? 0
                    : collected / (collected + pending),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeeValue extends StatelessWidget {
  const _FeeValue({
    required this.label,
    required this.amount,
    required this.icon,
  });

  final String label;
  final double amount;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 2),
              Text(
                '₹${amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
