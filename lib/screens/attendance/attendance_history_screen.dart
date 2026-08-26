import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/attendance/attendance_bloc.dart';
import '../../bloc/attendance/attendance_event.dart';
import '../../bloc/attendance/attendance_state.dart';
import '../../database/database_helper.dart';
import '../../models/attendance_model.dart';
import '../../models/attendance_record_model.dart';
import '../../theme/colors.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/custom_button.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  final int classId;
  final String className;

  const AttendanceHistoryScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    context.read<AttendanceBloc>().add(LoadAttendanceRecords(widget.classId));
  }

  void _viewSessionDetails(AttendanceRecordModel record) async {
    final dbHelper = DatabaseHelper(context.read<AttendanceBloc>().database);
    final details = await dbHelper.getAttendanceDetailsByRecordId(record.id!);

    if (!mounted) return;

    final updatedStatuses = <int, AttendanceStatus>{};
    for (final row in details) {
      final sId = row['studentId'] as int;
      final statusIdx = row['status'] as int;
      updatedStatuses[sId] = AttendanceStatus.values[statusIdx];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardBackground : Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1.2,
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              16 + MediaQuery.paddingOf(context).bottom,
            ),
            child: SafeArea(
              top: false,
              child: Column(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Session Details',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${DateFormatter.formatDate(record.date)} • ${record.time}',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Session summary pills
                  Row(
                    children: [
                      _buildSummaryPill('Present: ${record.presentCount}',
                          AppColors.presentColor),
                      const SizedBox(width: 8),
                      _buildSummaryPill(
                          'Absent: ${record.absentCount}', AppColors.absentColor),
                      const SizedBox(width: 8),
                      _buildSummaryPill(
                          'Late: ${record.lateCount}', AppColors.lateColor),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tap status to edit retroactively:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.separated(
                      itemCount: details.length,
                      separatorBuilder: (context, i) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = details[index];
                        final sId = item['studentId'] as int;
                        final currentStatus =
                            updatedStatuses[sId] ?? AttendanceStatus.present;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: 0.15),
                                child: Text(
                                  (item['studentName'] as String).isNotEmpty
                                      ? (item['studentName'] as String)[0]
                                          .toUpperCase()
                                      : '#',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['studentName'] as String,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Roll: ${item['rollNo']}',
                                      style: TextStyle(
                                        color: isDark
                                            ? AppColors.textMutedDark
                                            : AppColors.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Quick status toggles
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildStatusToggle(
                                    AttendanceStatus.present,
                                    currentStatus == AttendanceStatus.present,
                                    () {
                                      setModalState(() {
                                        updatedStatuses[sId] =
                                            AttendanceStatus.present;
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 4),
                                  _buildStatusToggle(
                                    AttendanceStatus.late,
                                    currentStatus == AttendanceStatus.late,
                                    () {
                                      setModalState(() {
                                        updatedStatuses[sId] =
                                            AttendanceStatus.late;
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 4),
                                  _buildStatusToggle(
                                    AttendanceStatus.absent,
                                    currentStatus == AttendanceStatus.absent,
                                    () {
                                      setModalState(() {
                                        updatedStatuses[sId] =
                                            AttendanceStatus.absent;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'Save Session Changes',
                    icon: Icons.save,
                    onPressed: () {
                      this.context.read<AttendanceBloc>().add(
                            UpdatePastAttendanceSession(
                              recordId: record.id!,
                              classId: widget.classId,
                              updatedStatuses: updatedStatuses,
                            ),
                          );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Session attendance updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusToggle(
    AttendanceStatus status,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? status.color : status.lightColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? status.color : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          status.shortLabel,
          style: TextStyle(
            color: isSelected ? Colors.white : status.color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _deleteSession(AttendanceRecordModel record) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Session'),
        content: Text(
          'Are you sure you want to delete the attendance session for ${DateFormatter.formatDate(record.date)} at ${record.time}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.errorColor),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AttendanceBloc>().add(
                    DeleteAttendanceRecord(record.id!, widget.classId),
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Attendance session deleted'),
                  backgroundColor: AppColors.errorColor,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.className} History'),
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<AttendanceBloc, AttendanceState>(
          builder: (context, state) {
            if (state is AttendanceLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AttendanceRecordsLoaded) {
              final records = state.records;

              if (records.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCardElevated
                              : AppColors.lightCardElevated,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.history_toggle_off_rounded,
                          size: 56,
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Attendance Sessions Yet',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Past attendance recordings will appear here.',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMuted,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => _loadHistory(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
                  itemCount: records.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildTopAnalyticsHero(context, records, isDark);
                    }

                    final record = records[index - 1];
                    return _buildHistorySessionCard(context, record, isDark);
                  },
                ),
              );
            } else if (state is AttendanceError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: AppColors.errorColor),
                ),
              );
            }
            return const Center(child: Text('Loading history...'));
          },
        ),
      ),
    );
  }

  Widget _buildTopAnalyticsHero(
    BuildContext context,
    List<AttendanceRecordModel> records,
    bool isDark,
  ) {
    final totalSessions = records.length;
    final avgPercentage = records.isEmpty
        ? 0.0
        : records.fold<double>(0, (sum, r) => sum + r.attendancePercentage) /
            totalSessions;
    final rateColor =
        AttendanceStatusExtension.getColorForPercentage(avgPercentage);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color:
                (isDark ? Colors.black : Colors.blueGrey).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          AppColors.primaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.auto_graph_rounded,
                      size: 18,
                      color: AppColors.primaryLight,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'History Overview',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: rateColor.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: rateColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  avgPercentage >= 75 ? 'Healthy Attendance' : 'Low Attendance',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: rateColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildHeroStatItem(
                  'Total Sessions',
                  '$totalSessions Logged',
                  Icons.event_note_rounded,
                  AppColors.primaryLight,
                  isDark,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              Expanded(
                child: _buildHeroStatItem(
                  'Average Rate',
                  '${avgPercentage.toStringAsFixed(1)}%',
                  Icons.pie_chart_outline_rounded,
                  rateColor,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStatItem(
    String label,
    String value,
    IconData icon,
    Color accentColor,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: accentColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMuted,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySessionCard(
    BuildContext context,
    AttendanceRecordModel record,
    bool isDark,
  ) {
    final total = record.totalStudents;
    final percentage = record.attendancePercentage;
    final rateColor =
        AttendanceStatusExtension.getColorForPercentage(percentage);

    final parsedDate = DateTime.tryParse(record.date);
    final dayNumber = parsedDate != null ? '${parsedDate.day}' : '';
    final monthShort = parsedDate != null
        ? DateFormatter.formatDate(record.date).split(' ')[1].replaceAll(',', '')
        : 'REC';
    final weekday = parsedDate != null
        ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][parsedDate.weekday - 1]
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.blueGrey)
                .withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _viewSessionDetails(record),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Calendar Block + Date/Time + Percentage + Menu
              Row(
                children: [
                  // Structured Calendar Date Badge
                  Container(
                    width: 48,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkCardElevated
                          : AppColors.lightCardElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor
                                .withValues(alpha: isDark ? 0.25 : 0.15),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(11)),
                          ),
                          child: Text(
                            monthShort.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryLight,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              dayNumber,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color:
                                    isDark ? Colors.white : AppColors.textDark,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Date, Day & Time column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormatter.formatDate(record.date),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              weekday.isNotEmpty ? '$weekday • ' : '',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.textMutedDark
                                    : AppColors.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMuted,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              record.time,
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.textMutedDark
                                    : AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Rate Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: rateColor.withValues(alpha: isDark ? 0.18 : 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: rateColor.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: rateColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${percentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: rateColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Overflow Options Popup Menu
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      size: 20,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMuted,
                    ),
                    onSelected: (val) {
                      if (val == 'details') {
                        _viewSessionDetails(record);
                      } else if (val == 'delete') {
                        _deleteSession(record);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'details',
                        child: Row(
                          children: [
                            Icon(Icons.edit_note_rounded, size: 18),
                            SizedBox(width: 8),
                            Text('View & Edit Details'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded,
                                color: AppColors.errorColor, size: 18),
                            SizedBox(width: 8),
                            Text('Delete Session',
                                style: TextStyle(color: AppColors.errorColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Segmented Attendance Distribution Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: SizedBox(
                  height: 6,
                  child: total == 0
                      ? Container(color: Colors.grey.withValues(alpha: 0.2))
                      : Row(
                          children: [
                            if (record.presentCount > 0)
                              Expanded(
                                flex: record.presentCount,
                                child: Container(color: AppColors.presentColor),
                              ),
                            if (record.lateCount > 0)
                              Expanded(
                                flex: record.lateCount,
                                child: Container(color: AppColors.lateColor),
                              ),
                            if (record.absentCount > 0)
                              Expanded(
                                flex: record.absentCount,
                                child: Container(color: AppColors.absentColor),
                              ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // Grid of 4 Structured Metric Pill Cards (Eliminates dead space!)
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'Present',
                      '${record.presentCount}',
                      AppColors.presentColor,
                      Icons.check_circle_rounded,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildMetricCard(
                      'Late',
                      '${record.lateCount}',
                      AppColors.lateColor,
                      Icons.schedule_rounded,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildMetricCard(
                      'Absent',
                      '${record.absentCount}',
                      AppColors.absentColor,
                      Icons.cancel_rounded,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildMetricCard(
                      'Total',
                      '$total',
                      isDark ? Colors.white : AppColors.textDark,
                      Icons.groups_rounded,
                      isDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Footer prompt: Tap to inspect breakdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tap to view student attendance list',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textMutedDark.withValues(alpha: 0.7)
                          : AppColors.textMuted.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 11,
                    color: isDark
                        ? AppColors.textMutedDark.withValues(alpha: 0.7)
                        : AppColors.textMuted.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String label,
    String count,
    Color color,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.8,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(height: 3),
          Text(
            count,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
