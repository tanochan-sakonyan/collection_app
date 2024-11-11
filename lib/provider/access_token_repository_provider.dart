import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/data/repository/access_token_repository.dart';

final accessTokenRepositoryProvider =
    Provider((ref) => AccessTokenRepository());
