import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/class/class_bloc.dart';
import '../../bloc/class/class_event.dart';
import '../../bloc/settings/settings_cubit.dart';
import '../../bloc/settings/settings_state.dart';
import '../../bloc/theme/theme_cubit.dart';
import '../../bloc/timetable/timetable_bloc.dart';
import '../../bloc/timetable/timetable_event.dart';
import '../../database/database_helper.dart';
import '../../models/settings_model.dart';
import '../../services/backup_service.dart';
import '../../services/demo_data_service.dart';
import '../../services/notification_service.dart';
import '../../theme/colors.dart';
import '../../utils/csv_helper.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/custom_text_field.dart';
import 'about_app_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _editTeacherProfile(BuildContext context, SettingsModel currentSettings) {
    String selectedTitle = currentSettings.teacherTitle;
    String selectedGender = currentSettings.teacherGender;
    String selectedInstitutionType = currentSettings.institutionType;

    final nameController = TextEditingController(
      text: currentSettings.teacherName == 'Professor'
          ? ''
          : currentSettings.teacherName,
    );
    final instituteController = TextEditingController(
      text: currentSettings.instituteName == 'Department of Science'
          ? ''
          : currentSettings.instituteName,
    );
    final emailController =
        TextEditingController(text: currentSettings.teacherEmail);

    final titleOptions = [
      {'title': 'Sir', 'desc': 'Educator / Teacher'},
      {'title': 'Miss', 'desc': 'Educator / Teacher'},
      {'title': 'Professor', 'desc': 'Higher Education'},
      {'title': 'Dr.', 'desc': 'Doctorate / Scholar'},
      {'title': 'Mr.', 'desc': 'Formal Title'},
      {'title': 'Ms.', 'desc': 'Formal Title'},
    ];

    final genderOptions = [
      {'val': 'Male', 'label': 'Male', 'icon': Icons.male_rounded},
      {'val': 'Female', 'label': 'Female', 'icon': Icons.female_rounded},
      {'val': 'Other', 'label': 'Other', 'icon': Icons.star_rounded},
      {'val': 'Unspecified', 'label': 'Skip', 'icon': Icons.remove_circle_outline_rounded},
    ];

    final institutionOptions = [
      {'type': 'University', 'icon': Icons.account_balance_rounded},
      {'type': 'College', 'icon': Icons.school_rounded},
      {'type': 'School', 'icon': Icons.apartment_rounded},
      {'type': 'Institute', 'icon': Icons.business_rounded},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

            // Compute live previews
            final rawName = nameController.text.trim();
            final teacherName = rawName.isNotEmpty ? rawName : 'Alex Smith';
            final fullTitle = teacherName.startsWith(selectedTitle)
                ? teacherName
                : '$selectedTitle $teacherName';

            final rawInst = instituteController.text.trim();
            final inst = rawInst.isNotEmpty
                ? rawInst
                : '$selectedInstitutionType of Advanced Studies';

            final previewGreeting = fullTitle;
            final previewNotice = '$fullTitle ($inst)';

            final avatarInitial = rawName.isNotEmpty
                ? rawName[0].toUpperCase()
                : (selectedTitle.isNotEmpty ? selectedTitle[0] : 'P');

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.90,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, -10),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag Handle
                      const SizedBox(height: 12),
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Header with Live Avatar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryColor
                                        .withValues(alpha: 0.35),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  avatarInitial,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Edit Educator Profile',
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Personalize your salutation and institution',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: isDark
                                          ? AppColors.textMutedDark
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () => Navigator.pop(ctx),
                              style: IconButton.styleFrom(
                                backgroundColor: isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFF1F5F9),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),
                      Divider(
                        height: 1,
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF1F5F9),
                      ),

                      // Scrollable form body
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // SECTION: Salutation / Honorific
                              const Text(
                                'Preferred Title / Salutation',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: titleOptions.map((opt) {
                                  final title = opt['title']!;
                                  final isSelected = selectedTitle == title;
                                  return Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        setModalState(() {
                                          selectedTitle = title;
                                          if (title == 'Sir' || title == 'Mr.') {
                                            selectedGender = 'Male';
                                          } else if (title == 'Miss' ||
                                              title == 'Ms.') {
                                            selectedGender = 'Female';
                                          }
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(14),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 10),
                                        decoration: BoxDecoration(
                                          gradient: isSelected
                                              ? AppColors.primaryGradient
                                              : null,
                                          color: isSelected
                                              ? null
                                              : (isDark
                                                  ? const Color(0xFF1E293B)
                                                  : const Color(0xFFF1F5F9)),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.primaryLight
                                                : (isDark
                                                    ? const Color(0xFF334155)
                                                    : const Color(0xFFE2E8F0)),
                                            width: isSelected ? 1.8 : 1.0,
                                          ),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: AppColors
                                                        .primaryColor
                                                        .withValues(alpha: 0.35),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Text(
                                          title,
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: isSelected
                                                ? FontWeight.w900
                                                : FontWeight.w600,
                                            color: isSelected
                                                ? Colors.white
                                                : (isDark
                                                    ? Colors.white70
                                                    : const Color(0xFF334155)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),

                              const SizedBox(height: 18),

                              // SECTION: Gender Segmented Pill Selector
                              const Text(
                                'Gender (Optional)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  children: genderOptions.map((opt) {
                                    final val = opt['val'] as String;
                                    final label = opt['label'] as String;
                                    final icon = opt['icon'] as IconData;
                                    final isSelected = selectedGender == val;

                                    return Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          HapticFeedback.selectionClick();
                                          setModalState(() => selectedGender = val);
                                        },
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? (isDark
                                                    ? AppColors.primaryColor
                                                    : Colors.white)
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withValues(
                                                              alpha: 0.1),
                                                      blurRadius: 6,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                icon,
                                                size: 15,
                                                color: isSelected
                                                    ? (isDark
                                                        ? Colors.white
                                                        : AppColors.primaryColor)
                                                    : (isDark
                                                        ? Colors.white60
                                                        : const Color(0xFF64748B)),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                label,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: isSelected
                                                      ? FontWeight.w800
                                                      : FontWeight.w500,
                                                  color: isSelected
                                                      ? (isDark
                                                          ? Colors.white
                                                          : AppColors.primaryColor)
                                                      : (isDark
                                                          ? Colors.white60
                                                          : const Color(0xFF64748B)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),

                              const SizedBox(height: 18),

                              // SECTION: Teacher Name
                              CustomTextField(
                                label: 'Full Name',
                                controller: nameController,
                                hint: 'e.g. Alex Smith / Priya Patel',
                                prefixIcon: Icons.person_outline_rounded,
                                onChanged: (_) => setModalState(() {}),
                              ),

                              const SizedBox(height: 14),

                              // SECTION: Institution Type Segmented Chips
                              const Text(
                                'Institution Type',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: institutionOptions.map((opt) {
                                  final type = opt['type'] as String;
                                  final icon = opt['icon'] as IconData;
                                  final isSelected =
                                      selectedInstitutionType == type;

                                  return Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        setModalState(
                                            () => selectedInstitutionType = type);
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primaryColor
                                                  .withValues(alpha: 0.18)
                                              : (isDark
                                                  ? const Color(0xFF1E293B)
                                                  : const Color(0xFFF1F5F9)),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.primaryLight
                                                : (isDark
                                                    ? const Color(0xFF334155)
                                                    : const Color(0xFFE2E8F0)),
                                            width: isSelected ? 1.6 : 1.0,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              icon,
                                              size: 15,
                                              color: isSelected
                                                  ? AppColors.primaryLight
                                                  : (isDark
                                                      ? Colors.white60
                                                      : const Color(0xFF64748B)),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              type,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: isSelected
                                                    ? FontWeight.w800
                                                    : FontWeight.w500,
                                                color: isSelected
                                                    ? (isDark
                                                        ? Colors.white
                                                        : AppColors.primaryColor)
                                                    : (isDark
                                                        ? Colors.white70
                                                        : const Color(0xFF334155)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),

                              const SizedBox(height: 14),

                              // SECTION: Institution Name
                              CustomTextField(
                                label: '$selectedInstitutionType / Department Name',
                                controller: instituteController,
                                hint: selectedInstitutionType == 'School'
                                    ? 'e.g. Greenwood High School'
                                    : selectedInstitutionType == 'College'
                                        ? 'e.g. St. Xavier\'s College'
                                        : 'e.g. Stanford University / Tech Dept',
                                prefixIcon: Icons.account_balance_outlined,
                                onChanged: (_) => setModalState(() {}),
                              ),

                              const SizedBox(height: 14),

                              // SECTION: Email
                              CustomTextField(
                                label: 'Email (Optional)',
                                controller: emailController,
                                hint: 'teacher@institution.edu',
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                              ),

                              const SizedBox(height: 18),

                              // SECTION: Live Interactive Preview Card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF131D31)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFFE2E8F0),
                                    width: 1.2,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.visibility_rounded,
                                          size: 15,
                                          color: AppColors.primaryLight,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'LIVE PREVIEW',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.primaryLight,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '• Dashboard Welcome: "Welcome back, $previewGreeting"',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '• Parent Notice: "$previewNotice"',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? const Color(0xFF94A3B8)
                                            : const Color(0xFF64748B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // SECTION: Save Profile Button
                              Container(
                                width: double.infinity,
                                height: 54,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryColor
                                          .withValues(alpha: 0.35),
                                      blurRadius: 16,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(18),
                                    onTap: () {
                                      HapticFeedback.mediumImpact();
                                      context
                                          .read<SettingsCubit>()
                                          .updateTeacherProfile(
                                            title: selectedTitle,
                                            gender: selectedGender,
                                            name: nameController.text
                                                    .trim()
                                                    .isNotEmpty
                                                ? nameController.text.trim()
                                                : selectedTitle,
                                            institutionType:
                                                selectedInstitutionType,
                                            institute: instituteController
                                                    .text
                                                    .trim()
                                                    .isNotEmpty
                                                ? instituteController.text.trim()
                                                : '$selectedInstitutionType of Science & Tech',
                                            email: emailController.text.trim(),
                                          );
                                      Navigator.pop(ctx);
                                      AppSnackBar.showSuccess(
                                        context,
                                        'Educator profile updated successfully.',
                                        title: 'Profile Saved',
                                      );
                                    },
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check_circle_rounded,
                                            color: Colors.white, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'Save Profile Changes',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _toggleLectureReminders(
      BuildContext context, bool enable, SettingsModel settings) async {
    HapticFeedback.mediumImpact();

    if (enable) {
      final isGranted = await NotificationService().requestPermissions();

      if (!context.mounted) return;

      if (isGranted) {
        context.read<SettingsCubit>().updateReminderPreferences(
              enable: true,
              leadMinutes: settings.reminderLeadMinutes,
              vibration: settings.enableVibration,
            );
        AppSnackBar.showSuccess(
          context,
          'Lecture reminders activated. You will receive notifications prior to scheduled lectures.',
          title: 'Reminders Enabled',
        );
      } else {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.notifications_off_rounded,
                    color: AppColors.errorColor),
                SizedBox(width: 10),
                Text('Permissions Required'),
              ],
            ),
            content: const Text(
              'Notification and Alarm scheduling permissions are disabled. To receive lecture reminders, please grant permissions in system settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.settings, size: 18),
                label: const Text('Open System Settings'),
                onPressed: () {
                  Navigator.pop(ctx);
                  NotificationService().openNotificationSettings();
                },
              ),
            ],
          ),
        );
      }
    } else {
      context.read<SettingsCubit>().updateReminderPreferences(
            enable: false,
            leadMinutes: settings.reminderLeadMinutes,
            vibration: settings.enableVibration,
          );
      AppSnackBar.showInfo(
        context,
        'Lecture reminders have been paused.',
        title: 'Reminders Paused',
      );
    }
  }

  void _openSystemSettings() async {
    HapticFeedback.lightImpact();
    await NotificationService().openNotificationSettings();
  }

  void _createBackup(BuildContext context) async {
    HapticFeedback.heavyImpact();
    final db = context.read<ClassBloc>().database;
    final settings = context.read<SettingsCubit>().state.settings;
    await BackupService.exportDatabaseBackup(context, db, settings: settings);
  }

  void _restoreBackup(BuildContext context) async {
    HapticFeedback.heavyImpact();
    final db = context.read<ClassBloc>().database;
    final counts = await BackupService.restoreDatabaseBackup(context, db);

    if (counts != null && context.mounted) {
      context.read<ClassBloc>().add(LoadClasses());
      context.read<TimetableBloc>().add(LoadAllTimetable());
      if (counts['settings'] is Map<String, dynamic> &&
          (counts['settings'] as Map<String, dynamic>).isNotEmpty) {
        final restoredSettings =
            SettingsModel.fromMap(counts['settings'] as Map<String, dynamic>);
        context.read<SettingsCubit>().updateTeacherProfile(
              title: restoredSettings.teacherTitle,
              gender: restoredSettings.teacherGender,
              name: restoredSettings.teacherName,
              institutionType: restoredSettings.institutionType,
              institute: restoredSettings.instituteName,
              email: restoredSettings.teacherEmail,
            );
      }
    }
  }

  void _loadDemoData(BuildContext context) async {
    HapticFeedback.heavyImpact();
    final db = context.read<ClassBloc>().database;
    final settings = context.read<SettingsCubit>().state.settings;
    await DemoDataService.seedDemoData(db,
        isDailyMode: settings.isDailyAttendanceMode);

    if (!context.mounted) return;
    context.read<ClassBloc>().add(LoadClasses());
    context.read<TimetableBloc>().add(LoadAllTimetable());

    AppSnackBar.showSuccess(
      context,
      settings.isDailyAttendanceMode
          ? 'Loaded School Demo: Grade 10-A, Grade 9-B, 16 students, and full-day roll calls.'
          : 'Loaded College Demo: Computer Science & AI, Applied Physics, 16 students, and timetable.',
      title: 'Demo Dataset Active',
    );
  }

  void _resetDatabase(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset All App Data?'),
        content: const Text(
          'This will permanently delete all classes, students, attendance sessions, and timetable records. We recommend exporting a backup first.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.errorColor),
            onPressed: () async {
              Navigator.pop(ctx);
              final db = context.read<ClassBloc>().database;
              final dbHelper = DatabaseHelper(db);
              await dbHelper.clearAllData();

              if (!context.mounted) return;
              context.read<ClassBloc>().add(LoadClasses());
              context.read<TimetableBloc>().add(LoadAllTimetable());

              AppSnackBar.showWarning(
                context,
                'All classes, student records, attendance logs, and schedules have been wiped.',
                title: 'Database Cleared',
              );
            },
            child: const Text('Clear Everything'),
          ),
        ],
      ),
    );
  }

  void _switchTrackingMode(BuildContext context, String newMode) async {
    HapticFeedback.selectionClick();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settingsCubit = context.read<SettingsCubit>();
    final db = context.read<ClassBloc>().database;
    final currentSettings = settingsCubit.state.settings;
    final currentIsDaily = currentSettings.isDailyAttendanceMode;
    final targetIsDaily = newMode == 'FULL_DAY' || newMode == 'daily';

    if (currentIsDaily == targetIsDaily) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCardElevated : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.warning_amber_rounded,
            color: AppColors.absentColor, size: 36),
        title: const Text('Change Tracking System Mode?'),
        content: const Text(
          'Warning: Changing your tracking mode alters how your 75% compliance rates are calculated. Existing records will be preserved, but new entries will follow the new system schema.',
          style: TextStyle(fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm Switch'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await DatabaseHelper(db).reconcileTrackingMode(newMode);
      await settingsCubit.updateAttendanceFrequency(newMode);

      if (!context.mounted) return;
      AppSnackBar.showSuccess(
        context,
        newMode == 'FULL_DAY'
            ? 'Tracking system configured to FULL_DAY master roll call.'
            : 'Tracking system configured to PERIOD_WISE timetable mode.',
        title: 'Mode Updated',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Preferences'),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final settings = state.settings;

          return ListView(
            padding: EdgeInsets.fromLTRB(
                16, 12, 16, MediaQuery.paddingOf(context).bottom + 130),
            children: [
              // Teacher Profile Card
              Container(
                decoration: BoxDecoration(
                  gradient: isDark
                      ? AppColors.heroGradientDark
                      : AppColors.heroGradientLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1.2,
                  ),
                ),
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor:
                          AppColors.primaryColor.withValues(alpha: 0.15),
                      child: Text(
                        settings.teacherName.isNotEmpty
                            ? settings.teacherName[0].toUpperCase()
                            : 'T',
                        style: const TextStyle(
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            settings.fullTeacherTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            settings.instituteName,
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          color: AppColors.primaryLight),
                      tooltip: 'Edit Profile',
                      onPressed: () => _editTeacherProfile(
                        context,
                        settings,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // SECTION: Theme & Appearance
              _buildSectionHeader('Appearance & Theme'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCardBackground : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color:
                        isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1.2,
                  ),
                ),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    _buildThemePill(
                      context,
                      label: 'System',
                      icon: Icons.brightness_auto_rounded,
                      isSelected:
                          context.watch<ThemeCubit>().state == ThemeMode.system,
                      onTap: () => context
                          .read<ThemeCubit>()
                          .setThemeMode(ThemeMode.system),
                    ),
                    const SizedBox(width: 8),
                    _buildThemePill(
                      context,
                      label: 'Light',
                      icon: Icons.light_mode_rounded,
                      isSelected:
                          context.watch<ThemeCubit>().state == ThemeMode.light,
                      onTap: () => context
                          .read<ThemeCubit>()
                          .setThemeMode(ThemeMode.light),
                    ),
                    const SizedBox(width: 8),
                    _buildThemePill(
                      context,
                      label: 'OLED Dark',
                      icon: Icons.dark_mode_rounded,
                      isSelected:
                          context.watch<ThemeCubit>().state == ThemeMode.dark,
                      onTap: () => context
                          .read<ThemeCubit>()
                          .setThemeMode(ThemeMode.dark),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // SECTION: Student Roster Templates
              _buildSectionHeader('Student Roster Templates'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCardBackground : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color:
                        isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1.2,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.table_chart_rounded,
                            color: Colors.green, size: 20),
                      ),
                      title: const Text('Example Excel Template (.xlsx)',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text(
                          'Export a ready-to-use example Excel spreadsheet for student roster imports.',
                          style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right_rounded,
                          color: Colors.grey),
                      onTap: () =>
                          ExcelHelper.exportSampleExcelTemplate(context),
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.teal.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.description_outlined,
                            color: Colors.teal, size: 20),
                      ),
                      title: const Text('Example CSV Template (.csv)',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text(
                          'Export a ready-to-use example CSV file for student roster imports.',
                          style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right_rounded,
                          color: Colors.grey),
                      onTap: () => ExcelHelper.exportSampleCsvTemplate(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // SECTION: Attendance Preferences
              _buildSectionHeader('Attendance Preferences'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCardBackground : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color:
                        isDark ? AppColors.darkBorder : AppColors.lightBorder,
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
                        const Text(
                          'Defaulter Alert Threshold',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                AppColors.absentColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.absentColor
                                    .withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            '< ${settings.defaulterThreshold.toInt()}%',
                            style: const TextStyle(
                              color: AppColors.absentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Students with attendance below this percentage will be flagged as defaulters.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMuted,
                      ),
                    ),
                    Slider(
                      value: settings.defaulterThreshold,
                      min: 50.0,
                      max: 90.0,
                      divisions: 8,
                      activeColor: AppColors.primaryColor,
                      label: '${settings.defaulterThreshold.toInt()}%',
                      onChanged: (val) {
                        context
                            .read<SettingsCubit>()
                            .updateDefaulterThreshold(val);
                      },
                    ),
                    const Divider(),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Default Status to Present',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(
                        'Pre-select "Present" when taking attendance for quicker session logging.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMuted,
                        ),
                      ),
                      value: settings.defaultAttendancePresent,
                      activeThumbColor: AppColors.presentColor,
                      onChanged: (val) {
                        context
                            .read<SettingsCubit>()
                            .updateDefaultAttendanceStatus(val);
                      },
                    ),
                    const SizedBox(height: 14),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Dedicated Attendance Mode Box with Padding & Polish
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkCardElevated.withValues(alpha: 0.6)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.tune_rounded,
                                size: 18,
                                color: AppColors.primaryLight,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Tracking Mode',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.primaryColor
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  settings.isDailyAttendanceMode
                                      ? 'FULL_DAY'
                                      : 'PERIOD_WISE',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Choose how roll call is logged across your institution classes.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              // Full-Day Roll Call Card
                              Expanded(
                                child: InkWell(
                                  onTap: () =>
                                      _switchTrackingMode(context, 'FULL_DAY'),
                                  borderRadius: BorderRadius.circular(14),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: settings.isDailyAttendanceMode
                                          ? AppColors.primaryColor
                                              .withValues(alpha: isDark ? 0.28 : 0.14)
                                          : (isDark
                                              ? AppColors.darkCardBackground
                                              : Colors.white),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: settings.isDailyAttendanceMode
                                            ? AppColors.primaryLight
                                            : (isDark
                                                ? AppColors.darkBorder
                                                : Colors.grey[300]!),
                                        width: settings.isDailyAttendanceMode
                                            ? 2.0
                                            : 1.0,
                                      ),
                                      boxShadow: settings.isDailyAttendanceMode
                                          ? [
                                              BoxShadow(
                                                color: AppColors.primaryColor
                                                    .withValues(alpha: 0.2),
                                                blurRadius: 10,
                                                offset: const Offset(0, 3),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Icon(
                                              Icons.school_rounded,
                                              size: 20,
                                              color: settings.isDailyAttendanceMode
                                                  ? AppColors.primaryLight
                                                  : Colors.grey,
                                            ),
                                            if (settings.isDailyAttendanceMode)
                                              const Icon(
                                                Icons.check_circle_rounded,
                                                size: 16,
                                                color: AppColors.primaryLight,
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Full-Day Roll Call',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.5,
                                            color: settings.isDailyAttendanceMode
                                                ? AppColors.primaryLight
                                                : (isDark
                                                    ? Colors.white
                                                    : Colors.black87),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '1 master record / day (Schools)',
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            color: isDark
                                                ? AppColors.textMutedDark
                                                : AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Period-Wise Card
                              Expanded(
                                child: InkWell(
                                  onTap: () => _switchTrackingMode(
                                      context, 'PERIOD_WISE'),
                                  borderRadius: BorderRadius.circular(14),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: !settings.isDailyAttendanceMode
                                          ? AppColors.primaryColor
                                              .withValues(alpha: isDark ? 0.28 : 0.14)
                                          : (isDark
                                              ? AppColors.darkCardBackground
                                              : Colors.white),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: !settings.isDailyAttendanceMode
                                            ? AppColors.primaryLight
                                            : (isDark
                                                ? AppColors.darkBorder
                                                : Colors.grey[300]!),
                                        width: !settings.isDailyAttendanceMode
                                            ? 2.0
                                            : 1.0,
                                      ),
                                      boxShadow: !settings.isDailyAttendanceMode
                                          ? [
                                              BoxShadow(
                                                color: AppColors.primaryColor
                                                    .withValues(alpha: 0.2),
                                                blurRadius: 10,
                                                offset: const Offset(0, 3),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Icon(
                                              Icons.access_time_filled_rounded,
                                              size: 20,
                                              color: !settings.isDailyAttendanceMode
                                                  ? AppColors.primaryLight
                                                  : Colors.grey,
                                            ),
                                            if (!settings.isDailyAttendanceMode)
                                              const Icon(
                                                Icons.check_circle_rounded,
                                                size: 16,
                                                color: AppColors.primaryLight,
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Per Lecture Slot',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.5,
                                            color: !settings.isDailyAttendanceMode
                                                ? AppColors.primaryLight
                                                : (isDark
                                                    ? Colors.white
                                                    : Colors.black87),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Period timetable (Colleges)',
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            color: isDark
                                                ? AppColors.textMutedDark
                                                : AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // SECTION: Lecture Notification Reminders
              _buildSectionHeader('Timetable & Lecture Reminders'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCardBackground : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color:
                        isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1.2,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Enable Lecture Reminders',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(
                        'Get notified prior to scheduled classes based on your weekly timetable.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMuted,
                        ),
                      ),
                      value: settings.enableLectureReminders,
                      activeThumbColor: AppColors.primaryColor,
                      onChanged: (val) =>
                          _toggleLectureReminders(context, val, settings),
                    ),
                    if (settings.enableLectureReminders) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Divider(height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor
                                        .withValues(alpha: isDark ? 0.18 : 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.access_time_rounded,
                                    size: 18,
                                    color: AppColors.primaryLight,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Reminder Lead Time',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Alert before start',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark
                                              ? AppColors.textMutedDark
                                              : AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkCardElevated
                                  : AppColors.lightCardElevated,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                                width: 1.2,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: settings.reminderLeadMinutes,
                                dropdownColor: isDark
                                    ? AppColors.darkCardBackground
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: AppColors.primaryLight,
                                    size: 18),
                                items: const [
                                  DropdownMenuItem(
                                      value: 5,
                                      child: Text('5m before',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600))),
                                  DropdownMenuItem(
                                      value: 10,
                                      child: Text('10m before',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600))),
                                  DropdownMenuItem(
                                      value: 15,
                                      child: Text('15m before',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600))),
                                  DropdownMenuItem(
                                      value: 30,
                                      child: Text('30m before',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600))),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    context
                                        .read<SettingsCubit>()
                                        .updateReminderPreferences(
                                          enable:
                                              settings.enableLectureReminders,
                                          leadMinutes: val,
                                          vibration: settings.enableVibration,
                                        );
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _openSystemSettings,
                        icon: const Icon(Icons.tune_rounded, size: 18),
                        label: const Text('Open App Notification Settings'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(42),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // SECTION: Information & About App
              _buildSectionHeader('Information & About'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCardBackground : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color:
                        isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1.2,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.school_rounded,
                            color: Colors.white, size: 20),
                      ),
                      title: const Text('About ClassTrack',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text(
                          'Architecture details, offline privacy model, tech stack & version.',
                          style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right_rounded,
                          color: Colors.grey),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AboutAppScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // SECTION: Data & Maintenance
              _buildSectionHeader('Data Management & Backup'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCardBackground : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color:
                        isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1.2,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor
                              .withValues(alpha: isDark ? 0.2 : 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.cloud_upload_rounded,
                            color: AppColors.primaryLight, size: 20),
                      ),
                      title: const Text('Export Full Database Backup',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text(
                          'Save all classes, student rosters, attendance logs, timetables, and settings to a JSON backup file.',
                          style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right_rounded,
                          color: Colors.grey),
                      onTap: () => _createBackup(context),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Divider(height: 1),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.presentColor
                              .withValues(alpha: isDark ? 0.2 : 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.cloud_download_rounded,
                            color: AppColors.presentColor, size: 20),
                      ),
                      title: const Text('Restore Database from Backup',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text(
                          'Import and restore all records from a previously exported ClassTrack backup file.',
                          style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right_rounded,
                          color: Colors.grey),
                      onTap: () => _restoreBackup(context),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Divider(height: 1),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B)
                              .withValues(alpha: isDark ? 0.2 : 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.science_rounded,
                            color: Color(0xFFF59E0B), size: 20),
                      ),
                      title: const Text('Load Sample Demo Dataset',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text(
                          'Populate sample classes, 16 students, attendance logs, and weekly timetable.',
                          style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right_rounded,
                          color: Colors.grey),
                      onTap: () => _loadDemoData(context),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Divider(height: 1),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.errorColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delete_sweep_rounded,
                            color: AppColors.errorColor, size: 20),
                      ),
                      title: const Text('Reset All Application Data',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text(
                          'Clear all classes, students, sessions, and timetable records.',
                          style: TextStyle(fontSize: 12)),
                      onTap: () => _resetDatabase(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // About Footer
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.school_rounded,
                              color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'ClassTrack',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Version 1.0.0 • Professional Edition',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildThemePill(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryColor.withValues(alpha: isDark ? 0.25 : 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primaryColor : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.primaryLight : Colors.grey,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.primaryLight : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
