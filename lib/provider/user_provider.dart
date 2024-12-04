import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/constants/base_url.dart';
import 'package:mr_collection/data/model/freezed/user.dart';
import 'package:mr_collection/data/repository/user_repository.dart';
import 'package:mr_collection/provider/access_token_provider.dart';
import 'package:mr_collection/services/user_service.dart';

final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  final userService = ref.read(userServiceProvider);
  return UserNotifier(userService, ref);
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

  UserNotifier(this.userService, this.ref) : super(null) {
    // アクセストークンが変更された際にユーザー情報を取得
    ref.listen<String?>(accessTokenProvider, (previous, next) {
      if (next != null) {
        fetchUser(next);
      } else {
        state = null;
      }
    });
  }

  Future<void> fetchUser(String accessToken) async {
    try {
      final user = await userService.fetchUser(accessToken);
      state = user;
    } catch (e) {
      print('ユーザー情報の取得に失敗しました: $e');
      state = null;
    }
  }

  void logoutUser() {
    state = null;
  }
}
