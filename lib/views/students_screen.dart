import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/student.dart';
import '../providers/school_provider.dart';
import '../widgets/photo_avatar.dart';
import 'student_form_screen.dart';
import 'student_profile_screen.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SchoolProvider>();
    final classes = {'All', ...p.students.map((e) => e.standardClass)}.toList()..sort();
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Students',
            style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Add student',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StudentFormScreen()),
            ),
            icon: const Icon(Icons.person_add_alt_1),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search name, admission no or father name',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => p.setStudentFilter(query: v),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: classes.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final c = classes[i];
                return ChoiceChip(
                  label: Text(c),
                  selected: p.classFilter == c,
                  onSelected: (_) => p.setStudentFilter(className: c),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          if (p.students.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(22),
                child: Text('No students found.'),
              ),
            ),
          ...p.students.map((s) => _StudentTile(student: s)),
        ],
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  final Student student;
  const _StudentTile({required this.student});

  @override
  Widget build(BuildContext context) {
    final p = context.read<SchoolProvider>();
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        leading: PhotoAvatar(path: student.photoPath, fallbackText: student.name),
        title: Text(student.name,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(
          '${student.admissionNo} • ${student.standardClass}${student.section.isEmpty ? '' : ' • ${student.section}'}',
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StudentProfileScreen(student: student),
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit') {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StudentFormScreen(student: student),
                ),
              );
            } else if (value == 'delete') {
              final yes = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Delete student?'),
                  content: Text('Delete ${student.name} and its fee records?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (yes == true) await p.deleteStudent(student);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}
