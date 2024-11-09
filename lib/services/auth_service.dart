import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/data/repository/auth_repository.dart';
import 'package:mr_collection/provider/auth_repository_provider.dart';

class AuthService {
  final AuthRepository _authRepository;

  AuthService(this._authRepository);

  Future<bool> verifyAccessToken(String accessToken) {
    return _authRepository.verifyAccessToken(accessToken);
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return AuthService(authRepository);
});
