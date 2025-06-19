import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/provider/event_repository_provider.dart';
import 'package:mr_collection/provider/member_repository_provider.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/data/repository/member_repository.dart';
import 'package:mr_collection/data/repository/event_repository.dart';
import 'package:mr_collection/data/model/freezed/member.dart';
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:mr_collection/data/model/freezed/user.dart';
import 'package:mr_collection/data/model/payment_status.dart';
import 'package:mr_collection/services/user_service.dart';
import 'package:mr_collection/data/repository/user_repository.dart';

class FakeMemberRepository extends MemberRepository {
  FakeMemberRepository() : super(baseUrl: '');
  List<String>? receivedNames;
  @override
  Future<List<Member>> createMembers(
      String userId, String eventId, List<String> newMemberNames) async {
    receivedNames = newMemberNames;
    return newMemberNames
        .map((name) => Member(
              memberId: 'id_\$name',
              memberName: name,
              status: PaymentStatus.unpaid,
            ))
        .toList();
  }
}

class FakeEventRepository extends EventRepository {
  FakeEventRepository() : super(baseUrl: '');
}

class FakeUserService extends UserService {
  FakeUserService() : super(UserRepository(baseUrl: ''));
}

void main() {
  group('UserNotifier.createMembers', () {
    test('adds members returned by repository', () async {
      final memberRepo = FakeMemberRepository();
      final container = ProviderContainer(overrides: [
        memberRepositoryProvider.overrideWithValue(memberRepo),
        eventRepositoryProvider.overrideWithValue(FakeEventRepository()),
        userServiceProvider.overrideWithValue(FakeUserService()),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(userProvider.notifier);
      const event = Event(eventId: 'e1', eventName: 'event', members: []);
      const user = User(
        userId: 'u1',
        appleId: null,
        lineUserId: null,
        paypayUrl: null,
        belongingLineGroupIds: null,
        events: [event],
      );
      notifier.state = user;

      await notifier.createMembers('u1', 'e1', 'Alice\nBob');

      final updatedMembers = notifier.state!.events.first.members;
      expect(
          updatedMembers.map((m) => m.memberName).toList(), ['Alice', 'Bob']);
      expect(memberRepo.receivedNames, ['Alice', 'Bob']);
    });
  });
}
