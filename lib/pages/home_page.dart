import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/countdown.dart';
import '../services/auth_service.dart';
import '../services/countdown_repository.dart';
import '../widgets/countdown_form.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final GlobalKey<CountdownFormState> _formKey = GlobalKey();

  Future<void> _createCountdown() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    if (form.targetDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    final targetDateTime = DateTime(
      form.targetDate!.year,
      form.targetDate!.month,
      form.targetDate!.day,
      form.targetTime?.hour ?? 0,
      form.targetTime?.minute ?? 0,
    );

    final authState = ref.read(authStateProvider);
    final countdown = Countdown(
      slug: Countdown.generateSlug(),
      title: form.title,
      description: form.description,
      emoji: form.emoji,
      targetDateTime: targetDateTime,
      themeColor: form.theme.getGradientHex(),
      ownerId: authState.user?.$id,
      isPublic: form.isPublic,
      createdAt: DateTime.now(),
    );

    // If authenticated, save to Appwrite
    if (authState.isAuthenticated) {
      _saveToAppwrite(countdown);
    } else {
      // Save to in-memory store
      ref.read(inMemoryCountdownStoreProvider.notifier).add(countdown);
      context.go('/c/${countdown.slug}');
    }
  }

  Future<void> _saveToAppwrite(Countdown countdown) async {
    try {
      final repository = ref.read(countdownRepositoryProvider);
      final saved = await repository.create(countdown);

      if (mounted) {
        context.go('/c/${saved.slug}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving countdown: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.timer, size: 28),
            const SizedBox(width: 8),
            Text(
              'CountDownNow',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/create'),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Create'),
          ),
          if (authState.isAuthenticated)
            TextButton.icon(
              onPressed: () => context.go('/dashboard'),
              icon: const Icon(Icons.dashboard),
              label: const Text('Dashboard'),
            ),
          if (authState.isAuthenticated)
            TextButton.icon(
              onPressed: () {
                ref.read(authStateProvider.notifier).logout();
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            )
          else
            TextButton.icon(
              onPressed: () => context.go('/login'),
              icon: const Icon(Icons.login),
              label: const Text('Login'),
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Section
                Icon(
                  Icons.timer,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'CountDownNow',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create beautiful countdown pages for your special events',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Quick Create Form
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Quick Create',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 24),

                        CountdownForm(
                          key: _formKey,
                          isCompact: true,
                        ),

                        const SizedBox(height: 24),

                        // Create Button
                        ElevatedButton.icon(
                          onPressed: _createCountdown,
                          icon: const Icon(Icons.add_circle),
                          label: const Text('Create Countdown'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),

                        if (!authState.isAuthenticated) ...[
                          const SizedBox(height: 16),
                          Text(
                            '💡 Tip: Login to save and manage your countdowns!',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
