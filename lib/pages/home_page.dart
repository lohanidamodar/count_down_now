import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/app_theme.dart';
import '../models/countdown.dart';
import '../services/auth_service.dart';
import '../services/countdown_repository.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _targetDate;
  TimeOfDay? _targetTime;
  String _selectedEmoji = '🎉';
  CountdownTheme _selectedTheme = CountdownTheme.presets[0];
  bool _isPublic = false;

  final List<String> _popularEmojis = [
    '🎉',
    '🎂',
    '🎄',
    '🎊',
    '🚀',
    '✈️',
    '💍',
    '🎓',
    '🏖️',
    '🎯',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );

    if (date != null) {
      setState(() => _targetDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() => _targetTime = time);
    }
  }

  void _createCountdown() {
    if (!_formKey.currentState!.validate()) return;

    if (_targetDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a date')));
      return;
    }

    final targetDateTime = DateTime(
      _targetDate!.year,
      _targetDate!.month,
      _targetDate!.day,
      _targetTime?.hour ?? 0,
      _targetTime?.minute ?? 0,
    );

    final authState = ref.read(authStateProvider);
    final countdown = Countdown(
      slug: Countdown.generateSlug(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      emoji: _selectedEmoji,
      targetDateTime: targetDateTime,
      themeColor: _selectedTheme.getGradientHex(),
      ownerId: authState.user?.$id,
      isPublic: _isPublic,
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving countdown: $e')));
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
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Quick Create Form
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Quick Create',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 24),

                          // Title
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Event Title',
                              hintText: 'My Birthday Party',
                              prefixIcon: Icon(Icons.title),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a title';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Description
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Description (optional)',
                              hintText: 'Add some details...',
                              prefixIcon: Icon(Icons.description),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 16),

                          // Date & Time
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _selectDate,
                                  icon: const Icon(Icons.calendar_today),
                                  label: Text(
                                    _targetDate == null
                                        ? 'Select Date'
                                        : '${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _selectTime,
                                  icon: const Icon(Icons.access_time),
                                  label: Text(
                                    _targetTime == null
                                        ? 'Select Time'
                                        : '${_targetTime!.hour.toString().padLeft(2, '0')}:${_targetTime!.minute.toString().padLeft(2, '0')}',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Emoji Selector
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Emoji',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _popularEmojis.map((emoji) {
                                  final isSelected = emoji == _selectedEmoji;
                                  return InkWell(
                                    onTap: () =>
                                        setState(() => _selectedEmoji = emoji),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isSelected
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                              : Colors.grey.shade300,
                                          width: isSelected ? 2 : 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        emoji,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Theme Selector
                          DropdownButtonFormField<CountdownTheme>(
                            initialValue: _selectedTheme,
                            decoration: const InputDecoration(
                              labelText: 'Color Theme',
                              prefixIcon: Icon(Icons.palette),
                            ),
                            items: CountdownTheme.presets.map((theme) {
                              return DropdownMenuItem(
                                value: theme,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: theme.primaryColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(theme.name),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (theme) {
                              if (theme != null) {
                                setState(() => _selectedTheme = theme);
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Public/Private Toggle
                          Card(
                            color: Colors.blue.shade50,
                            child: SwitchListTile(
                              title: const Text('Make this countdown public'),
                              subtitle: Text(
                                _isPublic
                                    ? 'Anyone with the link can view this countdown'
                                    : 'Only you can view this countdown',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              value: _isPublic,
                              onChanged: (value) {
                                setState(() => _isPublic = value);
                              },
                            ),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
