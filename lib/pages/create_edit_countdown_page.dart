import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/app_theme.dart';
import '../models/countdown.dart';
import '../services/auth_service.dart';
import '../services/countdown_repository.dart';

class CreateEditCountdownPage extends ConsumerStatefulWidget {
  final String? countdownId;

  const CreateEditCountdownPage({super.key, this.countdownId});

  @override
  ConsumerState<CreateEditCountdownPage> createState() =>
      _CreateEditCountdownPageState();
}

class _CreateEditCountdownPageState
    extends ConsumerState<CreateEditCountdownPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _targetDate;
  TimeOfDay? _targetTime;
  String _selectedEmoji = '🎉';
  CountdownTheme _selectedTheme = CountdownTheme.presets[0];
  bool _isLoading = false;
  Countdown? _existingCountdown;

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
    '❤️',
    '🌟',
    '🎁',
    '🏆',
    '🌺',
    '🎸',
  ];

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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Countdown not found')));
          context.go('/dashboard');
        }
        return;
      }

      // Pre-populate form fields with existing countdown data
      setState(() {
        _existingCountdown = countdown;
        _titleController.text = countdown.title;
        _descriptionController.text = countdown.description ?? '';
        _targetDate = DateTime(
          countdown.targetDateTime.year,
          countdown.targetDateTime.month,
          countdown.targetDateTime.day,
        );
        _targetTime = TimeOfDay(
          hour: countdown.targetDateTime.hour,
          minute: countdown.targetDateTime.minute,
        );
        _selectedEmoji = countdown.emoji ?? '🎉';
        _selectedTheme = CountdownTheme.presets.firstWhere(
          (theme) => theme.name == countdown.themeColor,
          orElse: () => CountdownTheme.presets[0],
        );
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading countdown: $e')));
        context.go('/dashboard');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 1)),
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
      initialTime: _targetTime ?? TimeOfDay.now(),
    );

    if (time != null) {
      setState(() => _targetTime = time);
    }
  }

  Future<void> _saveCountdown() async {
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
      id: _existingCountdown?.id,
      slug: _existingCountdown?.slug ?? Countdown.generateSlug(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      emoji: _selectedEmoji,
      targetDateTime: targetDateTime,
      themeColor: _selectedTheme.name,
      ownerId: authState.user?.$id,
      isPublic: true,
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Countdown saved!')));
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Event Title *',
                            hintText: 'My Awesome Event',
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
                            labelText: 'Description',
                            hintText: 'Add more details about your event...',
                            prefixIcon: Icon(Icons.description),
                          ),
                          maxLines: 3,
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
                                      ? 'Select Date *'
                                      : '${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}',
                                  style: TextStyle(
                                    color: _targetDate == null
                                        ? Colors.grey
                                        : null,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _selectTime,
                                icon: const Icon(Icons.access_time),
                                label: Text(
                                  _targetTime == null
                                      ? 'Select Time'
                                      : '${_targetTime!.hour.toString().padLeft(2, '0')}:${_targetTime!.minute.toString().padLeft(2, '0')}',
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Emoji Selector
                        Text(
                          'Select Emoji',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _popularEmojis.map((emoji) {
                            final isSelected = emoji == _selectedEmoji;
                            return InkWell(
                              onTap: () =>
                                  setState(() => _selectedEmoji = emoji),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey.shade300,
                                    width: isSelected ? 3 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                            .withValues(alpha: 0.1)
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    emoji,
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),

                        // Theme Selector
                        Text(
                          'Color Theme',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: CountdownTheme.presets.map((theme) {
                            final isSelected = theme == _selectedTheme;
                            return InkWell(
                              onTap: () =>
                                  setState(() => _selectedTheme = theme),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey.shade300,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: theme.getGradient(),
                                  color: theme.getGradient() == null
                                      ? theme.primaryColor
                                      : null,
                                ),
                                child: Text(
                                  theme.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 32),

                        // Save Button
                        ElevatedButton.icon(
                          onPressed: _saveCountdown,
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
            ),
    );
  }
}
