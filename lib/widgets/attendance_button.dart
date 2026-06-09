import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/attendance_model.dart';
import '../theme/colors.dart';

class AttendanceButton extends StatelessWidget {
  final AttendanceStatus status;
  final bool isSelected;
  final VoidCallback onPressed;

  const AttendanceButton({
    super.key,
    required this.status,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case AttendanceStatus.present:
        backgroundColor = isSelected 
            ? AppColors.presentColor 
            : AppColors.presentColor.withOpacity(0.1);
        textColor = isSelected 
            ? Colors.white 
            : AppColors.presentColor;
        icon = Icons.check_circle_outline;
        break;
      case AttendanceStatus.absent:
        backgroundColor = isSelected 
            ? AppColors.absentColor 
            : AppColors.absentColor.withOpacity(0.1);
        textColor = isSelected 
            ? Colors.white 
            : AppColors.absentColor;
        icon = Icons.cancel_outlined;
        break;
      case AttendanceStatus.late:
        backgroundColor = isSelected 
            ? AppColors.lateColor 
            : AppColors.lateColor.withOpacity(0.1);
        textColor = isSelected 
            ? Colors.white 
            : AppColors.lateColor;
        icon = Icons.access_time;
        break;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          onPressed();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: backgroundColor.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: textColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                status.label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
