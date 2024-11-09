import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/data/repository/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(baseUrl: 'https://your-api-url.com');
});
