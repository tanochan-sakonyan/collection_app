import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/constants/base_url.dart';
import 'package:mr_collection/data/model/freezed/user.dart';
import 'package:mr_collection/data/repository/member_repository.dart';
import 'package:mr_collection/data/repository/user_repository.dart';
import 'package:mr_collection/provider/access_token_provider.dart';
import 'package:mr_collection/provider/member_provider.dart';
import 'package:mr_collection/services/user_service.dart';

final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  final userService = ref.read(userServiceProvider);
  final memberRepository = ref.read(memberRepositoryProvider);
  return UserNotifier(memberRepository, userService, ref);
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

  UserNotifier(this.memberRepository, this.userService, this.ref)
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

  void setUser(User user) {
    state = user;
  }

  Future<User?> registerUser(String accessToken) async {
    try {
      final user = await userService.registerUser(accessToken);
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
}
