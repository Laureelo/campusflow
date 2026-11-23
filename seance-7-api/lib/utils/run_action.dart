import 'package:flutter/material.dart';

import '../core/api_exception.dart';

Future<bool> runAction(
  BuildContext context,
  Future<void> Function() action,
) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await action();
    return true;
  } on ApiException catch (error) {
    messenger.showSnackBar(SnackBar(content: Text(error.message)));
    return false;
  }
}
