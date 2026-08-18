import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/teacher.dart';
import '../providers/school_provider.dart';

class SalaryScreen extends StatefulWidget {
  final Teacher? teacher;
  const SalaryScreen({super.key, this.teacher});

  @override
  State<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen> {
  Teacher? selected;
  late final TextEditingController month;

  @override
  void initState() {
    super.initState();
    selected = widget.teacher;
    month = TextEditingController(text: DateFormat('MMMM yyyy').format(DateTime.now()));
  }

  @override
  void dispose() {
    month.dispose();
    super.dispose();
  }

  Future<void> pay() async {
    if (selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a teacher.')));
      return;
    }
    await context.read<SchoolProvider>().markSalaryPaid(
          teacher: selected!,
          month: month.text.trim(),
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final teachers = context.watch<SchoolProvider>().teachers;
    return Scaffold(
      appBar: AppBar(title: const Text('Pay salary')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          DropdownButtonFormField<Teacher>(
            initialValue: selected,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Teacher'),
            items: teachers.map((t) => DropdownMenuItem(
              value: t,
              child: Text('${t.name} • ₹${t.monthlySalary.toStringAsFixed(0)}'),
            )).toList(),
            onChanged: (t) => setState(() => selected = t),
          ),
          const SizedBox(height: 12),
          TextField(controller: month, decoration: const InputDecoration(labelText: 'Month / year')),
          const SizedBox(height: 18),
          if (selected != null)
            Card(
              child: ListTile(
                title: Text(selected!.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text('Base salary ₹${selected!.monthlySalary.toStringAsFixed(0)}'),
              ),
            ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: pay,
            icon: const Icon(Icons.check_circle),
            label: const Text('Mark salary paid'),
          ),
        ],
      ),
    );
  }
}
