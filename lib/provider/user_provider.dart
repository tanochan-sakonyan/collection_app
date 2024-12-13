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

  Future<User?> fetchUserById(int userId) async {
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

  Future<void> updateMemberStatus(
      int eventId, int memberId, int newStatus) async {
    try {
      final updatedMember = await memberRepository.updateMemberStatus(
          eventId, memberId, newStatus);

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

  Future<void> createEvent(String eventName, int userId) async {
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

  Future<void> deleteEvent(int eventId) async {
    try {
      final deleteResult = await eventRepository.deleteEvent(eventId);

      final isDeleted = deleteResult[eventId.toString()] ?? false;
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

  Future<void> createMember(int eventId, String memberName) async {
    try {
      final newMember =
          await memberRepository.createMember(eventId, memberName);
      final updatedUser = state?.copyWith(
        events: state?.events.map((event) {
              if (event.eventId == eventId) {
                return event.copyWith(
                  members: [...event.members, newMember],
                );
              }
              return event;
            }).toList() ??
            [],
      );
      state = updatedUser;
    } catch (e) {
      debugPrint('メンバーの作成中にエラーが発生しました: $e');
    }
  }

  Future<void> deleteMember(int memberId) async {
    try {
      final isDeleted = await memberRepository.deleteMember(memberId);

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
}
