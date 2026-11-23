import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import 'auth_provider.dart';

final userProvider = FutureProvider<User?>((ref) async {
  final signedIn = await ref.watch(authProvider.future);
  if (!signedIn) return null;
  return ref.watch(authRepositoryProvider).currentUser();
});
