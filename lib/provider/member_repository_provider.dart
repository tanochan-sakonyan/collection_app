import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/constants/base_url.dart';
import 'package:mr_collection/data/repository/member_repository.dart';

final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  return MemberRepository(baseUrl: baseUrl);
});
