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

class EditClassScreen extends StatefulWidget {
  final ClassModel classModel;
  final List<StudentModel> students;

  const EditClassScreen({
    super.key,
    required this.classModel,
    required this.students,
  });

  @override
  State<EditClassScreen> createState() => _EditClassScreenState();
}

class _EditClassScreenState extends State<EditClassScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _classNameController;
  late TextEditingController _subjectController;
  late TextEditingController _yearController;
  
  // Student form controllers
  final _studentNameController = TextEditingController();
  final _studentRollNoController = TextEditingController();
  final _studentParentContactController = TextEditingController();
  
  late List<StudentModel> _students;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _classNameController = TextEditingController(text: widget.classModel.name);
    _subjectController = TextEditingController(text: widget.classModel.subject);
    _yearController = TextEditingController(text: widget.classModel.year);
    _students = List.from(widget.students);
  }
  
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
        classId: widget.classModel.id!,
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
  
  void _editStudent(int index) {
    final student = _students[index];
    _studentNameController.text = student.name;
    _studentRollNoController.text = student.rollNo;
    _studentParentContactController.text = student.parentContact;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Student',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Student Name',
              controller: _studentNameController,
              hint: 'Full name',
              prefixIcon: Icons.person,
              isRequired: true,
            ),
            CustomTextField(
              label: 'Roll Number',
              controller: _studentRollNoController,
              hint: 'e.g. 101',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.tag,
              isRequired: true,
            ),
            CustomTextField(
              label: 'Parent Contact',
              controller: _studentParentContactController,
              hint: 'Phone number',
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone,
              isRequired: true,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_studentNameController.text.trim().isEmpty ||
                        _studentRollNoController.text.trim().isEmpty ||
                        _studentParentContactController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all student details')),
                      );
                      return;
                    }
                    
                    setState(() {
                      _students[index] = StudentModel(
                        id: student.id,
                        classId: widget.classModel.id!,
                        name: _studentNameController.text.trim(),
                        rollNo: _studentRollNoController.text.trim(),
                        parentContact: _studentParentContactController.text.trim(),
                      );
                    });
                    
                    Navigator.pop(context);
                    
                    // Clear fields
                    _studentNameController.clear();
                    _studentRollNoController.clear();
                    _studentParentContactController.clear();
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  void _removeStudent(int index) {
    final student = _students[index];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Student'),
        content: Text('Are you sure you want to remove ${student.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                if (student.id != null) {
                  // If student exists in database, delete it
                  context.read<ClassBloc>().add(DeleteStudent(student.id!));
                } else {
                  // If student is new and not yet saved, just remove from local list
                  _students.removeAt(index);
                }
              });
              Navigator.pop(ctx);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
      classId: widget.classModel.id!,
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
          content: Text('Successfully imported ${importedStudents.length} students'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  void _saveChanges() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() => _isLoading = true);
    
    // Update class details
    final updatedClass = widget.classModel.copyWith(
      name: _classNameController.text.trim(),
      subject: _subjectController.text.trim(),
      year: _yearController.text.trim(),
      totalStudents: _students.length,
    );
    
    context.read<ClassBloc>().add(UpdateClass(updatedClass));
    
    // Handle new and updated students
    for (var student in _students) {
      if (student.id == null) {
        // New student
        context.read<ClassBloc>().add(AddStudent(student));
      } else if (widget.students.any((s) => 
          s.id == student.id && 
          (s.name != student.name || 
           s.rollNo != student.rollNo || 
           s.parentContact != student.parentContact))) {
        // Updated student
        context.read<ClassBloc>().add(UpdateStudent(student));
      }
    }
    
    // Navigate back after saving
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Class'),
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
                Text(
                  'Students (${_students.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _importStudentsFromCSV,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Import CSV'),
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
            
            // List of students
            if (_students.isNotEmpty) ...[
              Text(
                'Manage Students (${_students.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              for (int i = 0; i < _students.length; i++)
                StudentCard(
                  student: _students[i],
                  onEdit: () => _editStudent(i),
                  onDelete: () => _removeStudent(i),
                ),
              const SizedBox(height: 16),
            ],
            
            // Save changes button
            CustomButton(
              text: 'Save Changes',
              icon: Icons.save,
              isLoading: _isLoading,
              onPressed: _saveChanges,
              backgroundColor: Theme.of(context).primaryColor,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
