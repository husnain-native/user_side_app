import 'package:flutter/material.dart';

Future<void> showAppErrorDialog(
  BuildContext context,
  String message, {
  String title = 'Something went wrong',
}) async {
  await showDialog(
    context: context,
    builder:
        (ctx) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              child: const Text('OK'),
            ),
          ],
        ),
  );
}

Future<void> showAppInfoDialog(
  BuildContext context,
  String message, {
  String title = 'Notice',
}) async {
  await showDialog(
    context: context,
    builder:
        (ctx) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              child: const Text('OK'),
            ),
          ],
        ),
  );
}
