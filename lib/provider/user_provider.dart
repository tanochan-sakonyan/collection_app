import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/constants/base_url.dart';
import 'package:mr_collection/data/model/freezed/user.dart';
import 'package:mr_collection/data/repository/event_repository.dart';
import 'package:mr_collection/data/repository/member_repository.dart';
import 'package:mr_collection/data/repository/user_repository.dart';
import 'package:mr_collection/provider/access_token_provider.dart';
import 'package:mr_collection/provider/event_repository_provider.dart';
import 'package:mr_collection/provider/member_repository_provider.dart';
import 'package:mr_collection/services/user_service.dart';
import 'package:mr_collection/data/model/freezed/member.dart';
import 'package:mr_collection/data/model/payment_status.dart';
import 'package:mr_collection/data/model/freezed/lineGroup.dart';

final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  final userService = ref.read(userServiceProvider);
  final eventRepository = ref.read(eventRepositoryProvider);
  final memberRepository = ref.read(memberRepositoryProvider);
  return UserNotifier(eventRepository, memberRepository, userService, ref);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(baseUrl: baseUrl);
});

final userServiceProvider = Provider<UserService>((ref) {
  final userRepository = ref.read(userRepositoryProvider);
  return UserService(userRepository);
});

class UserNotifier extends StateNotifier<User?> {
  final UserService userService;
  final Ref ref;
  final MemberRepository memberRepository;
  final EventRepository eventRepository;

  UserNotifier(
      this.eventRepository, this.memberRepository, this.userService, this.ref)
      : super(null) {
    // アクセストークンが変更された際にユーザー情報を取得
    ref.listen<String?>(accessTokenProvider, (previous, next) {
      if (next != null) {
        registerUser(next);
      } else {
        state = null;
      }
    });
  }

  Future<User?> registerUser(String accessToken) async {
    try {
      final user = await userService.registerUser(accessToken);
      debugPrint('accessToken: $accessToken');
      debugPrint('取得したユーザー情報: $user');
      state = user;
      debugPrint('state: $state');
      return user;
    } catch (e) {
      debugPrint('ユーザー登録の際にエラーが発生しました。: $e');
      state = null;
    }
  }

  Future<User?> fetchUserById(String userId) async {
    try {
      final user = await userService.fetchUserById(userId);
      state = user;
      return user;
    } catch (e) {
      debugPrint('ユーザー情報の取得の際にエラーが発生しました。: $e');
      state = null;
      return null;
    }
  }

  void logoutUser() {
    state = null;
  }

  Future<void> deleteUser(String userId) async {
    try {
      await ref.read(userRepositoryProvider).deleteUser(userId);
      state = null;
    } catch (e) {
      debugPrint('ユーザーの削除中にエラーが発生しました: $e: user_provider.dart ');
      rethrow;
    }
  }

  Future<void> createEvent(String eventName, String userId) async {
    try {
      final newEvent = await eventRepository.createEvent(eventName, userId);
      final updatedUser = state?.copyWith(
        events: [...state!.events, newEvent],
      );
      state = updatedUser;
    } catch (e) {
      debugPrint('イベントの作成中にエラーが発生しました: $e');
    }
  }

  Future<void> createEventAndTransferMembers(
      String eventId, String eventName, String userId) async {
    try {
      final newEvent = await eventRepository.createEventAndTransferMembers(
          eventId, eventName, userId);
      final updatedUser = state?.copyWith(
        events: [...state!.events, newEvent],
      );
      state = updatedUser;
    } catch (e) {
      debugPrint('イベントの作成中にエラーが発生しました: $e');
    }
  }

  Future<void> createEventAndGetMembersFromLine(
      String groupId, String eventName, List<LineGroupMember> members, String userId) async {
    try{
      final newEvent = await eventRepository.createEventAndGetMembersFromLine(
          groupId, eventName, members, userId);
      final updatedUser = state?.copyWith(
        events: [...state!.events, newEvent],
      );
      state = updatedUser;
    }catch (e){
      debugPrint('イベントの作成中にエラーが発生しました: $e');
    }
  }

  Future<void> inputTotalMoney(
      String userId, String eventId, int totalMoney) async {
    try {
      final updatedEvent =
          await eventRepository.inputTotalMoney(userId, eventId, totalMoney);
      final updatedUser = state?.copyWith(
        events: state!.events.map((event) {
          if (event.eventId == eventId) {
            return updatedEvent;
          }
          return event;
        }).toList(),
      );
      state = updatedUser;
    } catch (e) {
      debugPrint('イベントの合計金額の入力中にエラーが発生しました: $e');
    }
  }

