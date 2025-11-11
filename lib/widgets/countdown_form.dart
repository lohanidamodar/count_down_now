import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_theme.dart';
import '../models/countdown.dart';

class CountdownForm extends ConsumerStatefulWidget {
  final String? countdownId;
  final Countdown? initialCountdown;
  final VoidCallback? onSuccess;
  final bool isCompact;

  const CountdownForm({
    super.key,
    this.countdownId,
    this.initialCountdown,
    this.onSuccess,
    this.isCompact = false,
  });

  @override
  ConsumerState<CountdownForm> createState() => CountdownFormState();
}

class CountdownFormState extends ConsumerState<CountdownForm> {
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
    '❤️',
    '🌟',
    '🎁',
    '🏆',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCountdown != null) {
      _loadInitialData(widget.initialCountdown!);
    }
  }

  void _loadInitialData(Countdown countdown) {
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
    _isPublic = countdown.isPublic;

    // Match theme by comparing hex values to find the preset
    final hexValue = countdown.themeColor;
    _selectedTheme = CountdownTheme.presets.firstWhere(
      (theme) => theme.getGradientHex() == hexValue,
      orElse: () => CountdownTheme.presets[0],
    );
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: widget.isCompact ? 'Event Title' : 'Event Title *',
              hintText: widget.isCompact
                  ? 'My Birthday Party'
                  : 'My Awesome Event',
              prefixIcon: const Icon(Icons.title),
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
            decoration: InputDecoration(
              labelText: widget.isCompact
                  ? 'Description (optional)'
                  : 'Description',
              hintText: widget.isCompact
                  ? 'Add some details...'
                  : 'Add more details about your event...',
              prefixIcon: const Icon(Icons.description),
            ),
            maxLines: widget.isCompact ? 2 : 3,
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
                        ? 'Select Date ${widget.isCompact ? '' : '*'}'
                        : '${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}',
                    style: TextStyle(
                      color: _targetDate == null ? Colors.grey : null,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              SizedBox(width: widget.isCompact ? 8 : 16),
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: widget.isCompact ? 16 : 24),

          // Emoji Selector
          _buildEmojiSelector(),
          SizedBox(height: widget.isCompact ? 16 : 24),

          // Theme Selector
          _buildThemeSelector(),
          SizedBox(height: widget.isCompact ? 16 : 24),

          // Public/Private Toggle
          Card(
            color: Colors.blue.shade50,
            child: SwitchListTile(
              title: const Text('Make this countdown public'),
              subtitle: Text(
                _isPublic
                    ? 'Anyone with the link can view this countdown'
                    : 'Only you can view this countdown',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
              value: _isPublic,
              onChanged: (value) {
                setState(() => _isPublic = value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiSelector() {
    final emojis = widget.isCompact ? _popularEmojis.take(10) : _popularEmojis;
    final spacing = widget.isCompact ? 8.0 : 12.0;
    final borderRadius = widget.isCompact ? 8.0 : 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Emoji',
          style: widget.isCompact
              ? Theme.of(context).textTheme.titleSmall
              : Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: widget.isCompact ? 8 : 12),
        Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: emojis.map((emoji) {
            final isSelected = emoji == _selectedEmoji;
            return InkWell(
              onTap: () => setState(() => _selectedEmoji = emoji),
              borderRadius: BorderRadius.circular(borderRadius),
              child: Container(
                width: widget.isCompact ? null : 56,
                height: widget.isCompact ? null : 56,
                padding: widget.isCompact ? const EdgeInsets.all(8) : null,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                    width: isSelected ? (widget.isCompact ? 2 : 3) : 1,
                  ),
                  borderRadius: BorderRadius.circular(borderRadius),
                  color: !widget.isCompact && isSelected
                      ? Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1)
                      : null,
                ),
                child: widget.isCompact
                    ? Text(emoji, style: const TextStyle(fontSize: 24))
                    : Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildThemeSelector() {
    return DropdownButtonFormField<CountdownTheme>(
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
    );
  }

  // Expose these getters for parent widgets to access form data
  bool validate() => _formKey.currentState?.validate() ?? false;

  DateTime? get targetDate => _targetDate;
  TimeOfDay? get targetTime => _targetTime;
  String get title => _titleController.text.trim();
  String? get description => _descriptionController.text.trim().isEmpty
      ? null
      : _descriptionController.text.trim();
  String get emoji => _selectedEmoji;
  CountdownTheme get theme => _selectedTheme;
  bool get isPublic => _isPublic;
}
