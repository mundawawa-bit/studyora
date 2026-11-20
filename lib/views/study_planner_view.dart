import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controllers/app_controller.dart';
import '../models/planner_model.dart';

class StudyPlannerView extends StatefulWidget {
  const StudyPlannerView({super.key});

  @override
  State<StudyPlannerView> createState() => _StudyPlannerViewState();
}

class _StudyPlannerViewState extends State<StudyPlannerView> {
  final AppController _controller = AppController();

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  List<dynamic> _getEventsForDay(DateTime day) {
    final plans = _controller.planners.where((p) {
      return p.dueDate.year == day.year &&
          p.dueDate.month == day.month &&
          p.dueDate.day == day.day;
    }).toList();

    if (plans.isNotEmpty) {
      return [true];
    }
    return [];
  }

  void _showAddPlannerModal(BuildContext context) {
    final titleController = TextEditingController();
    final notesController = TextEditingController();

    String? selectedCourse = _controller.courses.isNotEmpty
        ? _controller.courses.first.courseName
        : 'Belajar Mandiri / Luar Matkul';
    DateTime selectedDate = _selectedDay;
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 30);
    const String plannerType = 'Daily';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8E5FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.edit_calendar_rounded, color: Color(0xFF8C72EC), size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Buat Study Plan (Daily)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D2E4A)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const Text('Aktivitas Belajar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF8C8CA1))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'Misal: Koding UI Dashboard Studyora',
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFFF8F8FC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text('Pilih Mata Kuliah (Opsi)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF8C8CA1))),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8FC),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCourse,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF8C72EC)),
                          items: [
                            const DropdownMenuItem(
                              value: 'Belajar Mandiri / Luar Matkul',
                              child: Text('🌱 Belajar Mandiri / Luar Matkul', style: TextStyle(fontSize: 13, color: Color(0xFF2D2E4A))),
                            ),
                            ..._controller.courses.map((course) {
                              return DropdownMenuItem(
                                value: course.courseName,
                                child: Text('📚 ${course.courseName}', style: const TextStyle(fontSize: 13, color: Color(0xFF2D2E4A))),
                              );
                            }),
                          ],
                          onChanged: (val) {
                            setModalState(() => selectedCourse = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text('Catatan / Keterangan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF8C8CA1))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Tambahkan detail atau catatan khusus...',
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFFF8F8FC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),

                    InkWell(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setModalState(() => selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F8FC),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined, color: Color(0xFF8C72EC), size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Tanggal: ${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D2E4A), fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              TimeOfDay? picked = await showTimePicker(
                                context: context,
                                initialTime: startTime,
                              );
                              if (picked != null) {
                                setModalState(() => startTime = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F8FC),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Jam Mulai', style: TextStyle(fontSize: 10, color: Color(0xFF8C8CA1), fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(
                                    startTime.format(context),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2D2E4A)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              TimeOfDay? picked = await showTimePicker(
                                context: context,
                                initialTime: endTime,
                              );
                              if (picked != null) {
                                setModalState(() => endTime = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F8FC),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Jam Selesai', style: TextStyle(fontSize: 10, color: Color(0xFF8C8CA1), fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(
                                    endTime.format(context),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2D2E4A)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8C72EC),
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        if (titleController.text.isNotEmpty) {
                          await _controller.addPlanner(
                            title: titleController.text,
                            courseName: selectedCourse == 'Belajar Mandiri / Luar Matkul' ? null : selectedCourse,
                            notes: notesController.text,
                            dueDate: selectedDate,
                            startTime: startTime,
                            endTime: endTime,
                            plannerType: plannerType,
                          );
                          if (!context.mounted) return;
                          setState(() {});
                          Navigator.pop(context);
                        }
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Kunci & Simpan Plan',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          SizedBox(width: 6),
                          Text('🔒', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
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
    final selectedDayPlans = _controller.planners.where((p) {
      return p.dueDate.year == _selectedDay.year &&
          p.dueDate.month == _selectedDay.month &&
          p.dueDate.day == _selectedDay.day;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),
      appBar: AppBar(
        title: const Text('Study Plan Interaktif', style: TextStyle(color: Color(0xFF2D2E4A), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
            ),
            child: TableCalendar<dynamic>(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              eventLoader: _getEventsForDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Color(0xFF8C72EC),
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Color(0xFFE8E5FF),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(color: Color(0xFF6C5CE7), fontWeight: FontWeight.bold),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      bottom: 1,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF8C72EC),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: selectedDayPlans.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.event_note_rounded, size: 48, color: Color(0xFFB0A8E8)),
                          const SizedBox(height: 8),
                          Text(
                            'Tidak ada plan pada tanggal ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                            style: const TextStyle(color: Color(0xFF8C8CA1), fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: selectedDayPlans.length,
                      itemBuilder: (context, index) {
                        PlannerModel plan = selectedDayPlans[index];
                        bool isExpired = plan.isExpired && !plan.isCompleted;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isExpired ? const Color(0xFFFFEBEE) : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isExpired ? Colors.red.shade200 : const Color(0xFFEBEBFF),
                            ),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isExpired ? Colors.red.shade100 : const Color(0xFFE8E5FF),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      isExpired ? 'Plan Terlewat! 🌧️' : (plan.courseName ?? 'Belajar Mandiri'),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isExpired ? Colors.red : const Color(0xFF6C5CE7),
                                      ),
                                    ),
                                  ),
                                  if (isExpired)
                                    const Text('Terkunci 🔒', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red))
                                  else
                                    Checkbox(
                                      value: plan.isCompleted,
                                      activeColor: const Color(0xFF8C72EC),
                                      onChanged: (val) async {
                                        await _controller.togglePlannerCompletion(plan.id);
                                        if (mounted) setState(() {});
                                      },
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                plan.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2D2E4A),
                                  decoration: plan.isCompleted ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              if (plan.notes.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(plan.notes, style: const TextStyle(fontSize: 12, color: Color(0xFF8C8CA1))),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${plan.startTime.format(context)} - ${plan.endTime.format(context)}',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF8C72EC)),
                                  ),
                                  if (plan.isCompleted)
                                    const Text(
                                      'Sudah Selesai ✨',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF8C72EC),
        onPressed: () => _showAddPlannerModal(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Plan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}