  Future<void> deleteEvent(String userId, String eventId) async {
    try {
      final deleteResult = await eventRepository.deleteEvent(userId, eventId);

      final isDeleted = deleteResult[eventId] ?? false;
      if (!isDeleted) {
        throw Exception('イベントの削除に失敗しました');
      }

      final updatedEvents =
          state!.events.where((event) => event.eventId != eventId).toList();

      final updatedUser = state?.copyWith(events: updatedEvents);
      state = updatedUser;

      debugPrint('イベントの削除に成功しました: $eventId');
    } catch (e) {
      debugPrint('イベントの削除中にエラーが発生しました: $e');
    }
  }

  Future<void> createMembers(
      String userId, String eventId, String rawInput) async {
    try {
      final names = rawInput
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (names.isEmpty) {
        throw Exception('名前が１つもありません');
      }
      final newMembers =
          await memberRepository.createMembers(userId, eventId, names);
      state = state?.copyWith(
        events: state!.events.map((evt) {
          if (evt.eventId != eventId) return evt;
          return evt.copyWith(members: [...evt.members, ...newMembers]);
        }).toList(),
      );
      debugPrint('メンバーの一括追加に成功しました: $names : user_provider.dart');
    } catch (e) {
      debugPrint('メンバーの作成中にエラーが発生しました: $e : user_provider.dart');
    }
  }

  Future<void> updateMemberStatus(
      String userId, String eventId, String memberId, int newStatus) async {
    try {
      final updatedMember = await memberRepository.updateMemberStatus(
          userId, eventId, memberId, newStatus);

      final updatedUser = state?.copyWith(
        events: state?.events.map((event) {
              if (event.eventId == eventId) {
                return event.copyWith(
                  members: event.members.map((member) {
                    if (member.memberId == memberId) {
                      return updatedMember;
                    }
                    return member;
                  }).toList(),
                );
              }
              return event;
            }).toList() ??
            [],
      );

      state = updatedUser;
    } catch (e) {
      debugPrint('メンバーのステータス更新中にエラーが発生しました: $e');
    }
  }

  Future<void> inputMembersMoney(String userId, String eventId,
      List<Map<String, dynamic>> membersMoneyList) async {
    try {
      final updatedMembers = await memberRepository.inputMembersMoney(
          userId, eventId, membersMoneyList);

      final updatedEvents = state?.events.map((event) {
            if (event.eventId != eventId) return event;
            return event.copyWith(
              members: updatedMembers,
            );
          }).toList() ??
          [];

      state = state?.copyWith(events: updatedEvents);

      debugPrint('メンバーの金額入力に成功しました: $membersMoneyList');
    } catch (e) {
      debugPrint('メンバーの金額入力中にエラーが発生しました: $e');
    }
  }

  Future<void> deleteMember(
      String userId, String eventId, String memberId) async {
    try {
      final isDeleted =
          await memberRepository.deleteMember(userId, eventId, memberId);

      if (!isDeleted) {
        throw Exception('メンバーの削除に失敗しました');
      }

      final updatedEvents = state?.events.map((event) {
            final updatedMembers = event.members
                .where((member) => member.memberId != memberId)
                .toList();
            return event.copyWith(members: updatedMembers);
          }).toList() ??
          [];

      final updatedUser = state?.copyWith(events: updatedEvents);
      state = updatedUser;

      debugPrint('メンバーの削除に成功しました: $memberId');
    } catch (e) {
      debugPrint('メンバーの削除中にエラーが発生しました: $e');
    }
  }

  int getStatusRank(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.unpaid:
        return 0;
      case PaymentStatus.paid:
        return 1;
      case PaymentStatus.absence:
      default:
        return 2;
    }
  }

  Future<void> sortingMembers(String eventId) async {
    if (state == null) return;

    final updatedEvents = state!.events.map((event) {
      if (event.eventId == eventId) {
        final sortedMembers = List<Member>.from(event.members);
        sortedMembers.sort((a, b) =>
            getStatusRank(a.status).compareTo(getStatusRank(b.status)));
        return event.copyWith(members: sortedMembers);
      } else {
        return event;
      }
    }).toList();

    state = state!.copyWith(events: updatedEvents);
  }

  Future<void> editMemberName(String userId, String eventId, String memberId,
      String newMemberName) async {
    try {
      final updatedMember = await memberRepository.editMemberName(
          userId, eventId, memberId, newMemberName);
      final updatedEvents = state?.events.map((event) {
        if (event.eventId != eventId) return event;
        return event.copyWith(
          members: event.members.map((m) {
            if (m.memberId == memberId) return updatedMember;
            return m;
          }).toList(),
        );
      }).toList();
      state = state?.copyWith(events: updatedEvents ?? []);
    } catch (e) {
      debugPrint('メンバーの作成中にエラーが発生しました: $e : user_provider.dart');
    }
  }

  Future<List<LineGroup>> getLineGroups(String userId) async {
    try {
      final lineGroups = await userService.getLineGroups(userId);
      return lineGroups;
    } catch (e) {
      debugPrint('ユーザー情報の取得の際にエラーが発生しました。: $e');
      return [];
    }
  }
}
