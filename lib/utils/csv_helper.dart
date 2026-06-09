// utils/excel_helper.dart
// ignore_for_file: unused_import

import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/student_model.dart';

class ExcelHelper {
  static Future<List<StudentModel>?> importStudentsFromExcel({
    required int classId,
    required Function(String) onError,
  }) async {
    try {
      // Pick Excel file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result == null || result.files.isEmpty) {
        return null; // User cancelled the picker
      }

      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      
      // Parse Excel
      var excel = Excel.decodeBytes(bytes);
      
      if (excel.tables.isEmpty) {
        onError('Excel file has no sheets');
        return null;
      }
      
      // Get first sheet
      String? tableName = excel.tables.keys.first;
      var table = excel.tables[tableName];
      
      if (table == null || table.rows.isEmpty) {
        onError('Excel sheet is empty');
        return null;
      }
      
      // Get headers from first row
      var headerRow = table.rows.first;
      List<String> headers = [];
      
      for (var cell in headerRow) {
        if (cell != null && cell.value != null) {
          headers.add(cell.value.toString().toLowerCase().trim());
        } else {
          headers.add('');
        }
      }
      
      // Validate required headers
      final requiredHeaders = ['name', 'roll no', 'parent contact'];
      
      for (final header in requiredHeaders) {
        if (!headers.contains(header)) {
          onError('Excel must contain headers: Name, Roll No, Parent Contact');
          return null;
        }
      }
      
      final nameIndex = headers.indexOf('name');
      final rollNoIndex = headers.indexOf('roll no');
      final parentContactIndex = headers.indexOf('parent contact');
      
      // Convert rows to StudentModel objects
      List<StudentModel> students = [];
      
      // Skip header row
      for (int i = 1; i < table.rows.length; i++) {
        final row = table.rows[i];
        
        // Skip empty rows
        if (row.isEmpty || row.every((cell) => cell == null || cell.value == null || cell.value.toString().trim().isEmpty)) {
          continue;
        }
        
        if (row.length <= nameIndex || row.length <= rollNoIndex || row.length <= parentContactIndex) {
          onError('Row ${i + 1} has fewer columns than expected');
          continue;
        }
        
        final nameCell = row[nameIndex];
        final rollNoCell = row[rollNoIndex];
        final parentContactCell = row[parentContactIndex];
        
        if (nameCell?.value == null || rollNoCell?.value == null || parentContactCell?.value == null) {
          onError('Row ${i + 1} has empty required fields');
          continue;
        }
        
        final name = nameCell!.value.toString().trim();
        final rollNo = rollNoCell!.value.toString().trim();
        final parentContact = parentContactCell!.value.toString().trim();
        
        if (name.isEmpty || rollNo.isEmpty || parentContact.isEmpty) {
          onError('Row ${i + 1} has empty required fields');
          continue;
        }
        
        students.add(StudentModel(
          classId: classId,
          name: name,
          rollNo: rollNo,
          parentContact: parentContact,
        ));
      }
      
      if (students.isEmpty) {
        onError('No valid student records found in Excel file');
        return null;
      }
      
      return students;
    } catch (e) {
      onError('Error processing Excel file: ${e.toString()}');
      return null;
    }
  }
  
  static Future<String?> exportAttendanceToExcel({
    required String className,
    required List<Map<String, dynamic>> data,
    required Function(String) onError,
  }) async {
    try {
      // Create Excel workbook
      var excel = Excel.createExcel();
      
      // Remove default sheet and create attendance sheet
      excel.delete('Sheet1');
      Sheet attendanceSheet = excel['Class_Attendance'];
      
      // Set up headers with styling
      final headers = ['Roll No', 'Name', 'Total Classes', 'Present', 'Absent', 'Late', 'Attendance %'];
      
      for (int col = 0; col < headers.length; col++) {
        var cell = attendanceSheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
        cell.value = TextCellValue(headers[col]);
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.blue,
          fontColorHex: ExcelColor.white,
          horizontalAlign: HorizontalAlign.Center,
          verticalAlign: VerticalAlign.Center,
        );
      }
      
      // Add data rows with conditional formatting
      for (int rowIndex = 0; rowIndex < data.length; rowIndex++) {
        final student = data[rowIndex];
        final dataRowIndex = rowIndex + 1; // +1 because row 0 is headers
        
        // Extract data
        final rollNo = student['rollNo']?.toString() ?? '';
        final name = student['name']?.toString() ?? '';
        final total = student['total'] ?? 0;
        final present = student['present'] ?? 0;
        final absent = student['absent'] ?? 0;
        final late = student['late'] ?? 0;
        final percentage = student['percentage']?.toString() ?? '0.0';
        
        // Convert percentage string to double for comparison
        double percentageValue = 0.0;
        try {
          percentageValue = double.parse(percentage.replaceAll('%', ''));
        } catch (e) {
          percentageValue = 0.0;
        }
        
        // Set cell values
        final rowData = [rollNo, name, total, present, absent, late, '${percentageValue.toStringAsFixed(1)}%'];
        
        for (int col = 0; col < rowData.length; col++) {
          var cell = attendanceSheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: dataRowIndex));
          
          // Set value based on type
          if (col == 2 || col == 3 || col == 4 || col == 5) { // Total, Present, Absent, Late
            cell.value = IntCellValue(int.tryParse(rowData[col].toString()) ?? 0);
          } else {
            cell.value = TextCellValue(rowData[col].toString());
          }
          
          // Apply conditional formatting
          ExcelColor backgroundColor;
          ExcelColor fontColor = ExcelColor.black;
          
          if (col == 6) { // Percentage column
            if (percentageValue >= 75) {
              backgroundColor = ExcelColor.lightGreen;
              fontColor = ExcelColor.green900;
            } else if (percentageValue >= 50) {
              backgroundColor = ExcelColor.yellow;
              fontColor = ExcelColor.orange;
            } else {
              backgroundColor = ExcelColor.pinkAccent;
              fontColor = ExcelColor.red900;
            }
          } else {
            // Alternate row colors for better readability
            backgroundColor = rowIndex % 2 == 0 ? ExcelColor.white : ExcelColor.green50;
          }
          
          cell.cellStyle = CellStyle(
            backgroundColorHex: backgroundColor,
            fontColorHex: fontColor,
            horizontalAlign: col == 1 ? HorizontalAlign.Left : HorizontalAlign.Center, // Name left-aligned, others centered
            verticalAlign: VerticalAlign.Center,
            bold: col == 6, // Bold percentage
          );
        }
      }
      
      // Auto-fit columns
      for (int col = 0; col < headers.length; col++) {
        attendanceSheet.setColumnAutoFit(col);
      }
      
      // Add summary statistics at the bottom
      final summaryRowIndex = data.length + 2; // +2 for header and spacing
      
      // Add summary title
      var summaryTitleCell = attendanceSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: summaryRowIndex));
      summaryTitleCell.value = TextCellValue('SUMMARY STATISTICS');
      summaryTitleCell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.blue900,
        fontColorHex: ExcelColor.white,
      );
      
      // Merge cells for summary title
      attendanceSheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: summaryRowIndex),
        CellIndex.indexByColumnRow(columnIndex: headers.length - 1, rowIndex: summaryRowIndex),
      );
      
      // Calculate and add summary statistics
      final totalStudents = data.length;
      final studentsAbove75 = data.where((s) {
        try {
          double percentage = double.parse((s['percentage']?.toString() ?? '0').replaceAll('%', ''));
          return percentage >= 75;
        } catch (e) {
          return false;
        }
      }).length;
      
      final studentsBelow75 = totalStudents - studentsAbove75;
      
      final summaryData = [
        ['Total Students:', totalStudents],
        ['Students with ≥75% Attendance:', studentsAbove75],
        ['Students with <75% Attendance:', studentsBelow75],
        ['Class Average Attendance:', '${_calculateAverageAttendance(data).toStringAsFixed(1)}%'],
      ];
      
      for (int i = 0; i < summaryData.length; i++) {
        final labelCell = attendanceSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: summaryRowIndex + 1 + i));
        final valueCell = attendanceSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: summaryRowIndex + 1 + i));
        
        labelCell.value = TextCellValue(summaryData[i][0].toString());
        valueCell.value = TextCellValue(summaryData[i][1].toString());
        
        labelCell.cellStyle = CellStyle(bold: true, horizontalAlign: HorizontalAlign.Left);
        valueCell.cellStyle = CellStyle(
          bold: true,
          horizontalAlign: HorizontalAlign.Left,
          fontColorHex: i == 2 ? ExcelColor.red900 : ExcelColor.green900, // Red for below 75%, green for others
        );
      }
      
      // Get appropriate directory based on platform
      Directory directory;
      
      if (Platform.isAndroid) {
        try {
          final externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            directory = externalDir;
          } else {
            directory = await getApplicationDocumentsDirectory();
          }
        } catch (e) {
          directory = await getApplicationDocumentsDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      
      // Create a unique filename with sanitized class name
      final sanitizedClassName = className.replaceAll(RegExp(r'[^\w\s]+'), '');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = '${sanitizedClassName}_attendance_$timestamp.xlsx';
      
      final file = File('${directory.path}/$filename');
      
      // Save Excel file
      var fileBytes = excel.save();
      if (fileBytes != null) {
        await file.writeAsBytes(fileBytes);
        return file.path;
      } else {
        onError('Failed to generate Excel file');
        return null;
      }
      
    } catch (e) {
      onError('Error exporting to Excel: ${e.toString()}');
      return null;
    }
  }
  
  static Future<String?> exportDetailedAttendanceToExcel({
    required String className,
    required List<Map<String, dynamic>> studentsData,
    required List<Map<String, dynamic>> attendanceRecords,
    required Function(String) onError,
  }) async {
    try {
      var excel = Excel.createExcel();
      excel.delete('Sheet1');
      Sheet detailSheet = excel['Detailed_Attendance'];
      
      // Get unique dates from attendance records
      Set<String> uniqueDates = {};
      for (var record in attendanceRecords) {
        if (record['date'] != null) {
          uniqueDates.add(record['date'].toString());
        }
      }
      
      List<String> sortedDates = uniqueDates.toList()..sort();
      
      // Headers
      List<String> headers = ['Roll No', 'Student Name'];
      headers.addAll(sortedDates);
      
      for (int col = 0; col < headers.length; col++) {
        var cell = detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
        cell.value = TextCellValue(headers[col]);
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.blue,
          fontColorHex: ExcelColor.white,
          horizontalAlign: HorizontalAlign.Center,
        );
      }
      
      // Add student attendance data
      for (int studentIndex = 0; studentIndex < studentsData.length; studentIndex++) {
        final student = studentsData[studentIndex];
        final rowIndex = studentIndex + 1;
        
        // Student info
        detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex)).value = 
            TextCellValue(student['rollNo']?.toString() ?? '');
        detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex)).value = 
            TextCellValue(student['name']?.toString() ?? '');
        
        // Attendance for each date
        for (int dateIndex = 0; dateIndex < sortedDates.length; dateIndex++) {
          final date = sortedDates[dateIndex];
          final colIndex = dateIndex + 2; // +2 for Roll No and Name columns
          
          // Find attendance record for this student and date
          String status = 'A'; // Default absent
          ExcelColor cellColor = ExcelColor.pinkAccent;
          
          for (var record in attendanceRecords) {
            if (record['studentId'].toString() == student['id'].toString() && 
                record['date'].toString() == date) {
              switch (record['status']?.toString().toUpperCase()) {
                case 'PRESENT':
                case 'P':
                  status = 'P';
                  cellColor = ExcelColor.lightGreen;
                  break;
                case 'LATE':
                case 'L':
                  status = 'L';
                  cellColor = ExcelColor.yellow;
                  break;
                default:
                  status = 'A';
                  cellColor = ExcelColor.pinkAccent;
              }
              break;
            }
          }
          
          var cell = detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: rowIndex));
          cell.value = TextCellValue(status);
          cell.cellStyle = CellStyle(
            backgroundColorHex: cellColor,
            horizontalAlign: HorizontalAlign.Center,
            bold: true,
            fontColorHex: status == 'A' ? ExcelColor.red900 : 
                         status == 'L' ? ExcelColor.orange : ExcelColor.green900,
          );
        }
      }
      
      // Auto-fit columns
      for (int col = 0; col < headers.length; col++) {
        detailSheet.setColumnAutoFit(col);
      }
      
      // Save file
      Directory directory;
      
      if (Platform.isAndroid) {
        try {
          final externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            directory = externalDir;
          } else {
            directory = await getApplicationDocumentsDirectory();
          }
        } catch (e) {
          directory = await getApplicationDocumentsDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      
      final sanitizedClassName = className.replaceAll(RegExp(r'[^\w\s]+'), '');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = '${sanitizedClassName}_detailed_attendance_$timestamp.xlsx';
      
      final file = File('${directory.path}/$filename');
      
      var fileBytes = excel.save();
      if (fileBytes != null) {
        await file.writeAsBytes(fileBytes);
        return file.path;
      } else {
        onError('Failed to generate detailed Excel file');
        return null;
      }
      
    } catch (e) {
      onError('Error exporting detailed attendance: ${e.toString()}');
      return null;
    }
  }
  
  // Helper method to calculate average attendance
  static double _calculateAverageAttendance(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 0.0;
    
    double total = 0.0;
    int count = 0;
    
    for (var student in data) {
      try {
        double percentage = double.parse((student['percentage']?.toString() ?? '0').replaceAll('%', ''));
        total += percentage;
        count++;
      } catch (e) {
        // Skip invalid percentage values
      }
    }
    
    return count > 0 ? total / count : 0.0;
  }
}