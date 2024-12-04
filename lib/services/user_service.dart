import 'package:mr_collection/data/model/freezed/user.dart';
import 'package:mr_collection/data/repository/user_repository.dart';

class UserService {
  final UserRepository userRepository;

  UserService(this.userRepository);

  Future<User> fetchUser(String accessToken) async {
    return userRepository.fetchUser(accessToken);
  }
}
