import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/data/model/freezed/user.dart';
import 'package:mr_collection/data/repository/user_repository.dart';
import 'package:mr_collection/services/user_service.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(baseUrl: 'https://your-api-url.com'); // TODO BE待ち
});

final userProvider = StateProvider<User?>((ref) => null);

final userServiceProvider = Provider<UserService>((ref) {
  final userRepository = ref.read(userRepositoryProvider);
  return UserService(userRepository);
});
