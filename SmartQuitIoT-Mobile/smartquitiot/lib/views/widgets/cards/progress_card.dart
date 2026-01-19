import 'package:flutter/material.dart';

class ProgressCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress; // 0.0 - 1.0
  final String progressText;

  /// Icon giờ nhận Widget → có thể truyền Icon, Lottie, Image…
  final Widget icon;

  final Color? backgroundColor;
  final Color? progressColor;

  const ProgressCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.progressText,
    required this.icon,
    this.backgroundColor,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? const Color(0xFF00D09E);
    final progColor = progressColor ?? Colors.white;

    return LayoutBuilder(builder: (context, constraints) {
      // Nếu constraints.maxWidth là infinite (hiếm khi xảy ra), dùng MediaQuery
      final maxWidth = constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : MediaQuery.of(context).size.width;
      final isNarrow = maxWidth < 360;

      // Ép kích thước icon để tránh icon quá to kéo tràn
      final Widget iconBox = SizedBox(
        width: 56,
        height: 56,
        child: FittedBox(
          fit: BoxFit.contain,
          child: icon,
        ),
      );

      final Widget titleWidget = Text(
        title,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        style: TextStyle(
          color: progColor,
          fontSize: isNarrow ? 14 : 16,
          fontWeight: FontWeight.bold,
        ),
      );

      final Widget subtitleWidget = Text(
        subtitle,
        overflow: TextOverflow.ellipsis,
        maxLines: isNarrow ? 2 : 1,
        style: TextStyle(
          color: progColor.withOpacity(0.95),
          fontSize: isNarrow ? 12 : 13,
        ),
      );

      final Widget progressBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: progColor.withOpacity(0.22),
          borderRadius: BorderRadius.circular(18),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            progressText,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: progColor,
              fontWeight: FontWeight.bold,
              fontSize: isNarrow ? 12 : 14,
            ),
          ),
        ),
      );

      return Container(
        padding: EdgeInsets.all(isNarrow ? 12 : 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgColor, _darkenColor(bgColor, 0.08)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: bgColor.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // nếu hẹp thì stack (icon + title) trên 1 dòng, badge xuống dòng bên dưới (không tràn)
            if (isNarrow) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  iconBox,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleWidget,
                        const SizedBox(height: 6),
                        subtitleWidget,
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: progressBadge,
              ),
            ] else ...[
              // layout rộng: icon + expanded text + badge (single row)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  iconBox,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleWidget,
                        const SizedBox(height: 6),
                        subtitleWidget,
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(fit: FlexFit.loose, child: progressBadge),
                ],
              ),
            ],
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: progColor.withOpacity(0.25),
                valueColor: AlwaysStoppedAnimation<Color>(progColor),
                minHeight: 8,
              ),
            ),
          ],
        ),
      );
    });
  }

  Color _darkenColor(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark =
    hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
