import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/modules/features/constants/base_url.dart';
import 'package:mr_collection/modules/features/data/repository/member_repository.dart';

final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  return MemberRepository(baseUrl: baseUrl);
});
