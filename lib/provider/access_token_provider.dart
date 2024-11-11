import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/provider/access_token_repository_provider.dart';

final accessTokenProvider = FutureProvider<StoredAccessToken?>((ref) async {
  return await ref.read(accessTokenRepositoryProvider).fetchAccessToken();
});
