// ignore_for_file: unreachable_switch_default

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/attendance/attendance_bloc.dart';
import '../../bloc/attendance/attendance_event.dart';
import '../../bloc/attendance/attendance_state.dart';
import '../../models/student_model.dart';
import '../../models/attendance_model.dart';
import '../../theme/colors.dart';

class TakeAttendanceScreen extends StatefulWidget {
  final int classId;
  final List<StudentModel> students;

  const TakeAttendanceScreen({
    super.key,
    required this.classId,
    required this.students,
  });

  @override
  State<TakeAttendanceScreen> createState() => _TakeAttendanceScreenState();
}

class _TakeAttendanceScreenState extends State<TakeAttendanceScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  final Map<int, AttendanceStatus> _attendanceMap = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Initialize attendance map with default values
    for (var student in widget.students) {
      if (student.id != null) {
        _attendanceMap[student.id!] = AttendanceStatus.present;
      }
    }

    // Load the attendance session using BLoC
    context.read<AttendanceBloc>().add(LoadAttendanceSession(widget.classId));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStudent() {
    if (_currentIndex < widget.students.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStudent() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _markAttendance(AttendanceStatus status) {
    final student = widget.students[_currentIndex];
    if (student.id != null) {
      // Update local map for immediate UI feedback
      setState(() {
        _attendanceMap[student.id!] = status;
      });

      // Use BLoC's MarkAttendance event with both status and studentId
      context.read<AttendanceBloc>().add(MarkAttendance(status, student.id!));

      // Automatically move to next student after marking attendance
      Future.delayed(const Duration(milliseconds: 200), () {
        if (_currentIndex < widget.students.length - 1) {
          _nextStudent();
        }
      });
    }
  }

  void _submitAttendance() {
    final bloc = context.read<AttendanceBloc>();
    final state = bloc.state;

    if (state is AttendanceSessionReady) {
      // Check if all students have been marked in BLoC state
      if (state.studentStatus.length == state.students.length) {
        // All marked, submit
        bloc.add(SubmitAttendance());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Please mark attendance for all students (${state.studentStatus.length}/${state.students.length})'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else if (state is AttendanceSessionComplete) {
      // Already complete, just submit
      bloc.add(SubmitAttendance());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot submit: attendance session not ready'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.students.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Take Attendance'),
        ),
        body: const Center(
          child: Text('No students found in this class'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Take Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Instructions'),
                  content: const Text(
                      'Swipe left to mark as present and go to next student\n'
                      'Swipe right to go to previous student\n'
                      'Tap the status buttons to mark attendance\n'
                      'Submit when all students are marked'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: BlocListener<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceSubmitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Attendance saved successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(
                context, true); // Return true to indicate data changed
          } else if (state is AttendanceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<AttendanceBloc, AttendanceState>(
          builder: (context, state) {
            if (state is AttendanceLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AttendanceSubmitting) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Saving attendance...'),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Date display
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Student counter and progress
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Text(
                        'Student ${_currentIndex + 1} of ${widget.students.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: (_currentIndex + 1) / widget.students.length,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Student card with swipe functionality
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemCount: widget.students.length,
                      itemBuilder: (context, index) {
                        final student = widget.students[index];
                        final currentStatus = student.id != null
                            ? _attendanceMap[student.id!] ??
                                AttendanceStatus.present
                            : AttendanceStatus.present;

                        return GestureDetector(
                          onHorizontalDragEnd: (details) {
                            if (details.primaryVelocity! > 0) {
                              // Swiped right - Previous student
                              _previousStudent();
                            } else if (details.primaryVelocity! < 0) {
                              // Swiped left - Mark as PRESENT and move to next student
                              _markAttendance(AttendanceStatus.present);
                            }
                          },
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Student avatar
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.2),
                                    child: Text(
                                      student.name.isNotEmpty
                                          ? student.name[0].toUpperCase()
                                          : '#',
                                      style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // Student name
                                  Text(
                                    student.name,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  const SizedBox(height: 6),

                                  // Roll number
                                  Text(
                                    'Roll No: ${student.rollNo}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // Current status indicator
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(currentStatus)
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Status: ${currentStatus.label}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _getStatusColor(currentStatus),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Swipe instruction
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.swipe, color: Colors.blue[700], size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Swipe left/right to navigate students',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Attendance buttons - Fixed layout
                Container(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          // Absent button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _markAttendance(AttendanceStatus.absent),
                              icon: const Icon(Icons.cancel,
                                  color: Colors.white, size: 18),
                              label: const Text(
                                'Absent',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.absentColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Present button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _markAttendance(AttendanceStatus.present),
                              icon: const Icon(Icons.check_circle,
                                  color: Colors.white, size: 18),
                              label: const Text(
                                'Present',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.presentColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Late button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _markAttendance(AttendanceStatus.late),
                              icon: const Icon(Icons.access_time,
                                  color: Colors.white, size: 18),
                              label: const Text(
                                'Late',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.lateColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _submitAttendance,
                          icon: const Icon(Icons.save,
                              color: Colors.white, size: 18),
                          label: const Text(
                            'Submit Attendance',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return AppColors.presentColor;
      case AttendanceStatus.late:
        return AppColors.lateColor;
      case AttendanceStatus.absent:
        return AppColors.absentColor;
      default:
        return Colors.grey;
    }
  }
}
