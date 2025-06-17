import 'package:mr_collection/data/model/freezed/lineGroup.dart';
import 'package:mr_collection/data/model/freezed/user.dart';
import 'package:mr_collection/data/repository/user_repository.dart';

class UserService {
  final UserRepository userRepository;

  UserService(this.userRepository);

  Future<User?> registerUser(String accessToken) async {
    return userRepository.registerUser(accessToken);
  }

  Future<User?> fetchUserById(String userId) {
    return userRepository.fetchUserById(userId);
  }

  Future<List<LineGroup>> getLineGroups(String userId) {
    return userRepository.getLineGroups(userId);
  }

  Future<LineGroup> refreshLineGroupMember(String userId, String groupId){
    return userRepository.refreshLineGroupMember(userId, groupId);
  }
}
