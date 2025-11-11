import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/app_theme.dart';
import '../models/countdown.dart';
import '../services/countdown_repository.dart';

class CountdownViewPage extends ConsumerStatefulWidget {
  final String slug;

  const CountdownViewPage({super.key, required this.slug});

  @override
  ConsumerState<CountdownViewPage> createState() => _CountdownViewPageState();
}

class _CountdownViewPageState extends ConsumerState<CountdownViewPage> {
  Timer? _timer;
  Countdown? _countdown;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCountdown();
  }

  Future<void> _loadCountdown() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // First check in-memory store
      final inMemoryCountdown = ref
          .read(inMemoryCountdownStoreProvider.notifier)
          .getBySlug(widget.slug);

      if (inMemoryCountdown != null) {
        setState(() {
          _countdown = inMemoryCountdown;
          _isLoading = false;
        });
        _startTimer();
        return;
      }

      // Then check Appwrite
      final repository = ref.read(countdownRepositoryProvider);
      final countdown = await repository.getBySlug(widget.slug);

      if (countdown == null) {
        setState(() {
          _error = 'Countdown not found';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _countdown = countdown;
        _isLoading = false;
      });
      _startTimer();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _copyLink() {
    final url =
        '${Uri.base.toString().replaceAll(Uri.base.path, '')}/c/${widget.slug}';
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null || _countdown == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Countdown not found',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home),
                label: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    }

    final countdown = _countdown!;
    final theme = CountdownTheme.fromName(countdown.themeColor);
    final timeRemaining = countdown.timeRemaining;
    final isFinished = countdown.isFinished;

    final days = isFinished ? 0 : timeRemaining.inDays;
    final hours = isFinished ? 0 : timeRemaining.inHours.remainder(24);
    final minutes = isFinished ? 0 : timeRemaining.inMinutes.remainder(60);
    final seconds = isFinished ? 0 : timeRemaining.inSeconds.remainder(60);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: theme.getGradient(),
          color: theme.getGradient() == null ? theme.primaryColor : null,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main Content
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Emoji
                      if (countdown.emoji != null)
                        Text(
                          countdown.emoji!,
                          style: const TextStyle(fontSize: 80),
                        ),
                      const SizedBox(height: 24),

                      // Title
                      Text(
                        countdown.title,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Description
                      if (countdown.description != null)
                        Text(
                          countdown.description!,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 48),

                      // Countdown Display
                      if (isFinished)
                        Column(
                          children: [
                            const Text('🎉', style: TextStyle(fontSize: 80)),
                            const SizedBox(height: 16),
                            const Text(
                              "It's time!",
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'The event has arrived!',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        )
                      else
                        IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildTimeCard(days, 'Day'),
                              const SizedBox(width: 16),
                              _buildTimeCard(hours, 'Hour'),
                              const SizedBox(width: 16),
                              _buildTimeCard(minutes, 'Minute'),
                              const SizedBox(width: 16),
                              _buildTimeCard(seconds, 'Second'),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Top Actions
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.home, color: Colors.white),
                  style: IconButton.styleFrom(backgroundColor: Colors.black26),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  onPressed: _copyLink,
                  icon: const Icon(Icons.share, color: Colors.white),
                  style: IconButton.styleFrom(backgroundColor: Colors.black26),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeCard(int value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$label${value == 1 ? '' : 's'}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
