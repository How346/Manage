import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/student.dart';
import '../providers/school_provider.dart';
import '../widgets/photo_avatar.dart';

class StudentFormScreen extends StatefulWidget {
  final Student? student;
  const StudentFormScreen({super.key, this.student});

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController admission;
  late final TextEditingController name;
  late final TextEditingController father;
  late final TextEditingController mother;
  late final TextEditingController className;
  late final TextEditingController section;
  late final TextEditingController dob;
  late final TextEditingController whatsapp;
  String? photoPath;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    admission = TextEditingController(text: s?.admissionNo ?? '');
    name = TextEditingController(text: s?.name ?? '');
    father = TextEditingController(text: s?.fatherName ?? '');
    mother = TextEditingController(text: s?.motherName ?? '');
    className = TextEditingController(text: s?.standardClass ?? '');
    section = TextEditingController(text: s?.section ?? '');
    dob = TextEditingController(text: s?.dob ?? '');
    whatsapp = TextEditingController(text: s?.whatsappNumber ?? '');
    photoPath = s?.photoPath;
  }

  @override
  void dispose() {
    for (final c in [admission, name, father, mother, className, section, dob, whatsapp]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> selectDob() async {
    final initial = DateTime.tryParse(dob.text) ?? DateTime(2018, 1, 1);
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      initialDate: initial,
    );
    if (picked != null) dob.text = DateFormat('yyyy-MM-dd').format(picked);
    setState(() {});
  }

  Future<void> pickPhoto(ImageSource source) async {
    final path = await context.read<SchoolProvider>().pickPhoto(source);
    if (path != null) setState(() => photoPath = path);
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => saving = true);
    try {
      final existing = widget.student;
      final student = Student(
        id: existing?.id,
        admissionNo: admission.text.trim(),
        name: name.text.trim(),
        fatherName: father.text.trim(),
        motherName: mother.text.trim(),
        standardClass: className.text.trim(),
        section: section.text.trim(),
        dob: dob.text.trim(),
        whatsappNumber: whatsapp.text.trim(),
        photoPath: photoPath,
        admissionDate: existing?.admissionDate ??
            DateFormat('yyyy-MM-dd').format(DateTime.now()),
      );
      await context.read<SchoolProvider>().saveStudent(student);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not save: $e')));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student == null ? 'New admission' : 'Edit student'),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Center(
              child: Column(
                children: [
                  PhotoAvatar(path: photoPath, radius: 54, fallbackText: name.text),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => pickPhoto(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => pickPhoto(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _field(admission, 'Admission number', required: true),
            _field(name, 'Student name', required: true),
            _field(father, "Father's name"),
            _field(mother, "Mother's name"),
            Row(
              children: [
                Expanded(child: _field(className, 'Class', required: true)),
                const SizedBox(width: 10),
                Expanded(child: _field(section, 'Section')),
              ],
            ),
            TextFormField(
              controller: dob,
              readOnly: true,
              onTap: selectDob,
              decoration: const InputDecoration(
                labelText: 'Date of birth',
                suffixIcon: Icon(Icons.calendar_month),
              ),
            ),
            const SizedBox(height: 12),
            _field(
              whatsapp,
              "Parent WhatsApp number",
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: saving ? null : save,
              icon: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(saving ? 'Saving…' : 'Save student'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    TextInputType? keyboardType,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: required
              ? (v) => v == null || v.trim().isEmpty ? '$label is required' : null
              : null,
          decoration: InputDecoration(labelText: label),
        ),
      );
}
