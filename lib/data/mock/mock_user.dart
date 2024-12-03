import 'package:mr_collection/data/model/freezed/user.dart';
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:mr_collection/data/model/freezed/member.dart';
import 'package:mr_collection/data/model/payment_status.dart';

const mockUser = (User(
  userId: 1,
  lineUserId: '1',
  paypayUrl: null,
  belongingLineGroupIds: ['1001', '1002'],
  events: [
    Event(
      eventId: 1,
      eventName: '一次会',
      members: [
        Member(
          memberId: 1,
          memberName: 'Aさん',
          lineUserId: 1001,
          status: PaymentStatus.absence,
        ),
        Member(
          memberId: 2,
          memberName: 'Bさん',
          lineUserId: 1002,
          status: PaymentStatus.paid,
        ),
        Member(
          memberId: 3,
          memberName: 'Cさん',
          lineUserId: 1003,
          status: PaymentStatus.unpaid,
        ),
      ],
    ),
    Event(
      eventId: 2,
      eventName: '二次会',
      members: [
        Member(
          memberId: 4,
          memberName: 'Dさん',
          lineUserId: 1004,
          status: PaymentStatus.paid,
        ),
        Member(
          memberId: 5,
          memberName: 'Eさん',
          lineUserId: 1005,
          status: PaymentStatus.absence,
        ),
        Member(
          memberId: 6,
          memberName: 'Fさん',
          lineUserId: 1006,
          status: PaymentStatus.unpaid,
        ),
      ],
    ),
    Event(
      eventId: 3,
      eventName: '三次会',
      members: [
        Member(
          memberId: 7,
          memberName: 'Gさん',
          lineUserId: 1007,
          status: PaymentStatus.unpaid,
        ),
        Member(
          memberId: 8,
          memberName: 'Hさん',
          lineUserId: 1008,
          status: PaymentStatus.paid,
        ),
        Member(
          memberId: 9,
          memberName: 'Iさん',
          lineUserId: 1009,
          status: PaymentStatus.absence,
        ),
      ],
    ),
  ],
));
