import 'package:flutter_riverpod/flutter_riverpod.dart';

final amountLoadingProvider = StateProvider.family<bool, String>((ref, eventId) => false);
