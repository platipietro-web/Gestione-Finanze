import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';

/// Marchio dell'app: un quadrato arrotondato con una linea che sale.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 40, this.showName = false});

  final double size;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: CustomPaint(painter: _TrendPainter(colors.onPrimary)),
    );
    if (!showName) return Semantics(label: context.l10n.appName, child: mark);
    return Semantics(
      label: context.l10n.appName,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          mark,
          SizedBox(width: size * 0.3),
          Text(
            context.l10n.appName,
            style: context.textStyles.titleLarge?.copyWith(
              fontSize: size * 0.45,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.085
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.24, h * 0.66)
      ..lineTo(w * 0.43, h * 0.47)
      ..lineTo(w * 0.56, h * 0.58)
      ..lineTo(w * 0.76, h * 0.34);
    canvas.drawPath(path, paint);
    canvas.drawCircle(
      Offset(w * 0.76, h * 0.34),
      size.width * 0.07,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_TrendPainter oldDelegate) => oldDelegate.color != color;
}
