import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/countdown.dart';
import '../services/auth_service.dart';
import '../services/countdown_repository.dart';
import '../widgets/countdown_form.dart';

class CreateEditCountdownPage extends ConsumerStatefulWidget {
  final String? countdownId;

  const CreateEditCountdownPage({super.key, this.countdownId});

  @override
  ConsumerState<CreateEditCountdownPage> createState() =>
      _CreateEditCountdownPageState();
}

class _CreateEditCountdownPageState
    extends ConsumerState<CreateEditCountdownPage> {
  final GlobalKey<CountdownFormState> _formKey = GlobalKey();
  bool _isLoading = false;
  Countdown? _existingCountdown;

  @override
  void initState() {
    super.initState();
    if (widget.countdownId != null) {
      _loadCountdown();
    }
  }

  Future<void> _loadCountdown() async {
    setState(() => _isLoading = true);

    try {
      final repository = ref.read(countdownRepositoryProvider);
      final countdown = await repository.getById(widget.countdownId!);

      if (countdown == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Countdown not found')),
          );
          context.go('/dashboard');
        }
        return;
      }

      setState(() {
        _existingCountdown = countdown;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading countdown: $e')),
        );
        context.go('/dashboard');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveCountdown() async {
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
      id: _existingCountdown?.id,
      slug: _existingCountdown?.slug ?? Countdown.generateSlug(),
      title: form.title,
      description: form.description,
      emoji: form.emoji,
      targetDateTime: targetDateTime,
      themeColor: form.theme.getGradientHex(),
      ownerId: authState.user?.$id,
      isPublic: form.isPublic,
      createdAt: _existingCountdown?.createdAt ?? DateTime.now(),
    );

    setState(() => _isLoading = true);

    try {
      if (authState.isAuthenticated) {
        final repository = ref.read(countdownRepositoryProvider);

        if (_existingCountdown != null) {
          await repository.update(countdown);
        } else {
          await repository.create(countdown);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Countdown saved!')),
          );
          context.go('/dashboard');
        }
      } else {
        // Save to in-memory store
        ref.read(inMemoryCountdownStoreProvider.notifier).add(countdown);

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Countdown Created!'),
              content: const Text(
                'Your countdown has been created. Login to save it permanently and manage it later.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/login');
                  },
                  child: const Text('Login'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/c/${countdown.slug}');
                  },
                  child: const Text('View Countdown'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _existingCountdown == null ? 'Create Countdown' : 'Edit Countdown',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: _isLoading && _existingCountdown == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CountdownForm(
                        key: _formKey,
                        countdownId: widget.countdownId,
                        initialCountdown: _existingCountdown,
                        isCompact: false,
                      ),
                      const SizedBox(height: 32),

                      // Save Button
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _saveCountdown,
                        icon: const Icon(Icons.save),
                        label: Text(
                          _existingCountdown == null
                              ? 'Create Countdown'
                              : 'Update Countdown',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),

                      if (!authState.isAuthenticated) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Login to save your countdown permanently and manage it from your dashboard.',
                                  style: TextStyle(
                                    color: Colors.blue.shade900,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
