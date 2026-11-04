import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'hello_providers.dart';

/// Pantalla temporal para comprobar que Flutter, Riverpod y Supabase funcionan.
class HelloScreen extends ConsumerWidget {
  const HelloScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = ref.watch(helloMessageProvider);

    return Scaffold(
      body: Center(
        child: message.when(
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Error al conectar con Supabase:\n$e',
                style: const TextStyle(color: Colors.red)),
          ),
          data: (text) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              Text(text, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              const Text('Flutter + Riverpod + Supabase local: OK'),
            ],
          ),
        ),
      ),
    );
  }
}
