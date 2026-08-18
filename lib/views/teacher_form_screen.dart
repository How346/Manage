import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/teacher.dart';
import '../providers/school_provider.dart';
import '../widgets/photo_avatar.dart';

class TeacherFormScreen extends StatefulWidget {
  final Teacher? teacher;
  const TeacherFormScreen({super.key, this.teacher});

  @override
  State<TeacherFormScreen> createState() => _TeacherFormScreenState();
}

class _TeacherFormScreenState extends State<TeacherFormScreen> {
  final key = GlobalKey<FormState>();
  late final TextEditingController name;
  late final TextEditingController role;
  late final TextEditingController salary;
  late final TextEditingController joining;
  late final TextEditingController whatsapp;
  String? photo;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.teacher;
    name = TextEditingController(text: t?.name ?? '');
    role = TextEditingController(text: t?.subjectOrRole ?? '');
    salary = TextEditingController(text: t == null ? '' : t.monthlySalary.toStringAsFixed(0));
    joining = TextEditingController(text: t?.joiningDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now()));
    whatsapp = TextEditingController(text: t?.whatsappNumber ?? '');
    photo = t?.photoPath;
  }

  @override
  void dispose() {
    for (final c in [name, role, salary, joining, whatsapp]) { c.dispose(); }
    super.dispose();
  }

  Future<void> pick(ImageSource source) async {
    final path = await context.read<SchoolProvider>().pickPhoto(source);
    if (path != null) setState(() => photo = path);
  }

  Future<void> save() async {
    if (!key.currentState!.validate()) return;
    final amount = double.tryParse(salary.text.trim());
    if (amount == null || amount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid salary.')));
      return;
    }
    setState(() => saving = true);
    try {
      await context.read<SchoolProvider>().saveTeacher(
            Teacher(
              id: widget.teacher?.id,
              name: name.text.trim(),
              subjectOrRole: role.text.trim(),
              monthlySalary: amount,
              joiningDate: joining.text.trim(),
              whatsappNumber: whatsapp.text.trim(),
              photoPath: photo,
            ),
          );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.teacher == null ? 'Add teacher' : 'Edit teacher')),
      body: Form(
        key: key,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Center(child: PhotoAvatar(path: photo, radius: 54, fallbackText: name.text)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: [
                OutlinedButton.icon(onPressed: () => pick(ImageSource.camera), icon: const Icon(Icons.camera_alt), label: const Text('Camera')),
                OutlinedButton.icon(onPressed: () => pick(ImageSource.gallery), icon: const Icon(Icons.photo_library), label: const Text('Gallery')),
              ],
            ),
            const SizedBox(height: 18),
            _f(name, 'Teacher name'),
            _f(role, 'Subject / designation'),
            _f(salary, 'Monthly salary', type: TextInputType.number),
            _f(joining, 'Joining date'),
            _f(whatsapp, 'WhatsApp number', type: TextInputType.phone, required: false),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: saving ? null : save,
              icon: const Icon(Icons.save),
              label: Text(saving ? 'Saving…' : 'Save teacher'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _f(TextEditingController c, String label, {TextInputType? type, bool required = true}) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: c,
          keyboardType: type,
          validator: required ? (v) => v == null || v.trim().isEmpty ? '$label is required' : null : null,
          decoration: InputDecoration(labelText: label),
        ),
      );
}
