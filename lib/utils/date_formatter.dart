import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('dd MMM, yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }
  
  static String formatTime(String time) {
    try {
      return DateFormat('hh:mm a').format(DateFormat('HH:mm').parse(time));
    } catch (e) {
      return time;
    }
  }
  
  static String getCurrentDate() {
    return DateTime.now().toIso8601String().split('T')[0];
  }
  
  static String getCurrentTime() {
    return DateFormat('HH:mm').format(DateTime.now());
  }
  
  static String getTimeAgo(String dateTime) {
    try {
      final now = DateTime.now();
      final parsedDateTime = DateTime.parse(dateTime);
      final difference = now.difference(parsedDateTime);
      
      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()} ${(difference.inDays / 365).floor() == 1 ? 'year' : 'years'} ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} ${(difference.inDays / 30).floor() == 1 ? 'month' : 'months'} ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateTime;
    }
  }
}
