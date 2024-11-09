import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/data/model/freezed/user.dart';
import 'package:mr_collection/data/repository/user_repository.dart';
import 'package:mr_collection/services/user_service.dart';

final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  final userService = ref.read(userServiceProvider);
  return UserNotifier(userService);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(baseUrl: 'https://your-api-url.com'); // TODO BE待ち
});

final userServiceProvider = Provider<UserService>((ref) {
  final userRepository = ref.read(userRepositoryProvider);
  return UserService(userRepository);
});

class UserNotifier extends StateNotifier<User?> {
  final UserService userService;

  UserNotifier(this.userService) : super(null);

  Future<void> registerUser(
      WidgetRef ref, String email, String password) async {
    try {
      final user = await userService.registerUser(ref, email, password);
      state = user;
    } catch (e) {
      // エラーハンドリング
      print('Error: $e');
    }
  }

  Future<void> loginUser(WidgetRef ref, String email, String password) async {
    try {
      final user = await userService.loginUser(ref, email, password);
      state = user;
    } catch (e) {
      // エラーハンドリング
      print('Error: $e');
    }
  }

  void logoutUser() {
    state = null;
  }
}
