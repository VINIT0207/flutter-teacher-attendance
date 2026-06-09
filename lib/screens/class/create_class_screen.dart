import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/class/class_bloc.dart';
import '../../bloc/class/class_event.dart';
import '../../models/class_model.dart';
import '../../models/student_model.dart';
import '../../utils/csv_helper.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/student_card.dart';

class CreateClassScreen extends StatefulWidget {
  const CreateClassScreen({super.key});

  @override
  State<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _classNameController = TextEditingController();
  final _subjectController = TextEditingController();
  final _yearController = TextEditingController();

  // Student form controllers
  final _studentNameController = TextEditingController();
  final _studentRollNoController = TextEditingController();
  final _studentParentContactController = TextEditingController();

  final List<StudentModel> _students = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _classNameController.dispose();
    _subjectController.dispose();
    _yearController.dispose();
    _studentNameController.dispose();
    _studentRollNoController.dispose();
    _studentParentContactController.dispose();
    super.dispose();
  }

  void _addStudent() {
    if (_studentNameController.text.trim().isEmpty ||
        _studentRollNoController.text.trim().isEmpty ||
        _studentParentContactController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all student details')),
      );
      return;
    }

    setState(() {
      _students.add(StudentModel(
        classId: 0, // Temporary, will be set after class creation
        name: _studentNameController.text.trim(),
        rollNo: _studentRollNoController.text.trim(),
        parentContact: _studentParentContactController.text.trim(),
      ));

      // Clear fields for next entry
      _studentNameController.clear();
      _studentRollNoController.clear();
      _studentParentContactController.clear();
    });
  }

  void _removeStudent(int index) {
    setState(() {
      _students.removeAt(index);
    });
  }

  void _importStudentsFromCSV() async {
    // Show an info dialog first
    bool? proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Students from CSV'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CSV file should have the following format:'),
            SizedBox(height: 8),
            Text('• First row: headers (name, roll no, parent contact)'),
            Text('• Each subsequent row: student data'),
            SizedBox(height: 8),
            Text('Do you want to continue?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (proceed != true) return;

    List<StudentModel>? importedStudents = await ExcelHelper.importStudentsFromExcel(
      classId: 0, // Temporary, will be set after class creation
      onError: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
    );

    if (importedStudents != null && importedStudents.isNotEmpty) {
      setState(() {
        _students.addAll(importedStudents);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Successfully imported ${importedStudents.length} students'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _createClass() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final classModel = ClassModel(
      name: _classNameController.text.trim(),
      subject: _subjectController.text.trim(),
      year: _yearController.text.trim(),
      totalStudents: _students.length,
    );

    context.read<ClassBloc>().add(CreateClass(classModel, _students));

    // Navigate back after class creation
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Class'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Class details section
            const Text(
              'Class Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Class Name',
              controller: _classNameController,
              hint: 'e.g. Computer Science 101',
              isRequired: true,
              prefixIcon: Icons.class_,
            ),
            CustomTextField(
              label: 'Subject',
              controller: _subjectController,
              hint: 'e.g. Programming Fundamentals',
              isRequired: true,
              prefixIcon: Icons.subject,
            ),
            CustomTextField(
              label: 'Year',
              controller: _yearController,
              hint: 'e.g. FY, SY, TY',
              isRequired: true,
              prefixIcon: Icons.calendar_today,
            ),
            const SizedBox(height: 24),

            // Students section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Students',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _importStudentsFromCSV,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Import XLSX'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Add student form
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Student',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Student Name',
                      controller: _studentNameController,
                      hint: 'Full name',
                      prefixIcon: Icons.person,
                    ),
                    CustomTextField(
                      label: 'Roll Number',
                      controller: _studentRollNoController,
                      hint: 'e.g. 101',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.tag,
                    ),
                    CustomTextField(
                      label: 'Parent Contact',
                      controller: _studentParentContactController,
                      hint: 'Phone number',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone,
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Add Student',
                      icon: Icons.add,
                      onPressed: _addStudent,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // List of added students
            if (_students.isNotEmpty) ...[
              Text(
                'Added Students (${_students.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              for (int i = 0; i < _students.length; i++)
                StudentCard(
                  student: _students[i],
                  onDelete: () => _removeStudent(i),
                ),
              const SizedBox(height: 16),
            ],

            // Create class button
            CustomButton(
              text: 'Create Class',
              icon: Icons.save,
              isLoading: _isLoading,
              onPressed: _createClass,
              backgroundColor: Theme.of(context).primaryColor,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
