import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/attendance/attendance_bloc.dart';
import '../../bloc/attendance/attendance_event.dart';
import '../../bloc/attendance/attendance_state.dart';
import '../../models/attendance_model.dart';
import '../../models/student_model.dart';
import '../../theme/colors.dart';
import '../../widgets/attendance_chart.dart';
import '../../widgets/custom_button.dart';

class AttendanceSummaryScreen extends StatelessWidget {
  final int classId;
  final List<StudentModel> students;
  final Map<int, AttendanceStatus> studentStatus;

  const AttendanceSummaryScreen({
    super.key,
    required this.classId,
    required this.students,
    required this.studentStatus,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate attendance counts
    int presentCount = 0;
    int absentCount = 0;
    int lateCount = 0;

    for (var status in studentStatus.values) {
      if (status == AttendanceStatus.present) {
        presentCount++;
      } else if (status == AttendanceStatus.absent) {
        absentCount++;
      } else if (status == AttendanceStatus.late) {
        lateCount++;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Summary'),
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is AttendanceSubmitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Attendance saved successfully')),
            );
            // Use popUntil to return to the class dashboard screen
            Navigator.of(context).popUntil((route) => route.isFirst || route.settings.name == 'class_dashboard');
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Success icon
                const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.presentColor,
                  size: 64,
                ),
                const SizedBox(height: 16),
                
                // Success message
                const Text(
                  'Attendance Recorded!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Attendance chart
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Today\'s Attendance',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        AttendancePieChart(
                          present: presentCount,
                          absent: absentCount,
                          late: lateCount,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // View details button
                CustomButton(
                  text: 'View Student Details',
                  icon: Icons.list_alt,
                  onPressed: () {
                    _showAttendanceDetails(context);
                  },
                  backgroundColor: Colors.grey[800],
                  textColor: Colors.white,
                ),
                const SizedBox(height: 16),
                
                // Submit button
                if (state is AttendanceSubmitting)
                  const Center(child: CircularProgressIndicator())
                else
                  CustomButton(
                    text: 'Submit Attendance',
                    icon: Icons.save,
                    onPressed: () {
                      // Add debug print to verify the button is clicked
                      print('Submit attendance button clicked');
                      // Dispatch the SubmitAttendance event to the bloc
                      context.read<AttendanceBloc>().add(SubmitAttendance());
                    },
                    backgroundColor: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAttendanceDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                child: Row(
                  children: [
                    const Text(
                      'Student Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final status = studentStatus[student.id];
                    
                    IconData statusIcon;
                    Color statusColor;
                    String statusText;
                    
                    if (status == AttendanceStatus.present) {
                      statusIcon = Icons.check_circle_outline;
                      statusColor = AppColors.presentColor;
                      statusText = 'Present';
                    } else if (status == AttendanceStatus.absent) {
                      statusIcon = Icons.cancel_outlined;
                      statusColor = AppColors.absentColor;
                      statusText = 'Absent';
                    } else {
                      statusIcon = Icons.access_time;
                      statusColor = AppColors.lateColor;
                      statusText = 'Late';
                    }
                    
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                        child: Text(
                          student.name.isNotEmpty 
                              ? student.name[0].toUpperCase()
                              : '#',
                        ),
                      ),
                      title: Text(student.name),
                      subtitle: Text('Roll No: ${student.rollNo}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusIcon,
                            color: statusColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Edit button to change status
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () {
                              _editStudentStatus(context, student);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _editStudentStatus(BuildContext context, StudentModel student) {
    final currentStatus = studentStatus[student.id] ?? AttendanceStatus.present;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Change Status for ${student.name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatusOption(
                      context,
                      status: AttendanceStatus.present,
                      currentStatus: currentStatus,
                      onTap: () {
                        const newStatus = AttendanceStatus.present;
                        setState(() => studentStatus[student.id!] = newStatus);
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildStatusOption(
                      context,
                      status: AttendanceStatus.absent,
                      currentStatus: currentStatus,
                      onTap: () {
                        const newStatus = AttendanceStatus.absent;
                        setState(() => studentStatus[student.id!] = newStatus);
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildStatusOption(
                      context,
                      status: AttendanceStatus.late,
                      currentStatus: currentStatus,
                      onTap: () {
                        const newStatus = AttendanceStatus.late;
                        setState(() => studentStatus[student.id!] = newStatus);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusOption(
    BuildContext context, {
    required AttendanceStatus status,
    required AttendanceStatus currentStatus,
    required VoidCallback onTap,
  }) {
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String label;

    switch (status) {
      case AttendanceStatus.present:
        backgroundColor = currentStatus == status 
            ? AppColors.presentColor 
            : AppColors.presentColor.withOpacity(0.1);
        textColor = currentStatus == status 
            ? Colors.white 
            : AppColors.presentColor;
        icon = Icons.check_circle_outline;
        label = 'Present';
        break;
      case AttendanceStatus.absent:
        backgroundColor = currentStatus == status 
            ? AppColors.absentColor 
            : AppColors.absentColor.withOpacity(0.1);
        textColor = currentStatus == status 
            ? Colors.white 
            : AppColors.absentColor;
        icon = Icons.cancel_outlined;
        label = 'Absent';
        break;
      case AttendanceStatus.late:
        backgroundColor = currentStatus == status 
            ? AppColors.lateColor 
            : AppColors.lateColor.withOpacity(0.1);
        textColor = currentStatus == status 
            ? Colors.white 
            : AppColors.lateColor;
        icon = Icons.access_time;
        label = 'Late';
        break;
    }

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 100,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: currentStatus == status
                ? [
                    BoxShadow(
                      color: backgroundColor.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: textColor,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
