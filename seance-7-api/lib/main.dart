import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';

void main() {
  runApp(ProviderScope(retry: (_, _) => null, child: const CampusFlowApp()));
}

class CampusFlowApp extends ConsumerWidget {
  const CampusFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'CampusFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
