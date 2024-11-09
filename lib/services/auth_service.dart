import 'package:mr_collection/data/repository/auth_repository.dart';

class AuthService {
  final AuthRepository _authRepository;

  AuthService(this._authRepository);

  Future<bool> verifyAccessToken(String accessToken) {
    return _authRepository.verifyAccessToken(accessToken);
  }
}
