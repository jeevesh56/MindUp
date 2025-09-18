import 'package:flutter/material.dart';

class NeuroPulseLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool useImage;

  const NeuroPulseLogo({
    super.key,
    this.size = 64.0,
    this.showText = false,
    this.useImage = true,
  });

  @override
  Widget build(BuildContext context) {
    if (useImage) {
      // Use your actual logo image
      return Container(
        width: size,
        height: size,
        child: Image.asset(
          'assets/logo.jpg',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to custom painted logo if image not found
            return CustomPaint(
              size: Size(size, size),
              painter: NeuroPulseLogoPainter(),
            );
          },
        ),
      );
    } else {
      // Use custom painted logo
      return Container(
        width: size,
        height: size,
        child: CustomPaint(
          size: Size(size, size),
          painter: NeuroPulseLogoPainter(),
        ),
      );
    }
  }
}

class NeuroPulseLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    final fillPaint = Paint()..style = PaintingStyle.fill;

    // Head silhouette
    final headPath = Path();
    headPath.moveTo(size.width * 0.2, size.height * 0.3);
    headPath.quadraticBezierTo(
      size.width * 0.1,
      size.height * 0.4,
      size.width * 0.15,
      size.height * 0.6,
    );
    headPath.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.8,
      size.width * 0.4,
      size.height * 0.85,
    );
    headPath.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.9,
      size.width * 0.8,
      size.height * 0.8,
    );
    headPath.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.6,
      size.width * 0.85,
      size.height * 0.4,
    );
    headPath.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.2,
      size.width * 0.6,
      size.height * 0.15,
    );
    headPath.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.1,
      size.width * 0.2,
      size.height * 0.3,
    );

    // Draw head outline
    paint.color = const Color(0xFFB39DDB);
    canvas.drawPath(headPath, paint);

    // Brainwave data lines (left side)
    final dataLines = [
      Offset(size.width * 0.25, size.height * 0.35),
      Offset(size.width * 0.35, size.height * 0.35),
    ];
    final dataLines2 = [
      Offset(size.width * 0.25, size.height * 0.45),
      Offset(size.width * 0.4, size.height * 0.45),
    ];
    final dataLines3 = [
      Offset(size.width * 0.25, size.height * 0.55),
      Offset(size.width * 0.38, size.height * 0.55),
    ];

    paint.color = const Color(0xFF9C27B0);
    paint.strokeWidth = 1.5;
    canvas.drawLine(dataLines[0], dataLines[1], paint);
    canvas.drawLine(dataLines2[0], dataLines2[1], paint);
    canvas.drawLine(dataLines3[0], dataLines3[1], paint);

    // Audio equalizer bars (right side)
    final barHeights = [0.3, 0.5, 0.4, 0.6, 0.35, 0.45];
    final barWidth = size.width * 0.08;
    final startX = size.width * 0.5;
    final startY = size.height * 0.4;

    fillPaint.color = const Color(0xFF9C27B0);
    for (int i = 0; i < barHeights.length; i++) {
      final barHeight = barHeights[i] * size.height * 0.3;
      final barX = startX + (i * barWidth * 0.8);
      final barY = startY - barHeight;

      canvas.drawRect(
        Rect.fromLTWH(barX, barY, barWidth * 0.6, barHeight),
        fillPaint,
      );
    }

    // Add some glow effect
    paint.color = const Color(0xFF9C27B0).withValues(alpha: 0.3);
    paint.strokeWidth = 4.0;
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(headPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class NeuroPulseLogoWithText extends StatelessWidget {
  final double size;

  const NeuroPulseLogoWithText({super.key, this.size = 128.0});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        NeuroPulseLogo(size: size * 0.6),
        const SizedBox(height: 8),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Neuro',
                style: TextStyle(
                  color: Color(0xFF9C27B0),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: 'Pulse',
                style: TextStyle(
                  color: Color(0xFFB39DDB),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
