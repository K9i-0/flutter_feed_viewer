import 'package:flutter/material.dart';

class CommonLabel extends StatelessWidget {
  final String label;
  final String? tooltip;
  const CommonLabel({
    required this.label,
    this.tooltip,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Widget commonLabel = DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 2,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.apply(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
      ),
    );

    if (tooltip != null) {
      commonLabel = Tooltip(
        message: tooltip!,
        child: commonLabel,
      );
    }

    return commonLabel;
  }
}
