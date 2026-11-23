import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import 'error_view.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return user.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          ErrorView(error: error, onRetry: () => ref.invalidate(userProvider)),
      data: (user) {
        if (user == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                child: Text(
                  user.name.substring(0, 1),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 16),
              Text(user.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(user.email),
              Text('${user.age} years old'),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => ref.read(authProvider.notifier).signOut(),
                child: const Text('Sign out'),
              ),
            ],
          ),
        );
      },
    );
  }
}
