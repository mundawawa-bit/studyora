import 'package:flutter/material.dart';
import '../controllers/app_controller.dart';
import '../models/task_model.dart';

class TaskView extends StatefulWidget {
  const TaskView({super.key});

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  final AppController _controller = AppController();
  String _selectedCourseFilter = 'Semua';

  void _showAddTaskModal(BuildContext context, {TaskModel? taskToEdit}) {
    final titleController = TextEditingController(text: taskToEdit?.title ?? '');
    final notesController = TextEditingController(text: taskToEdit?.notes ?? '');

    String? selectedCourse = taskToEdit?.course;
    if (selectedCourse == null && _controller.courses.isNotEmpty) {
      selectedCourse = _controller.courses.first.courseName;
    }

    DateTime selectedDate = taskToEdit?.dueDate ?? DateTime.now();
    bool isEditing = taskToEdit != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isEditing ? '✨ Edit Tugas ✨' : '✨ Tambah Tugas Baru ✨',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Input Judul Tugas
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Judul Tugas',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Dropdown Mata Kuliah
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedCourse,
                        decoration: const InputDecoration(
                          labelText: 'Mata Kuliah',
                          border: InputBorder.none,
                          icon: Icon(Icons.book, color: Colors.deepPurple),
                        ),
                        items: _controller.courses.map((course) {
                          return DropdownMenuItem(
                            value: course.courseName,
                            child: Text(course.courseName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setModalState(() {
                            selectedCourse = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Input Catatan Tugas
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Catatan Tugas',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Picker Tanggal Deadline
                    InkWell(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2030),
                        );
                        if (pickedDate != null) {
                          setModalState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.deepPurple, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Deadline: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                              style: const TextStyle(fontSize: 16, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tombol Simpan / Update
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          if (titleController.text.isNotEmpty) {
                            if (isEditing) {
                              await _controller.deleteTask(taskToEdit.id);
                              await _controller.addTaskData(
                                title: titleController.text,
                                course: selectedCourse ?? 'Umum',
                                notes: notesController.text,
                                dueDate: selectedDate,
                              );
                            } else {
                              await _controller.addTaskData(
                                title: titleController.text,
                                course: selectedCourse ?? 'Umum',
                                notes: notesController.text,
                                dueDate: selectedDate,
                              );
                            }
                            if (!context.mounted) return;
                            setState(() {});
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          isEditing ? 'Perbarui Tugas 🌸' : 'Simpan Tugas 🌸',
                          style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Set<String> uniqueCourses = {
      ..._controller.courses.map((c) => c.courseName).where((name) => name.trim().isNotEmpty),
      ..._controller.tasksList.map((t) => t.course).where((name) => name.trim().isNotEmpty),
    };
    final List<String> filterOptions = ['Semua', ...uniqueCourses];

    if (!filterOptions.contains(_selectedCourseFilter)) {
      _selectedCourseFilter = 'Semua';
    }

    final List<TaskModel> filteredTasks = _selectedCourseFilter == 'Semua'
        ? _controller.tasksList
        : _controller.tasksList.where((t) => t.course == _selectedCourseFilter).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Daftar Tugas 📝', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          if (_controller.tasksList.isNotEmpty || filterOptions.length > 1)
            SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: filterOptions.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final String option = filterOptions[index];
                  final bool isSelected = _selectedCourseFilter == option;
                  return ChoiceChip(
                    label: Text(option),
                    selected: isSelected,
                    selectedColor: Colors.deepPurple,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
                      ),
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedCourseFilter = option;
                      });
                    },
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: filteredTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          _controller.tasksList.isEmpty
                              ? 'Belum ada tugas. Yuk tambah tugasmu! ✨'
                              : 'Tidak ada tugas untuk mata kuliah "$_selectedCourseFilter".',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final TaskModel task = filteredTasks[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: task.isCompleted,
                              activeColor: Colors.deepPurple,
                              onChanged: (bool? value) async {
                                await _controller.updateTaskStatus(task.id, value ?? false);
                                setState(() {});
                              },
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                      fontWeight: FontWeight.bold,
                                      color: task.isCompleted ? Colors.grey : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.book, size: 14, color: Colors.deepPurple),
                                      const SizedBox(width: 4),
                                      Text(
                                        task.course,
                                        style: const TextStyle(fontSize: 12, color: Colors.deepPurple, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  if (task.notes.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      'Catatan: ${task.notes}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  ],
                                  const SizedBox(height: 2),
                                  Text(
                                    'Deadline: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                                    style: const TextStyle(fontSize: 11, color: Colors.orangeAccent, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            // Tombol Edit
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent, size: 22),
                              onPressed: () {
                                _showAddTaskModal(context, taskToEdit: task);
                              },
                            ),
                            // Tombol Hapus
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                              onPressed: () async {
                                await _controller.deleteTask(task.id);
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () => _showAddTaskModal(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}