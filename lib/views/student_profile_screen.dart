import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/student.dart';
import '../providers/school_provider.dart';
import '../widgets/photo_avatar.dart';
import 'fee_payment_screen.dart';
import 'student_form_screen.dart';

class StudentProfileScreen extends StatelessWidget {
  final Student student;
  const StudentProfileScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final p = context.read<SchoolProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student profile'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => StudentFormScreen(student: student)),
            ),
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: FutureBuilder(
        future: p.database.getFeesForStudent(student.id!),
        builder: (context, snapshot) {
          final fees = snapshot.data ?? [];
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      PhotoAvatar(path: student.photoPath, radius: 52, fallbackText: student.name),
                      const SizedBox(height: 12),
                      Text(student.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                      Text('${student.standardClass} ${student.section} • ${student.admissionNo}'),
                      const SizedBox(height: 16),
                      _info('Father', student.fatherName),
                      _info('Mother', student.motherName),
                      _info('DOB', student.dob.isEmpty ? 'Not set' : student.dob),
                      _info('WhatsApp', student.whatsappNumber.isEmpty ? 'Not set' : student.whatsappNumber),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FeePaymentScreen(student: student)),
                ),
                icon: const Icon(Icons.payments),
                label: const Text('Record fee payment'),
              ),
              const SizedBox(height: 18),
              Text('Fee history',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              if (fees.isEmpty)
                const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('No fee records yet.')))
              else
                ...fees.map(
                  (f) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(f.monthYear, style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text('Paid ₹${f.paidAmount.toStringAsFixed(0)} • Due ₹${f.dueAmount.toStringAsFixed(0)}'),
                      trailing: Chip(label: Text(f.status)),
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              Text(
                'Admission date: ${DateFormat('dd MMM yyyy').format(DateTime.tryParse(student.admissionDate) ?? DateTime.now())}',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _info(String label, String value) => ListTile(
        dense: true,
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        trailing: Text(value.isEmpty ? '—' : value),
      );
}
