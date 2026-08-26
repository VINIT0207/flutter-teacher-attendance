import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';

class LiquidGlassBarItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;
  final Color? activeColor;
  final Widget? customWidget;
  final String? badgeText;

  const LiquidGlassBarItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
    this.activeColor,
    this.customWidget,
    this.badgeText,
  });
}

class LiquidGlassBar extends StatelessWidget {
  final List<LiquidGlassBarItem> items;
  final Widget? trailing;
  final double height;
  final EdgeInsetsGeometry? margin;

  const LiquidGlassBar({
    super.key,
    required this.items,
    this.trailing,
    this.height = 64.0,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    // Adaptively calculate bottom margin so it always floats cleanly above
    // Android 3-button navigation bars (~48dp), gesture indicators (~24dp), or flat edges
    final double calculatedBottomMargin =
        bottomInset > 0 ? (bottomInset + 10.0) : 16.0;
    final effectiveMargin =
        margin ?? EdgeInsets.fromLTRB(16, 0, 16, calculatedBottomMargin);

    return SafeArea(
      top: false,
      left: true,
      right: true,
      bottom: false,
      child: Container(
        margin: effectiveMargin,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : Colors.blueGrey)
                  .withValues(alpha: 0.25),
              blurRadius: 20,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppColors.primaryColor
                  .withValues(alpha: isDark ? 0.15 : 0.08),
              blurRadius: 12,
              spreadRadius: -2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.glassDarkBg : AppColors.glassLightBg,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isDark
                      ? AppColors.glassBorderDark
                      : AppColors.glassBorderLight,
                  width: 1.4,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [
                          Colors.white.withValues(alpha: 0.12),
                          Colors.white.withValues(alpha: 0.02),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.9),
                          Colors.white.withValues(alpha: 0.6),
                        ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ...items.map((item) => _buildBarItem(context, item)),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarItem(BuildContext context, LiquidGlassBarItem item) {
    if (item.customWidget != null) {
      return item.customWidget!;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = item.activeColor ?? AppColors.primaryLight;
    final inactiveColor =
        isDark ? AppColors.textMutedDark : AppColors.textMuted;

    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          item.onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          decoration: BoxDecoration(
            color: item.isSelected
                ? activeColor.withValues(alpha: 0.16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: item.isSelected
                ? Border.all(
                    color: activeColor.withValues(alpha: 0.35),
                    width: 1.2,
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    item.icon,
                    size: 21,
                    color: item.isSelected ? activeColor : inactiveColor,
                  ),
                  if (item.badgeText != null)
                    Positioned(
                      right: -8,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.absentColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          item.badgeText!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                        item.isSelected ? FontWeight.bold : FontWeight.w600,
                    color: item.isSelected ? activeColor : inactiveColor,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
