import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/student_info.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';

// ==================== TAHAP 6 ====================
// Form sederhana untuk membuat course baru lewat HTTP POST.
// Alur: form ini -> CourseProvider.createCourse() -> CourseRepository
// -> CourseApiService -> http.post(). Screen ini TIDAK memanggil
// package:http secara langsung.
// I Gede Pradhana Subawa Deningrat
// 2415051030
class AddCoursePage extends StatefulWidget {
  const AddCoursePage({super.key});

  @override
  State<AddCoursePage> createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final formKey = GlobalKey<FormState>();

  final codeController = TextEditingController();
  final titleController = TextEditingController();
  final creditsController = TextEditingController();

  String status = 'planned';

  @override
  void dispose() {
    codeController.dispose();
    titleController.dispose();
    creditsController.dispose();
    super.dispose();
  }

  Future<void> submitForm() async {
    // Validasi field wajib tidak kosong + credits berupa angka.
    if (!formKey.currentState!.validate()) {
      return;
    }

    final course = Course(
      code: codeController.text.trim(),
      title: titleController.text.trim(),
      credits: int.parse(creditsController.text.trim()),
      status: status,
    );

    final provider = context.read<CourseProvider>();

    try {
      await provider.createCourse(course);

      // Setelah await, WAJIB cek mounted sebelum memakai context.
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course berhasil ditambahkan'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan course: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // watch -> tombol Simpan otomatis update saat isSaving berubah.
    final isSaving = context.watch<CourseProvider>().isSaving;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Course'),
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

              TextFormField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'Kode Course',
                  hintText: 'Contoh: MOB06',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Kode wajib diisi';
                  }
                  return null;
                },
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
                  final credits = int.tryParse(value.trim());
                  if (credits == null) {
                    return 'Credits harus berupa angka';
                  }
                  if (credits <= 0) {
                    return 'Credits harus lebih dari 0';
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
                  // Tombol dinonaktifkan selama isSaving, mencegah
                  // submit ganda / data ganda.
                  onPressed: isSaving ? null : submitForm,
                  child: isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}