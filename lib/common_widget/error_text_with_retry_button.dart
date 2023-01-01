import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// リトライボタン付きのエラーWidget
class ErrorTextWithRetryButton extends HookConsumerWidget {
  final Object? error;
  final StackTrace? stackTrace;
  final VoidCallback? onRetry;
  const ErrorTextWithRetryButton({
    super.key,
    required this.error,
    required this.stackTrace,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          error.toString(),
          maxLines: 3,
        ),
        const Gap(16),
        TextButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
          onPressed: onRetry,
        ),
      ],
    );
  }
}
