import 'package:flutter/material.dart';
import '../models/verb_builder.dart';
import 'lego_brick.dart';

/// Widget zone de dépôt pour les briques
class BrickDropZone extends StatelessWidget {
  final String label; // "Radical" ou "Terminaison"
  final bool isRadical;
  final VerbPart? currentPart;
  final Function(VerbPart) onAccept;
  final VoidCallback? onRemove;

  const BrickDropZone({
    super.key,
    required this.label,
    required this.isRadical,
    this.currentPart,
    required this.onAccept,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = isRadical ? Colors.blue.shade50 : Colors.orange.shade50;
    final borderColor = isRadical ? Colors.blue.shade300 : Colors.orange.shade300;

    return DragTarget<VerbPart>(
      onWillAccept: (data) => data?.isRadical == isRadical,
      onAccept: onAccept,
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;

        return Container(
          width: 200,
          height: 100,
          decoration: BoxDecoration(
            color: isHighlighted
                ? (isRadical ? Colors.blue.shade100 : Colors.orange.shade100)
                : baseColor,
            border: Border.all(
              color: isHighlighted
                  ? (isRadical ? Colors.blue.shade600 : Colors.orange.shade600)
                  : borderColor,
              width: isHighlighted ? 3 : 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: currentPart != null
              ? Center(
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Stack(
                      children: [
                        LegoBrick(
                          text: currentPart!.text,
                          isRadical: currentPart!.isRadical,
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isRadical ? Icons.category : Icons.label,
                      size: 32,
                      color: borderColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: borderColor,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
