import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/class/class_bloc.dart';
import '../../bloc/class/class_state.dart';
import '../../bloc/settings/settings_cubit.dart';
import '../../bloc/timetable/timetable_bloc.dart';
import '../../bloc/timetable/timetable_event.dart';
import '../../bloc/timetable/timetable_state.dart';
import '../../database/database_helper.dart';
import '../../models/class_model.dart';
import '../../models/timetable_model.dart';
import '../../theme/colors.dart';
import '../attendance/take_attendance_screen.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  int _selectedDay = DateTime.now().weekday; // 1 = Mon ... 7 = Sun

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadSlotsForDay(_selectedDay);
      }
    });
  }

  void _loadSlotsForDay(int day) {
    try {
      context.read<TimetableBloc>().add(LoadTimetableForDay(day));
    } catch (_) {}
  }

  void _openAddLectureDialog(BuildContext context, List<ClassModel> classes) {
    if (classes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create at least one class first.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final settings = this.context.read<SettingsCubit>().state.settings;
    final isDaily = settings.isDailyAttendanceMode;

    ClassModel selectedClass = classes.first;
    int selectedDay = _selectedDay;
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);
    final initialSubject = selectedClass.subject == 'Daily Roll Call'
        ? ''
        : selectedClass.subject;
    final subjectController = TextEditingController(text: initialSubject);
    final roomController = TextEditingController(text: 'Room 101');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.88,
              ),
              padding: EdgeInsets.fromLTRB(
                24,
                20,
                24,
                16 + MediaQuery.paddingOf(ctx).bottom,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCardBackground : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1.2,
                ),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isDaily ? 'Schedule Lecture Period' : 'Schedule Lecture Slot',
                        style:
                            const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // Select Class Dropdown
                      Text(isDaily ? 'Select Class / Division' : 'Select Class',
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCardElevated
                              : AppColors.lightCardElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<ClassModel>(
                            isExpanded: true,
                            value: selectedClass,
                            dropdownColor: isDark
                                ? AppColors.darkCardBackground
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                                color: AppColors.primaryLight, size: 22),
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() {
                                  selectedClass = val;
                                  if (val.subject != 'Daily Roll Call' &&
                                      subjectController.text.trim().isEmpty) {
                                    subjectController.text = val.subject;
                                  }
                                });
                              }
                            },
                            items: classes.map((c) {
                              final label = (c.subject.isEmpty ||
                                      c.subject == 'Daily Roll Call')
                                  ? '${c.name} (${c.year})'
                                  : '${c.name} • ${c.subject}';
                              return DropdownMenuItem(
                                value: c,
                                child: Text(
                                  label,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Subject / Topic Input Field
                      Text(
                        isDaily ? 'Period Subject / Topic' : 'Lecture Subject / Topic',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: subjectController,
                        decoration: InputDecoration(
                          hintText: isDaily
                              ? 'e.g. Mathematics, Science, English'
                              : 'e.g. Data Structures, Applied Physics',
                          prefixIcon: const Icon(
                            Icons.menu_book_rounded,
                            color: AppColors.primaryLight,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? AppColors.darkCardElevated
                              : AppColors.lightCardElevated,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Day Selector Dropdown
                      const Text('Day of Week',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCardElevated
                              : AppColors.lightCardElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: selectedDay,
                            dropdownColor: isDark
                                ? AppColors.darkCardBackground
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                                color: AppColors.primaryLight, size: 22),
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() => selectedDay = val);
                              }
                            },
                            items: const [
                              DropdownMenuItem(
                                  value: DateTime.monday,
                                  child: Text('Monday')),
                              DropdownMenuItem(
                                  value: DateTime.tuesday,
                                  child: Text('Tuesday')),
                              DropdownMenuItem(
                                  value: DateTime.wednesday,
                                  child: Text('Wednesday')),
                              DropdownMenuItem(
                                  value: DateTime.thursday,
                                  child: Text('Thursday')),
                              DropdownMenuItem(
                                  value: DateTime.friday,
                                  child: Text('Friday')),
                              DropdownMenuItem(
                                  value: DateTime.saturday,
                                  child: Text('Saturday')),
                              DropdownMenuItem(
                                  value: DateTime.sunday,
                                  child: Text('Sunday')),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Time Pickers Row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Start Time',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () async {
                                    final picked = await showTimePicker(
                                      context: context,
                                      initialTime: startTime,
                                    );
                                    if (picked != null) {
                                      setModalState(() => startTime = picked);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.darkCardElevated
                                          : AppColors.lightCardElevated,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: isDark
                                              ? AppColors.darkBorder
                                              : AppColors.lightBorder),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          startTime.format(context),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const Icon(
                                            Icons.access_time_rounded,
                                            size: 18,
                                            color: AppColors.primaryLight),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('End Time',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () async {
                                    final picked = await showTimePicker(
                                      context: context,
                                      initialTime: endTime,
                                    );
                                    if (picked != null) {
                                      setModalState(() => endTime = picked);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.darkCardElevated
                                          : AppColors.lightCardElevated,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: isDark
                                              ? AppColors.darkBorder
                                              : AppColors.lightBorder),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          endTime.format(context),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const Icon(
                                            Icons.access_time_filled_rounded,
                                            size: 18,
                                            color: AppColors.primaryLight),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Room Input
                      const Text('Room / Hall',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: roomController,
                        decoration: InputDecoration(
                          hintText: 'e.g. Hall 4B or Lab 2',
                          prefixIcon: const Icon(Icons.room_preferences_rounded,
                              color: AppColors.primaryLight, size: 20),
                          filled: true,
                          fillColor: isDark
                              ? AppColors.darkCardElevated
                              : AppColors.lightCardElevated,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      ElevatedButton.icon(
                        onPressed: () {
                          final startStr =
                              '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
                          final endStr =
                              '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

                          final rawSubject = subjectController.text.trim();
                          final effectiveSubject = rawSubject.isNotEmpty
                              ? rawSubject
                              : (selectedClass.subject != 'Daily Roll Call'
                                  ? selectedClass.subject
                                  : 'General Subject');

                          final slot = TimetableModel(
                            classId: selectedClass.id!,
                            className: selectedClass.name,
                            subject: effectiveSubject,
                            dayOfWeek: selectedDay,
                            startTime: startStr,
                            endTime: endStr,
                            roomNumber: roomController.text.trim(),
                          );

                          this
                              .context
                              .read<TimetableBloc>()
                              .add(AddTimetableSlot(slot));
                          Navigator.pop(ctx);

                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Lecture slot scheduled and reminder active!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_alarm_rounded),
                        label: const Text('Save & Set Reminder'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _takeAttendanceForSlot(TimetableModel slot) async {
    HapticFeedback.mediumImpact();
    final db = context.read<ClassBloc>().database;
    final dbHelper = DatabaseHelper(db);
    final students = await dbHelper.getStudents(slot.classId);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: 'take_attendance'),
        builder: (context) => TakeAttendanceScreen(
          classId: slot.classId,
          students: students,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = context.watch<SettingsCubit>().state.settings;
    final isDaily = settings.isDailyAttendanceMode;

    final classState = context.watch<ClassBloc>().state;
    List<ClassModel> classes = [];
    if (classState is ClassesLoaded) {
      classes = classState.classes;
    }

    final days = [
      {'num': 1, 'short': 'Mon', 'full': 'Monday'},
      {'num': 2, 'short': 'Tue', 'full': 'Tuesday'},
      {'num': 3, 'short': 'Wed', 'full': 'Wednesday'},
      {'num': 4, 'short': 'Thu', 'full': 'Thursday'},
      {'num': 5, 'short': 'Fri', 'full': 'Friday'},
      {'num': 6, 'short': 'Sat', 'full': 'Saturday'},
      {'num': 7, 'short': 'Sun', 'full': 'Sunday'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Timetable'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Lecture',
            onPressed: () => _openAddLectureDialog(context, classes),
          ),
        ],
      ),
      body: Column(
        children: [
          // Day Selector Bar
          Container(
            height: 56,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: days.length,
              separatorBuilder: (context, i) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final d = days[index];
                final isSelected = d['num'] == _selectedDay;
                final isToday = d['num'] == DateTime.now().weekday;

                return InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedDay = d['num'] as int);
                    _loadSlotsForDay(_selectedDay);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryColor
                          : (isDark
                              ? AppColors.darkCardBackground
                              : Colors.white),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryColor
                            : (isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          d['short'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                        if (isToday)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Timetable slots list
          Expanded(
            child: BlocBuilder<TimetableBloc, TimetableState>(
              builder: (context, state) {
                if (state is TimetableLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TimetableLoaded) {
                  final slots = state.slots;

                  if (slots.isEmpty) {
                    return Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          32.0,
                          20.0,
                          32.0,
                          MediaQuery.paddingOf(context).bottom + 120.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 56,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMuted,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Lectures for ${days.firstWhere((d) => d['num'] == _selectedDay)['full']}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Schedule your lecture slots to receive automated reminders.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.textMutedDark
                                    : AppColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _openAddLectureDialog(context, classes),
                              icon: const Icon(Icons.add),
                              label: Text(
                                  isDaily ? 'Add Period Slot' : 'Add Lecture Slot'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                        16, 8, 16, MediaQuery.paddingOf(context).bottom + 100),
                    itemCount: slots.length,
                    separatorBuilder: (context, i) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final slot = slots[index];

                      return Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCardBackground
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                            width: 1.2,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: AppColors.primaryColor
                                                .withValues(alpha: 0.3)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.access_time_rounded,
                                              size: 14,
                                              color: AppColors.primaryLight),
                                          const SizedBox(width: 5),
                                          Text(
                                            slot.formattedTimeSlot,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: AppColors.primaryLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (slot.roomNumber.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? AppColors.darkCardElevated
                                              : AppColors.lightCardElevated,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          slot.roomNumber,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      size: 18, color: AppColors.errorColor),
                                  onPressed: () {
                                    context.read<TimetableBloc>().add(
                                          DeleteTimetableSlotEvent(
                                              slot.id!, slot.dayOfWeek),
                                        );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Class Tag Badge
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor
                                        .withValues(alpha: isDark ? 0.22 : 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.primaryColor
                                          .withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.school_rounded,
                                        size: 13,
                                        color: AppColors.primaryLight,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        slot.className,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Subject / Period Topic Name
                            Text(
                              slot.subject,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Divider(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                                height: 1),
                            const SizedBox(height: 10),
                            // Quick Action Button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isDaily ? 'Full-Day Roll Call' : 'Lecture Attendance',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.textMutedDark
                                        : AppColors.textMuted,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _takeAttendanceForSlot(slot),
                                  icon: const Icon(Icons.check_circle_outline,
                                      size: 16),
                                  label: Text(isDaily
                                      ? 'Mark Roll Call'
                                      : 'Take Attendance'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.presentColor,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    textStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
                return const Center(child: Text('Loading timetable...'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
