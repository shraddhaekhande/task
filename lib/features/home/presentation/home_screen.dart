import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/home_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const routePath = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Home'),
        actions: [
          IconButton(
            onPressed: () =>
                ref.read(homeControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: state.when(
        data: (profile) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (profile != null)
                Text(
                  'Welcome ${profile.displayName ?? profile.phoneNumber ?? ''}',
                  style: Theme.of(context).textTheme.headlineSmall,
                )
              else
                const Text('No profile data available'),
              const SizedBox(height: 12),
              Text('Phone: ${profile?.phoneNumber ?? 'Unknown'}'),
              if (profile?.email != null)
                Text('Email: ${profile?.email ?? ''}'),
              const SizedBox(height: 24),
              Text(
                'JWT issued at: ${profile?.issuedAt?.toIso8601String() ?? '-'}',
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                err.toString(),
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    ref.read(homeControllerProvider.notifier).refreshProfile(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

