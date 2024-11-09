import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/data/model/freezed/user.dart';
import 'package:mr_collection/data/repository/user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(baseUrl: 'https://your-api-url.com'); // TODO BE待ち
});

final userProvider = StateProvider<User?>((ref) => null);
