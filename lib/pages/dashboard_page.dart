import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/countdown.dart';
import '../services/auth_service.dart';
import '../services/countdown_repository.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  List<Countdown> _countdowns = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCountdowns();
  }

  Future<void> _loadCountdowns() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authState = ref.read(authStateProvider);
      if (authState.user == null) {
        setState(() {
          _error = 'Please login to view your dashboard';
          _isLoading = false;
        });
        return;
      }

      final repository = ref.read(countdownRepositoryProvider);
      final countdowns = await repository.getByOwner(authState.user!.$id);

      setState(() {
        _countdowns = countdowns;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteCountdown(Countdown countdown) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Countdown'),
        content: Text('Are you sure you want to delete "${countdown.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final repository = ref.read(countdownRepositoryProvider);
      await repository.delete(countdown.id!);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Countdown deleted')));
        _loadCountdowns();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting countdown: $e')));
      }
    }
  }

  void _copyLink(String slug) {
    final url = '${Uri.base.toString().replaceAll(Uri.base.path, '')}/c/$slug';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Countdowns'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCountdowns,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
              context.go('/');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(_error!),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadCountdowns,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _countdowns.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer_off, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No countdowns yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first countdown to get started',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/create'),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Countdown'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadCountdowns,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 800;
                  final crossAxisCount = isWide ? 3 : 1;

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: isWide ? 1.5 : 2.5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _countdowns.length,
                    itemBuilder: (context, index) {
                      final countdown = _countdowns[index];
                      return _buildCountdownCard(countdown);
                    },
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/create'),
        icon: const Icon(Icons.add),
        label: const Text('New Countdown'),
      ),
    );
  }

  Widget _buildCountdownCard(Countdown countdown) {
    final timeRemaining = countdown.timeRemaining;
    final isFinished = countdown.isFinished;

    String timeRemainingText;
    if (isFinished) {
      timeRemainingText = 'Event passed';
    } else {
      final days = timeRemaining.inDays;
      final hours = timeRemaining.inHours.remainder(24);
      final minutes = timeRemaining.inMinutes.remainder(60);

      if (days > 0) {
        timeRemainingText =
            '$days day${days > 1 ? 's' : ''}, $hours hour${hours > 1 ? 's' : ''}';
      } else if (hours > 0) {
        timeRemainingText =
            '$hours hour${hours > 1 ? 's' : ''}, $minutes min${minutes > 1 ? 's' : ''}';
      } else {
        timeRemainingText = '$minutes minute${minutes > 1 ? 's' : ''}';
      }
    }

    return Card(
      child: InkWell(
        onTap: () => context.go('/c/${countdown.slug}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (countdown.emoji != null)
                    Text(
                      countdown.emoji!,
                      style: const TextStyle(fontSize: 32),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          countdown.title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat(
                            'MMM dd, yyyy • HH:mm',
                          ).format(countdown.targetDateTime),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isFinished
                      ? Colors.grey.shade200
                      : Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  timeRemainingText,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isFinished
                        ? Colors.grey.shade700
                        : Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.link, size: 20),
                    onPressed: () => _copyLink(countdown.slug),
                    tooltip: 'Copy Link',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.visibility, size: 20),
                    onPressed: () => context.go('/c/${countdown.slug}'),
                    tooltip: 'View',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue.shade100,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () => _deleteCountdown(countdown),
                    tooltip: 'Delete',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
