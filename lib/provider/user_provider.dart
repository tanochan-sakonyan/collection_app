import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/constants/base_url.dart';
import 'package:mr_collection/data/model/freezed/line_group_member.dart';
import 'package:mr_collection/data/model/freezed/user.dart';
import 'package:mr_collection/data/repository/event_repository.dart';
import 'package:mr_collection/data/repository/member_repository.dart';
import 'package:mr_collection/data/repository/user_repository.dart';
import 'package:mr_collection/provider/access_token_provider.dart';
import 'package:mr_collection/provider/amount_loading_provider.dart';
import 'package:mr_collection/provider/event_repository_provider.dart';
import 'package:mr_collection/provider/member_repository_provider.dart';
import 'package:mr_collection/services/user_service.dart';
import 'package:mr_collection/data/model/freezed/member.dart';
import 'package:mr_collection/data/model/payment_status.dart';
import 'package:mr_collection/data/model/freezed/line_group.dart';

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
      : super(null);

  // TODO: 現在はAppleログインで使用しているが、後々registerAppleUserを作成して移行する
  Future<User?> registerUser(String accessToken) async {
    try {
      final user = await userService.registerUser(accessToken);
      debugPrint('accessToken: $accessToken');
      debugPrint('取得したユーザー情報(テスト): $user');
      state = user;
      debugPrint('state: $state');
      return user;
    } catch (e) {
      debugPrint('ユーザー登録の際にエラーが発生しました。: $e');
      state = null;
    }
  }

  Future<User?> registerLineUser(String accessToken) async {
    try {
      final user = await userService.registerLineUser(accessToken);
      debugPrint('accessToken: $accessToken');
      debugPrint('取得したLINEユーザー情報: $user');
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

  Future<User?> fetchLineUserById(String userId, String lineAccessToken) async {
    try {
      final user = await userService.fetchLineUserById(userId, lineAccessToken);
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

  Future<void> editEventName(
      String userId, String eventId, String newEventName) async {
    try {
      final updateEvent =
          await eventRepository.editEventName(userId, eventId, newEventName);
      final updatedUser = state?.copyWith(
        events: state!.events.map((event) {
          if (event.eventId == eventId) {
            return updateEvent;
          }
          return event;
        }).toList(),
      );
      state = updatedUser;
      debugPrint("イベント名を更新しました: $newEventName");
    } catch (e) {
      debugPrint("イベント名編集中にエラーが発生しました: $e");
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

  Future<void> createEventAndGetMembersFromLine(String userId, String groupId,
      String eventName, List<LineGroupMember> members) async {
    try {
      final newEvent = await eventRepository.createEventAndGetMembersFromLine(
          userId, groupId, eventName, members);
      final updatedUser = state?.copyWith(
        events: [...state!.events, newEvent],
      );
      state = updatedUser;
    } catch (e) {
      debugPrint('イベントの作成中にエラーが発生しました: $e');
    }
  }

  Future<LineGroup> refreshLineGroupMember(
      String groupId, String userId) async {
    try {
      final updatedGroup = await ref
          .read(userRepositoryProvider)
          .refreshLineGroupMember(userId, groupId);
      return updatedGroup;
    } catch (e) {
      debugPrint('LINEメンバーの再取得にエラーが発生しました: $e');
      rethrow;
    }
  }

  Future<void> updateMemberDifference(
      String eventId, LineGroup updatedLineGroup) async {
    final oldEvent = state!.events.firstWhere((e) => e.eventId == eventId);
    final oldMembers = oldEvent.members;

    final oldMemberIds = oldMembers.map((m) => m.memberId).toSet();
    final newMemberIds =
        updatedLineGroup.members.map((m) => m.memberId).toSet();

    final additionalMembers = updatedLineGroup.members
        .where((m) => !oldMemberIds.contains(m.memberId))
        .map((lgm) => Member(
              memberId: lgm.memberId,
              memberName: lgm.memberName,
              status: PaymentStatus.unpaid,
              // amount: 0,
            ))
        .toList();
    final deletedMembers = oldMemberIds.difference(newMemberIds);

    final keptMembers =
        oldMembers.where((m) => !deletedMembers.contains(m.memberId)).toList();

    final updatedMembers = [...keptMembers, ...additionalMembers];

    final updatedEvents = state!.events.map((event) {
      if (event.eventId == eventId) {
        return event.copyWith(
          members: updatedMembers,
          // lineMembersFetchedAt: updatedLineGroup.fetchedAt, // TODO: 規約対応
        );
      }
      return event;
    }).toList();

    state = state!.copyWith(events: updatedEvents);
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
      List<Map<String, dynamic>> membersMoneyList, WidgetRef ref) async {
    ref.read(amountLoadingProvider(eventId).notifier).state = true;
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
    }finally {
      ref.read(amountLoadingProvider(eventId).notifier).state = false;
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

  Future<void> clearMembersOfEvent(String eventId) async {
    state = state!.copyWith(
      events: state!.events
          .map((e) => e.eventId == eventId ? e.copyWith(members: []) : e)
          .toList(),
    );
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

  Future<bool> sendMessage(
      String userId, String eventId, String message) async {
    try {
      final result =
          await eventRepository.sendMessage(userId, eventId, message);
      return result;
    } catch (e) {
      debugPrint('メッセージ送信中にエラーが発生しました: $e');
      return false;
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

  Future<void> addNote(String userId, String eventId, String memo) async {
    try {
      final updateEvent = await eventRepository.addNote(userId, eventId, memo);
      final updatedUser = state?.copyWith(
        events: state!.events.map((event) {
          if (event.eventId == eventId) {
            return updateEvent;
          }
          return event;
        }).toList(),
      );
      state = updatedUser;
      debugPrint("メモを更新しました: $memo : user_provider");
    } catch (e) {
      debugPrint("メモ編集中にエラーが発生しました: $e : user_provider");
    }
  }
}
