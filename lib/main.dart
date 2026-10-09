import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/errors/error_boundary.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize clinical safety boundaries and error handlers
  setupGlobalErrorBoundaries();

  // Root entrypoint wrapped in ProviderScope for Riverpod state management
  runApp(
    const ProviderScope(
      child: MediCareApp(),
    ),
  );
}
