import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';

enum SnackBarType { success, error, info, warning }

class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    HapticFeedback.mediumImpact();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color primaryAccent;
    IconData icon;
    String defaultTitle;

    switch (type) {
      case SnackBarType.success:
        primaryAccent = AppColors.presentColor;
        icon = Icons.check_circle_rounded;
        defaultTitle = 'Success';
        break;
      case SnackBarType.error:
        primaryAccent = AppColors.errorColor;
        icon = Icons.error_rounded;
        defaultTitle = 'Error';
        break;
      case SnackBarType.warning:
        primaryAccent = Colors.amber[700] ?? Colors.amber;
        icon = Icons.warning_rounded;
        defaultTitle = 'Notice';
        break;
      case SnackBarType.info:
        primaryAccent = AppColors.primaryLight;
        icon = Icons.info_rounded;
        defaultTitle = 'Information';
        break;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        duration: duration,
        padding: EdgeInsets.zero,
        content: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCardBackground : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: primaryAccent.withValues(alpha: isDark ? 0.45 : 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryAccent.withValues(alpha: isDark ? 0.2 : 0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryAccent.withValues(alpha: isDark ? 0.18 : 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: primaryAccent, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title ?? defaultTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : AppColors.textDark,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMuted,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (action != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: action.onPressed,
                  style: TextButton.styleFrom(
                    foregroundColor: primaryAccent,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  child: Text(
                    action.label,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message,
      {String? title, SnackBarAction? action}) {
    show(context,
        message: message,
        title: title ?? 'Success',
        type: SnackBarType.success,
        action: action);
  }

  static void showError(BuildContext context, String message, {String? title}) {
    show(context,
        message: message,
        title: title ?? 'Action Failed',
        type: SnackBarType.error);
  }

  static void showInfo(BuildContext context, String message,
      {String? title, SnackBarAction? action}) {
    show(context,
        message: message,
        title: title ?? 'ClassTrack',
        type: SnackBarType.info,
        action: action);
  }

  static void showWarning(BuildContext context, String message,
      {String? title}) {
    show(context,
        message: message,
        title: title ?? 'Attention',
        type: SnackBarType.warning);
  }
}
