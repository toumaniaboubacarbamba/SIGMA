import 'package:flutter/material.dart';

import '../../../app_theme.dart';

enum TimelineStepState { done, current, upcoming }

/// Une étape de la timeline verticale du détail de dossier.
class TimelineStep extends StatelessWidget {
  final String label;
  final String description;
  final TimelineStepState state;
  final bool isLast;

  const TimelineStep({
    super.key,
    required this.label,
    required this.description,
    required this.state,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final done = state == TimelineStepState.done;
    final current = state == TimelineStepState.current;
    final active = done || current;

    final dotColor = done
        ? SigmaColors.primary
        : (current ? SigmaColors.surface : SigmaColors.surfaceContainerHigh);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  border: current
                      ? Border.all(color: SigmaColors.primary, width: 2)
                      : (done
                          ? null
                          : Border.all(color: SigmaColors.outlineVariant)),
                ),
                child: done
                    ? const Icon(Icons.check, size: 18, color: Colors.white)
                    : (current
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: SigmaColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : const Icon(Icons.schedule,
                            size: 16, color: SigmaColors.outline)),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: done ? SigmaColors.primary : SigmaColors.outlineVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(width: SigmaSpacing.md),
          Expanded(
            child: Opacity(
              opacity: active ? 1 : 0.55,
              child: Padding(
                padding: const EdgeInsets.only(bottom: SigmaSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: SigmaText.titleMd.copyWith(
                        color: active ? SigmaColors.primary : SigmaColors.onSurfaceVariant,
                        fontWeight: current ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: SigmaText.bodyMd.copyWith(color: SigmaColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
