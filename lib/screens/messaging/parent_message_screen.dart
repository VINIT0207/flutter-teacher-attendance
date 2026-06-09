// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/student_model.dart';
import '../../theme/colors.dart';

class SendParentReportScreen extends StatefulWidget {
  final int classId;
  final List<StudentModel> students;
  final StudentModel? student;
  final double? attendance;

  const SendParentReportScreen({
    super.key,
    required this.classId,
    required this.students,
    this.student,
    this.attendance,
  });

  @override
  State<SendParentReportScreen> createState() => _SendParentReportScreenState();
}

class _SendParentReportScreenState extends State<SendParentReportScreen> {
  final _messageController = TextEditingController();
  final _phoneController = TextEditingController();
  StudentModel? _selectedStudent;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize with passed student or first student
    if (widget.student != null) {
      _selectedStudent = widget.student;
    } else if (widget.students.isNotEmpty) {
      _selectedStudent = widget.students.first;
    }
    
    _initializeMessage();
  }

  void _initializeMessage() {
    if (_selectedStudent != null) {
      final attendance = widget.attendance ?? 0.0;
      print('Attendance passed: $attendance');
      _messageController.text = '''This is to inform you that ${_selectedStudent!.name}'s attendance is currently at ${attendance.toStringAsFixed(1)}%, which is below the required 75%.

Please ensure regular attendance to avoid any academic penalties.

Regards,
[Your Name]
[School Name]''';
      
      // Set phone number if available
      _phoneController.text = _selectedStudent!.parentContact;
    }
  }

  Future<void> _sendMessage() async {
    // Validation
    if (_selectedStudent == null) {
      _showSnackBar('Please select a student', Colors.red);
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      _showSnackBar('Please enter parent phone number', Colors.red);
      return;
    }

    if (_messageController.text.trim().isEmpty) {
      _showSnackBar('Please enter a message', Colors.red);
      return;
    }

    // Validate phone number length
    if (_phoneController.text.trim().length < 10) {
      _showSnackBar('Please enter a valid phone number', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final phone = _phoneController.text.trim();
      final message = _messageController.text.trim();
      
      // Create the SMS URL
      final smsUrl = 'sms:$phone?body=${Uri.encodeComponent(message)}';
      
      // Try to launch the SMS app
      if (await canLaunchUrl(Uri.parse(smsUrl))) {
        await launchUrl(Uri.parse(smsUrl));
        
        _showSnackBar('SMS app opened successfully', Colors.green);
        
        // Optional: Clear the form after successful opening
        // You might want to comment this out if you want to keep the message
        // _messageController.clear();
        
        // Go back to previous screen after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
        
      } else {
        // Fallback: try alternative SMS launch method
        final alternativeUrl = 'sms:$phone';
        if (await canLaunchUrl(Uri.parse(alternativeUrl))) {
          await launchUrl(Uri.parse(alternativeUrl));
          _showSnackBar('SMS app opened. Please copy the message manually.', Colors.orange);
        } else {
          _showSnackBar('Could not open SMS app on this device', Colors.red);
        }
      }
    } catch (e) {
      print('Error sending message: $e');
      _showSnackBar('Error opening SMS app: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Message to Parent'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student selector if multiple students
              if (widget.student == null && widget.students.isNotEmpty)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Student',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<StudentModel>(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          value: _selectedStudent,
                          onChanged: (StudentModel? value) {
                            if (value != null) {
                              setState(() {
                                _selectedStudent = value;
                              });
                              _initializeMessage();
                            }
                          },
                          items: widget.students
                              .map<DropdownMenuItem<StudentModel>>((StudentModel student) {
                            return DropdownMenuItem<StudentModel>(
                              value: student,
                              child: Text('${student.name} (${student.rollNo})'),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              
              if (_selectedStudent != null) ...[
                const SizedBox(height: 16),
                
                // Student info card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.absentColor.withOpacity(0.2),
                          child: Text(
                            _selectedStudent!.name.isNotEmpty
                                ? _selectedStudent!.name[0].toUpperCase()
                                : '#',
                            style: const TextStyle(
                              color: AppColors.absentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedStudent!.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                'Roll No: ${_selectedStudent!.rollNo}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'Attendance: ${(widget.attendance ?? 0.0).toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  color: AppColors.absentColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Parent contact card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Parent Contact',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            hintText: 'Enter parent phone number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            prefixIcon: const Icon(Icons.phone),
                          ),
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Message section
                const Text(
                  'Message',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You can edit the message before sending',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Message text field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Message',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' *',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(
                        maxHeight: 200,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _messageController,
                        maxLines: null,
                        minLines: 6,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12),
                          hintText: 'Enter your message here...',
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Send button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _sendMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Text(
                      _isLoading ? 'Sending...' : 'Send Message',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Instructions
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'This will open your SMS app with the message pre-filled. You can then send it to the parent.',
                          style: TextStyle(fontSize: 12),
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
    );
  }
}