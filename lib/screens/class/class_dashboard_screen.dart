import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../bloc/class/class_bloc.dart';
import '../../bloc/class/class_event.dart';
import '../../bloc/class/class_state.dart';
import '../../models/student_model.dart';
import '../../theme/colors.dart';
import '../../utils/date_formatter.dart';
import '../attendance/take_attendance_screen.dart';
import '../reports/class_insights_screen.dart';
import '../reports/download_report_screen.dart';
import '../reports/student_performance_screen.dart';
import 'edit_class_screen.dart';

class ClassDashboardScreen extends StatefulWidget {
  final int classId;

  const ClassDashboardScreen({
    super.key,
    required this.classId,
  });

  @override
  State<ClassDashboardScreen> createState() => _ClassDashboardScreenState();
}

class _ClassDashboardScreenState extends State<ClassDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadClassDetails();
  }

  void _loadClassDetails() {
    if (mounted) {
      context.read<ClassBloc>().add(LoadClassDetails(widget.classId));
    }
  }

  void _navigateBack() {
    if (mounted) {
      context.read<ClassBloc>().add(LoadClasses());
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  void _deleteClass(BuildContext context, int classId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Class'),
        content: const Text(
          'Are you sure you want to delete this class? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (mounted) {
                context.read<ClassBloc>().add(DeleteClass(classId));
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                });
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClassBloc, ClassState>(
      listener: (context, state) {
        // Handle navigation after deletion
        if (state is ClassesLoaded && mounted) {
          // Safe to navigate back
        }
      },
      builder: (context, state) {
        if (state is ClassLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Class Dashboard')),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (state is ClassDetailsLoaded) {
          final classModel = state.classModel;
          final students = state.students;

          return Scaffold(
            appBar: AppBar(
              title: Text(classModel.name),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _navigateBack,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: const RouteSettings(name: 'edit_class'),
                          builder: (context) => EditClassScreen(
                            classModel: classModel,
                            students: students,
                          ),
                        ),
                      ).then((_) {
                        if (mounted) {
                          _loadClassDetails();
                        }
                      });
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteClass(context, classModel.id!),
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                if (mounted) {
                  _loadClassDetails();
                }
                return Future.delayed(const Duration(milliseconds: 300));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Class info card
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.class_,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                title: Text(
                                  classModel.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Text(classModel.subject),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    classModel.year,
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildInfoColumn(
                                    'Total Students',
                                    '${classModel.totalStudents}',
                                    Icons.people,
                                  ),
                                  _buildInfoColumn(
                                    'Last Attendance',
                                    classModel.lastAttendanceDate != null
                                        ? DateFormatter.formatDate(
                                            classModel.lastAttendanceDate!)
                                        : 'Never',
                                    Icons.calendar_today,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Action buttons
                      const Text(
                        'Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      AnimationLimiter(
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          childAspectRatio: 1.1,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          children: AnimationConfiguration.toStaggeredList(
                            duration: const Duration(milliseconds: 375),
                            childAnimationBuilder: (widget) => SlideAnimation(
                              horizontalOffset: 50.0,
                              child: FadeInAnimation(
                                child: widget,
                              ),
                            ),
                            children: [
                              _buildActionCard(
                                context,
                                Icons.check_circle_outline,
                                'Take Attendance',
                                AppColors.presentColor,
                                () {
                                  if (!mounted) return;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      settings: const RouteSettings(
                                          name: 'take_attendance'),
                                      builder: (context) =>
                                          TakeAttendanceScreen(
                                        classId: classModel.id!,
                                        students: students,
                                      ),
                                    ),
                                  ).then((_) {
                                    if (mounted) {
                                      _loadClassDetails();
                                      context
                                          .read<ClassBloc>()
                                          .add(LoadClasses());
                                    }
                                  });
                                },
                              ),
                              _buildActionCard(
                                context,
                                Icons.analytics_outlined,
                                'Student Performance',
                                Colors.purple,
                                () {
                                  if (!mounted) return;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      settings: const RouteSettings(
                                          name: 'student_performance'),
                                      builder: (context) =>
                                          StudentPerformanceScreen(
                                        classId: classModel.id!,
                                        students: students,
                                      ),
                                    ),
                                  ).then((_) {
                                    if (mounted) _loadClassDetails();
                                  });
                                },
                              ),
                              _buildActionCard(
                                context,
                                Icons.insights,
                                'Class Insights',
                                Colors.blue,
                                () {
                                  if (!mounted) return;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      settings: const RouteSettings(
                                          name: 'class_insights'),
                                      builder: (context) => ClassInsightsScreen(
                                        classId: classModel.id!,
                                      ),
                                    ),
                                  ).then((_) {
                                    if (mounted) _loadClassDetails();
                                  });
                                },
                              ),
                              _buildActionCard(
                                context,
                                Icons.download_outlined,
                                'Download Report',
                                Colors.green,
                                () {
                                  if (!mounted) return;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      settings: const RouteSettings(
                                          name: 'download_report'),
                                      builder: (context) =>
                                          DownloadReportScreen(
                                        classId: classModel.id!,
                                        className: classModel.name,
                                      ),
                                    ),
                                  ).then((_) {
                                    if (mounted) _loadClassDetails();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Student list
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Students (${students.length})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {
                              if (mounted) {
                                showSearch(
                                  context: context,
                                  delegate: StudentSearchDelegate(students),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (students.isEmpty)
                        Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 32),
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
                              const SizedBox(height: 8),
                              Text(
                                'Add students by editing the class',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        AnimationLimiter(
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: students.length,
                            itemBuilder: (context, index) {
                              final student = students[index];
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 375),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: Card(
                                      elevation: 2,
                                      margin: const EdgeInsets.only(bottom: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.2),
                                          child: Text(
                                            student.name.isNotEmpty
                                                ? student.name[0].toUpperCase()
                                                : '#',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          student.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle:
                                            Text('Roll No: ${student.rollNo}'),
                                        trailing: PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_vert),
                                          onSelected: (value) {
                                            if (value == 'delete' && mounted) {
                                              showDialog(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: const Text(
                                                      'Delete Student'),
                                                  content: Text(
                                                    'Are you sure you want to delete ${student.name}?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(ctx)
                                                              .pop(),
                                                      child:
                                                          const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(ctx).pop();
                                                        if (mounted) {
                                                          context
                                                              .read<ClassBloc>()
                                                              .add(
                                                                DeleteStudent(
                                                                    student.id!),
                                                              );
                                                        }
                                                      },
                                                      child: const Text(
                                                        'Delete',
                                                        style: TextStyle(
                                                            color: AppColors
                                                                .errorColor),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem<String>(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete,
                                                      color:
                                                          AppColors.errorColor),
                                                  SizedBox(width: 8),
                                                  Text('Delete',
                                                      style: TextStyle(
                                                          color: AppColors
                                                              .errorColor)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else if (state is ClassError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Class Dashboard'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _navigateBack,
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.errorColor,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.errorColor),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(title: const Text('Class Dashboard')),
            body: const Center(child: Text('Something went wrong')),
          );
        }
      },
    );
  }

  Widget _buildInfoColumn(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StudentSearchDelegate extends SearchDelegate<String> {
  final List<StudentModel> students;

  StudentSearchDelegate(this.students);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final filteredStudents = students
        .where((student) =>
            student.name.toLowerCase().contains(query.toLowerCase()) ||
            student.rollNo.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: filteredStudents.length,
      itemBuilder: (context, index) {
        final student = filteredStudents[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.withOpacity(0.2),
            child: Text(
              student.name.isNotEmpty ? student.name[0].toUpperCase() : '#',
              style: const TextStyle(color: Colors.blue),
            ),
          ),
          title: Text(student.name),
          subtitle: Text('Roll No: ${student.rollNo}'),
          onTap: () {
            close(context, student.id.toString());
          },
        );
      },
    );
  }
}

