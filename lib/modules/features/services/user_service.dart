import 'package:mr_collection/modules/features/data/model/freezed/line_group.dart';
import 'package:mr_collection/modules/features/data/model/freezed/user.dart';
import 'package:mr_collection/modules/features/data/repository/user_repository.dart';

class UserService {
  final UserRepository userRepository;

  UserService(this.userRepository);

  Future<User?> registerUser(String accessToken) async {
    return userRepository.registerUser(accessToken);
  }

  Future<User?> registerLineUser(String accessToken) async {
    return userRepository.registerLineUser(accessToken);
  }

  Future<User?> fetchUserById(String userId) {
    return userRepository.fetchUserById(userId);
  }

  Future<User?> fetchLineUserById(String userId, String lineAccessToken) {
    return userRepository.fetchLineUserById(userId, lineAccessToken);
  }

  Future<List<LineGroup>> getLineGroups(String userId) {
    return userRepository.getLineGroups(userId);
  }

  Future<LineGroup> refreshLineGroupMember(String userId, String groupId) {
    return userRepository.refreshLineGroupMember(userId, groupId);
  }
}
