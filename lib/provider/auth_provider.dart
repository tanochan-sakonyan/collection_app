import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/data/repository/auth_repository.dart';
import 'package:mr_collection/services/auth_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(baseUrl: 'https://your-api-url.com');
});

final authServiceProvider = Provider<AuthService>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return AuthService(authRepository);
});
