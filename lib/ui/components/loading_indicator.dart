import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


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
          const ColoredBox(
            color: Colors.black54,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}