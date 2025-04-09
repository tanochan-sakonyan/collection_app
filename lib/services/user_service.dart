import 'package:mr_collection/data/model/freezed/user.dart';
import 'package:mr_collection/data/repository/user_repository.dart';

class UserService {
  final UserRepository userRepository;

  UserService(this.userRepository);

  Future<User?> registerUser(String accessToken) async {
    return userRepository.registerUser(accessToken);
  }

  Future<User?> registerUserByApple() async {
    return userRepository.registerUserByApple();
  }

  Future<User?> fetchUserById(String userId) {
    return userRepository.fetchUserById(userId);
  }
}
