import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/teacher.dart';
import '../providers/school_provider.dart';
import '../widgets/photo_avatar.dart';
import 'teacher_form_screen.dart';
import 'salary_screen.dart';

class TeachersScreen extends StatelessWidget {
  const TeachersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SchoolProvider>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Teachers',
            style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TeacherFormScreen()),
            ),
            icon: const Icon(Icons.person_add),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search teacher or designation',
            ),
            onChanged: p.setTeacherQuery,
          ),
          const SizedBox(height: 14),
          if (p.teachers.isEmpty)
            const Card(child: Padding(padding: EdgeInsets.all(22), child: Text('No teachers found.'))),
          ...p.teachers.map(
            (t) => Card(
              margin: const EdgeInsets.only(bottom: 9),
              child: ListTile(
                leading: PhotoAvatar(path: t.photoPath, fallbackText: t.name),
                title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text('${t.subjectOrRole} • ₹${t.monthlySalary.toStringAsFixed(0)}/month'),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => TeacherFormScreen(teacher: t)));
                    } else if (value == 'salary') {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => SalaryScreen(teacher: t)));
                    } else if (value == 'delete') {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Delete teacher?'),
                          content: Text('Delete ${t.name} and salary records?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                          ],
                        ),
                      );
                      if (ok == true) await p.deleteTeacher(t);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'salary', child: Text('Salary')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
