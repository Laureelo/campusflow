import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../core/auth_interceptor.dart';
import '../core/token_storage.dart';
import '../data/auth_repository.dart';

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => const SecureTokenStorage(),
);

final dioProvider = Provider<Dio>((ref) {
  final dio = buildDio();
  dio.interceptors.add(
    AuthInterceptor(
      storage: ref.watch(tokenStorageProvider),
      onUnauthorized: () => ref.read(authProvider.notifier).expireSession(),
    ),
  );
  return dio;
});

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => ApiAuthRepository(ref.watch(dioProvider)),
);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final token = await ref.read(tokenStorageProvider).read();
    return token != null;
  }

  Future<void> signIn({required String email, required String password}) async {
    final token = await ref
        .read(authRepositoryProvider)
        .login(email: email, password: password);
    await ref.read(tokenStorageProvider).write(token);
    state = const AsyncData(true);
  }

  Future<void> signOut() async {
    await ref.read(tokenStorageProvider).delete();
    state = const AsyncData(false);
  }

  Future<void> expireSession() => signOut();
}

final authProvider = AsyncNotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);
