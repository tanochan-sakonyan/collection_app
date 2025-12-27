import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/modules/features/data/model/freezed/event.dart';
import 'package:mr_collection/modules/features/data/model/payment_status.dart';
import 'package:mr_collection/modules/shukinkun_ads/services/location_service.dart';

final shukinkunAdsTriggerProvider =
    StateNotifierProvider<ShukinkunAdsTriggerNotifier, Set<String>>((ref) {
  final locationService = ref.watch(shukinkunAdsLocationServiceProvider);
  return ShukinkunAdsTriggerNotifier(locationService);
});

class ShukinkunAdsTriggerNotifier extends StateNotifier<Set<String>> {
  ShukinkunAdsTriggerNotifier(this._locationService) : super({});

  final ShukinkunAdsLocationService _locationService;

  // 集金くんAdsの発火条件をチェックする
  Future<void> checkEvents(List<Event> events) async {
    for (final event in events) {
      if (state.contains(event.eventId)) {
        continue;
      }

      final totalMembers = event.members.length;
      if (totalMembers == 0) {
        continue;
      }

      final unpaidCount = event.members
          .where((member) => member.status == PaymentStatus.unpaid)
          .length;
      final bool meetsCondition =
          totalMembers >= 10 ? unpaidCount <= 2 : unpaidCount == 0;

      if (!meetsCondition) {
        continue;
      }

      state = {...state, event.eventId};
      try {
        final position = await _locationService.fetchCurrentPosition();
        if (position != null) {
          debugPrint(
            'Shukinkun Ads location => lat: ${position.latitude}, lng: ${position.longitude}',
          );
        }
      } on Exception catch (error, stackTrace) {
        debugPrint('Shukinkun Ads location fetch failed: $error');
        FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace),
        );
      }
    }
  }
}
