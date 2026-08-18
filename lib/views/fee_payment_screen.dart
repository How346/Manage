import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/student.dart';
import '../providers/school_provider.dart';

class FeePaymentScreen extends StatefulWidget {
  final Student? student;
  const FeePaymentScreen({super.key, this.student});

  @override
  State<FeePaymentScreen> createState() => _FeePaymentScreenState();
}

class _FeePaymentScreenState extends State<FeePaymentScreen> {
  Student? selected;
  late final TextEditingController month;
  late final TextEditingController total;
  late final TextEditingController paid;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    selected = widget.student;
    month = TextEditingController(text: DateFormat('MMMM yyyy').format(DateTime.now()));
    total = TextEditingController(text: '0');
    paid = TextEditingController(text: '0');
  }

  @override
  void dispose() {
    month.dispose();
    total.dispose();
    paid.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a student.')));
      return;
    }
    final t = double.tryParse(total.text.trim());
    final p = double.tryParse(paid.text.trim());
    if (t == null || p == null || t < 0 || p < 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid amounts.')));
      return;
    }
    if (p > t) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paid amount cannot exceed total amount.')));
      return;
    }
    setState(() => saving = true);
    try {
      await context.read<SchoolProvider>().saveFee(
            studentId: selected!.id!,
            month: month.text.trim(),
            total: t,
            paid: p,
          );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final students = context.watch<SchoolProvider>().students;
    return Scaffold(
      appBar: AppBar(title: const Text('Record fee payment')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          DropdownButtonFormField<Student>(
            initialValue: selected,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Student'),
            items: students
                .map((s) => DropdownMenuItem(
                      value: s,
                      child: Text('${s.name} • ${s.admissionNo}'),
                    ))
                .toList(),
            onChanged: (s) => setState(() => selected = s),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: month,
            decoration: const InputDecoration(labelText: 'Month / year'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: total,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Total fee'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: paid,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Paid amount'),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: saving ? null : save,
            icon: const Icon(Icons.save),
            label: Text(saving ? 'Saving…' : 'Save payment'),
          ),
        ],
      ),
    );
  }
}
