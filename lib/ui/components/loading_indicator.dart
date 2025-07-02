import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

final loadingProvider = StateProvider<bool>((ref) => false);

class CircleIndicator extends ConsumerWidget {
  const CircleIndicator({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(loadingProvider);

    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.85),
              child: const Center(
                child: SpinKitFadingCircle(
                  color: Colors.grey,
                  size: 60.0,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
