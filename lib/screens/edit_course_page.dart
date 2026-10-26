import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/student_info.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';

// ==================== TAHAP 7 ====================
// Form edit course lewat HTTP PUT. code dibuat READ-ONLY karena
// dipakai sebagai kunci favorites sejak Pertemuan 6 -- kalau code
// boleh diubah, status favorite course ini bisa jadi "yatim"
// (tidak match lagi dengan code yang baru).
// Alur sama seperti AddCoursePage (Tahap 6): screen -> CourseProvider
// -> CourseRepository -> CourseApiService. Screen tidak sentuh http.
// I Gede Pradhana Subawa Deningrat
// 2415051030
class EditCoursePage extends StatefulWidget {
  final Course course;

  const EditCoursePage({
    super.key,
    required this.course,
  });

  @override
  State<EditCoursePage> createState() => _EditCoursePageState();
}

class _EditCoursePageState extends State<EditCoursePage> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController titleController;
  late final TextEditingController creditsController;
  late String status;

  @override
  void initState() {
    super.initState();
    // Form diisi dengan data LAMA (sesuai instruksi worksheet).
    titleController = TextEditingController(text: widget.course.title);
    creditsController = TextEditingController(
      text: widget.course.credits.toString(),
    );
    status = widget.course.status;
  }

  @override
  void dispose() {
    titleController.dispose();
    creditsController.dispose();
    super.dispose();
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final id = widget.course.id;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course ini tidak punya id, tidak bisa diupdate'),
        ),
      );
      return;
    }

    final updatedCourse = Course(
      id: id,
      // code TETAP memakai yang lama, tidak diambil dari form.
      code: widget.course.code,
      title: titleController.text.trim(),
      credits: int.parse(creditsController.text.trim()),
      status: status,
    );

    final provider = context.read<CourseProvider>();

    try {
      await provider.updateCourse(id, updatedCourse);

      // Setelah await, WAJIB cek mounted sebelum memakai context.
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course berhasil diperbarui'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui course: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<CourseProvider>().isSaving;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Course'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                studentName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Text(
                'NIM: 2415051030',
                style: TextStyle(fontSize: 14),
              ),

              const SizedBox(height: 24),

              // code: read-only, cuma ditampilkan sebagai info.
              TextFormField(
                initialValue: widget.course.code,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Kode Course (tidak bisa diubah)',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Course',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul wajib diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: creditsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Credits (SKS)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Credits wajib diisi';
                  }
                  if (int.tryParse(value.trim()) == null) {
                    return 'Credits harus berupa angka';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'planned',
                    child: Text('planned'),
                  ),
                  DropdownMenuItem(
                    value: 'active',
                    child: Text('active'),
                  ),
                  DropdownMenuItem(
                    value: 'done',
                    child: Text('done'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      status = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSaving ? null : submitForm,
                  child: isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Simpan Perubahan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}