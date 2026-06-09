// screens/reports/download_report_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../bloc/attendance/attendance_bloc.dart';
import '../../bloc/attendance/attendance_event.dart';
import '../../bloc/attendance/attendance_state.dart';
import '../../bloc/class/class_bloc.dart';
import '../../bloc/class/class_event.dart';
import '../../database/database_helper.dart';
import '../../theme/colors.dart';
import '../../utils/csv_helper.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class DownloadReportScreen extends StatefulWidget {
  final int classId;
  final String className;

  const DownloadReportScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<DownloadReportScreen> createState() => _DownloadReportScreenState();
}

class _DownloadReportScreenState extends State<DownloadReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  String? _exportPath;
  
  @override
  void initState() {
    super.initState();
    context.read<AttendanceBloc>().add(LoadAttendanceRecords(widget.classId));
  }
  
  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }
  
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        _startDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        
        // Reset end date if it's before start date
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
          _endDateController.clear();
        }
      });
    }
  }
  
  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
        _endDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }
  
  Future<void> _generateReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      // Get database helper
      final database = context.read<AttendanceBloc>().database;
      final dbHelper = DatabaseHelper(database);
      
      // Get all students for the class
      final students = await dbHelper.getStudents(widget.classId);
      
      // Generate report data
      List<Map<String, dynamic>> reportData = [];
      
      for (var student in students) {
        final performance = await dbHelper.getStudentPerformance(student.id!);
        
        reportData.add({
          'rollNo': student.rollNo,
          'name': student.name,
          'total': performance['total'],
          'present': performance['present'],
          'absent': performance['absent'],
          'late': performance['late'],
          'percentage': performance['percentage'],
        });
      }
      
      // Sort by roll number
      reportData.sort((a, b) => a['rollNo'].compareTo(b['rollNo']));
      
      // Export to CSV
      final csvPath = await ExcelHelper.exportAttendanceToExcel(
        className: widget.className,
        data: reportData,
        onError: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        },
      );
      
      setState(() {
        _exportPath = csvPath;
        _isLoading = false;
      });
      
      if (csvPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report saved to: $csvPath')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating report: $e')),
      );
    }
  }
  
  void _shareReport() {
    if (_exportPath != null) {
      Share.shareFiles(
        [_exportPath!],
        text: 'Attendance Report for ${widget.className}',
      );
    }
  }
  
  void _navigateBack() {
    // Ensure the ClassBloc reloads classes when navigating back
    context.read<ClassBloc>().add(LoadClasses());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Report'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateBack,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocListener<AttendanceBloc, AttendanceState>(
          listener: (context, state) {
            if (state is AttendanceError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    'Generate Attendance Report',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create a CSV report of student attendance for a specific date range.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Class info
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.class_,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Class:',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                Text(
                                  widget.className,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Date selection
                  const Text(
                    'Select Date Range',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Start Date',
                          controller: _startDateController,
                          hint: 'YYYY-MM-DD',
                          isRequired: true,
                          readOnly: true,
                          prefixIcon: Icons.calendar_today,
                          onTap: () => _selectStartDate(context),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a start date';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          label: 'End Date',
                          controller: _endDateController,
                          hint: 'YYYY-MM-DD',
                          isRequired: true,
                          readOnly: true,
                          prefixIcon: Icons.calendar_today,
                          onTap: () => _selectEndDate(context),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select an end date';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Generate button
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_exportPath == null)
                    CustomButton(
                      text: 'Generate Report',
                      icon: Icons.download_rounded,
                      onPressed: _generateReport,
                      backgroundColor: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                    )
                  else
                    Column(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.presentColor,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Report Generated Successfully!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Saved to: $_exportPath',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        
                        // Share button
                        CustomButton(
                          text: 'Share Report',
                          icon: Icons.share,
                          onPressed: _shareReport,
                          backgroundColor: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        
                        // Generate new report button
                        CustomButton(
                          text: 'Generate New Report',
                          icon: Icons.refresh,
                          onPressed: () {
                            setState(() {
                              _exportPath = null;
                              _startDateController.clear();
                              _endDateController.clear();
                              _startDate = null;
                              _endDate = null;
                            });
                          },
                          backgroundColor: Colors.grey[800],
                          textColor: Colors.white,
                        ),
                        
                        // Back button
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Back to Class',
                          icon: Icons.arrow_back,
                          onPressed: _navigateBack,
                          backgroundColor: Colors.grey[600],
                          textColor: Colors.white,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
