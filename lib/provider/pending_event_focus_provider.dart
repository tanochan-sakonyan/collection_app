import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stores the eventId that should be focused when returning to HomeScreen.
final pendingEventFocusProvider = StateProvider<String?>((ref) => null);
