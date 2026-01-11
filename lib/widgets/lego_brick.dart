import 'package:flutter/material.dart';

/// Painter pour dessiner une brique LEGO
class LegoBrickPainter extends CustomPainter {
  final Color color;
  final bool isRadical; // Pour ajuster le style

  LegoBrickPainter({
    required this.color,
    required this.isRadical,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Corps principal de la brique (rectangle arrondi)
    final bodyRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, size.height * 0.3, size.width, size.height * 0.7),
      topLeft: const Radius.circular(8),
      topRight: const Radius.circular(8),
      bottomLeft: const Radius.circular(8),
      bottomRight: const Radius.circular(8),
    );

    canvas.drawRRect(bodyRect, paint);

    // Ombres internes pour effet 3D
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(
          4,
          size.height * 0.3 + 4,
          size.width - 8,
          size.height * 0.7 - 8,
        ),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
        bottomLeft: const Radius.circular(6),
        bottomRight: const Radius.circular(6),
      ),
      shadowPaint,
    );

    // Dessiner les picots LEGO
    _drawStuds(canvas, size, color);

    // Bordure
    final borderPaint = Paint()
      ..color = _darkenColor(color, 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(bodyRect, borderPaint);
  }

  void _drawStuds(Canvas canvas, Size size, Color color) {
    final studPaint = Paint()
      ..color = _lightenColor(color, 0.1)
      ..style = PaintingStyle.fill;

    final studShadowPaint = Paint()
      ..color = _darkenColor(color, 0.2)
      ..style = PaintingStyle.fill;

    // Nombre de picots selon la largeur
    final studCount = (size.width / 40).floor().clamp(1, 4);
    final studRadius = 8.0;
    final studSpacing = size.width / (studCount + 1);

    for (int i = 0; i < studCount; i++) {
      final x = studSpacing * (i + 1);
      final y = size.height * 0.15;

      // Ombre du picot
      canvas.drawCircle(
        Offset(x + 1, y + 1),
        studRadius,
        studShadowPaint,
      );

      // Picot principal
      canvas.drawCircle(
        Offset(x, y),
        studRadius,
        studPaint,
      );

      // Highlight sur le picot
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x - 2, y - 2),
        studRadius * 0.4,
        highlightPaint,
      );
    }
  }

  Color _lightenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  Color _darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  @override
  bool shouldRepaint(covariant LegoBrickPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isRadical != isRadical;
  }
}

/// Widget de brique LEGO
class LegoBrick extends StatelessWidget {
  final String text;
  final bool isRadical; // true = bleu (radical), false = orange (terminaison)
  final double? width;
  final VoidCallback? onTap;

  const LegoBrick({
    super.key,
    required this.text,
    required this.isRadical,
    this.width,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isRadical ? Colors.blue.shade600 : Colors.orange.shade600;
    final textSize = text.length > 5 ? 16.0 : 20.0;

    // Calculer la largeur dynamique basée sur le texte
    final calculatedWidth = width ?? (text.length * 18.0 + 40.0).clamp(80.0, 200.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: calculatedWidth,
        height: 60,
        child: Stack(
          children: [
            // Custom painter pour la forme LEGO
            CustomPaint(
              size: Size(calculatedWidth, 60),
              painter: LegoBrickPainter(
                color: color,
                isRadical: isRadical,
              ),
            ),

            // Texte au centre
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: textSize,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 2.0,
                        color: Colors.black26,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
