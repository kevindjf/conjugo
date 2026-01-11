import 'package:flutter/material.dart';
import '../models/verb_builder.dart';
import 'lego_brick.dart';

/// Widget de brique draggable
class DraggableBrick extends StatelessWidget {
  final VerbPart part;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragCompleted;
  final VoidCallback? onDragCanceled;

  const DraggableBrick({
    super.key,
    required this.part,
    this.onDragStarted,
    this.onDragCompleted,
    this.onDragCanceled,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<VerbPart>(
      data: part,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.1,
          child: Opacity(
            opacity: 0.8,
            child: LegoBrick(
              text: part.text,
              isRadical: part.isRadical,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: LegoBrick(
          text: part.text,
          isRadical: part.isRadical,
        ),
      ),
      onDragStarted: onDragStarted,
      onDragCompleted: onDragCompleted,
      onDraggableCanceled: (_, __) => onDragCanceled?.call(),
      child: LegoBrick(
        text: part.text,
        isRadical: part.isRadical,
      ),
    );
  }
}
