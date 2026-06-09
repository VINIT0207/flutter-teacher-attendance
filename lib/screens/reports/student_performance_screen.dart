import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../bloc/attendance/attendance_bloc.dart';
import '../../models/attendance_model.dart';
import '../../models/student_model.dart';
import '../../theme/colors.dart';
import '../../database/database_helper.dart';

class StudentPerformanceScreen extends StatefulWidget {
  final int classId;
  final List<StudentModel> students;

  const StudentPerformanceScreen({
    super.key,
    required this.classId,
    required this.students,
  });

  @override
  State<StudentPerformanceScreen> createState() => _StudentPerformanceScreenState();
}

class _StudentPerformanceScreenState extends State<StudentPerformanceScreen> {
  StudentModel? _selectedStudent;
  late ScrollController _scrollController;
  Map<String, dynamic>? _performanceData;
  List<AttendanceModel> _attendanceRecords = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    if (widget.students.isNotEmpty) {
      _selectedStudent = widget.students.first;
      _loadStudentPerformance();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadStudentPerformance() async {
    if (_selectedStudent?.id == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get database helper from the BLoC
      final attendanceBloc = context.read<AttendanceBloc>();
      // Assuming your BLoC has a database property, adjust this line as needed
      final dbHelper = DatabaseHelper(attendanceBloc.database);
      
      // Get student performance data
      final performance = await dbHelper.getStudentPerformance(_selectedStudent!.id!);
      final attendance = await dbHelper.getStudentAttendance(_selectedStudent!.id!);
      
      setState(() {
        _performanceData = performance;
        _attendanceRecords = attendance;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading student performance: $e');
      setState(() {
        _isLoading = false;
        _performanceData = {
          'present': 0,
          'absent': 0,
          'late': 0,
          'total': 0,
          'percentage': '0.0'
        };
        _attendanceRecords = [];
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading student data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getAttendanceColor(double percentage) {
    if (percentage >= 75) {
      return AppColors.presentColor;
    } else if (percentage >= 50) {
      return AppColors.lateColor;
    } else {
      return AppColors.absentColor;
    }
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return AppColors.presentColor;
      case AttendanceStatus.absent:
        return AppColors.absentColor;
      case AttendanceStatus.late:
        return AppColors.lateColor;
    }
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceHistory() {
    if (_attendanceRecords.isEmpty) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.history,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No attendance records found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Recent Attendance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.separated(
                itemCount: _attendanceRecords.length > 10 ? 10 : _attendanceRecords.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final attendance = _attendanceRecords[index];
                  final status = attendance.status;
                  
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: _getStatusColor(status).withOpacity(0.2),
                      child: Icon(
                        status == AttendanceStatus.present
                            ? Icons.check
                            : status == AttendanceStatus.late
                                ? Icons.access_time
                                : Icons.close,
                        color: _getStatusColor(status),
                        size: 16,
                      ),
                    ),
                    title: Text(
                      status.label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(status),
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      'Record ID: ${attendance.recordId}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status.label[0],
                        style: TextStyle(
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_attendanceRecords.length > 10) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Showing latest 10 of ${_attendanceRecords.length} records',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.students.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Student Performance'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No students in this class',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Performance'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Student selector - Made larger
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: DropdownButtonFormField<StudentModel>(
                  decoration: const InputDecoration(
                    labelText: 'Select Student',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    isDense: false,
                  ),
                  isExpanded: true,
                  iconSize: 28,
                  menuMaxHeight: 300,
                  value: _selectedStudent,
                  onChanged: (StudentModel? value) {
                    if (value != null) {
                      setState(() {
                        _selectedStudent = value;
                      });
                      _loadStudentPerformance();
                    }
                  },
                  items: widget.students.map<DropdownMenuItem<StudentModel>>((StudentModel student) {
                    return DropdownMenuItem<StudentModel>(
                      value: student,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          '${student.name} (${student.rollNo})',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 76, 88, 142),
                          ),
                          overflow: TextOverflow.ellipsis,
                      ),
                     ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          
          // Student performance data
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _performanceData == null
                    ? const Center(
                        child: Text('No performance data available'),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadStudentPerformance,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Student info card
                                Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                        child: Text(
                                          _selectedStudent!.name.isNotEmpty 
                                              ? _selectedStudent!.name[0].toUpperCase() 
                                              : '#',
                                          style: TextStyle(
                                            color: Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        _selectedStudent!.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      subtitle: Text('Roll No: ${_selectedStudent!.rollNo}'),
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: _getAttendanceColor(
                                            double.parse(_performanceData!['percentage']),
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          '${_performanceData!['percentage']}%',
                                          style: TextStyle(
                                            color: _getAttendanceColor(
                                              double.parse(_performanceData!['percentage']),
                                            ),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Attendance overview chart
                                Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        const Text(
                                          'Attendance Overview',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        if (_performanceData!['total'] > 0) ...[
                                          SizedBox(
                                            height: 200,
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                PieChart(
                                                  PieChartData(
                                                    centerSpaceRadius: 50,
                                                    sectionsSpace: 2,
                                                    sections: [
                                                      if (_performanceData!['present'] > 0)
                                                        PieChartSectionData(
                                                          value: _performanceData!['present'].toDouble(),
                                                          color: AppColors.presentColor,
                                                          radius: 30,
                                                          title: '',
                                                        ),
                                                      if (_performanceData!['late'] > 0)
                                                        PieChartSectionData(
                                                          value: _performanceData!['late'].toDouble(),
                                                          color: AppColors.lateColor,
                                                          radius: 30,
                                                          title: '',
                                                        ),
                                                      if (_performanceData!['absent'] > 0)
                                                        PieChartSectionData(
                                                          value: _performanceData!['absent'].toDouble(),
                                                          color: AppColors.absentColor,
                                                          radius: 30,
                                                          title: '',
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      '${_performanceData!['percentage']}%',
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                        color: _getAttendanceColor(
                                                          double.parse(_performanceData!['percentage']),
                                                        ),
                                                      ),
                                                    ),
                                                    const Text(
                                                      'Attendance',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          // Legend
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              _buildLegendItem('Present', AppColors.presentColor, _performanceData!['present']),
                                              _buildLegendItem('Late', AppColors.lateColor, _performanceData!['late']),
                                              _buildLegendItem('Absent', AppColors.absentColor, _performanceData!['absent']),
                                            ],
                                          ),
                                        ] else ...[
                                          Container(
                                            height: 150,
                                            alignment: Alignment.center,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.pie_chart_outline,
                                                  size: 48,
                                                  color: Colors.grey[400],
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'No attendance data',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Statistics
                                Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.analytics,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              'Statistics',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildStatCard(
                                                'Total Classes',
                                                _performanceData!['total'].toString(),
                                                Icons.school,
                                                Colors.blue,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: _buildStatCard(
                                                'Present',
                                                _performanceData!['present'].toString(),
                                                Icons.check_circle,
                                                AppColors.presentColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildStatCard(
                                                'Late',
                                                _performanceData!['late'].toString(),
                                                Icons.access_time,
                                                AppColors.lateColor,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: _buildStatCard(
                                                'Absent',
                                                _performanceData!['absent'].toString(),
                                                Icons.cancel,
                                                AppColors.absentColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Attendance history
                                _buildAttendanceHistory(),
                                
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}