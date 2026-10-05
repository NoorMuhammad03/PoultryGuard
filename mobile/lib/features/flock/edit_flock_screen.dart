import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import 'models/flock.dart';
import 'services/flock_service.dart';

class EditFlockScreen extends StatefulWidget {
  const EditFlockScreen({super.key, required this.flock});

  final Flock flock;

  @override
  State<EditFlockScreen> createState() => _EditFlockScreenState();
}

class _EditFlockScreenState extends State<EditFlockScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _breedController;
  late final TextEditingController _currentBirdCountController;
  late final TextEditingController _notesController;

  late DateTime _startDate;
  late String _status;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.flock.name);

    _breedController = TextEditingController(text: widget.flock.breed);

    _currentBirdCountController = TextEditingController(
      text: widget.flock.currentBirdCount.toString(),
    );

    _notesController = TextEditingController(text: widget.flock.notes ?? '');

    _startDate = widget.flock.startDate;
    _status = widget.flock.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _currentBirdCountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _startDate = selectedDate;
    });
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FlockService.updateFlock(
        flockId: widget.flock.id,
        name: _nameController.text,
        breed: _breedController.text,
        startDate: _startDate,
        currentBirdCount: int.parse(_currentBirdCountController.text.trim()),
        status: _status,
        notes: _notesController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flock updated successfully.')),
      );

      Navigator.pop(context, true);
    } on FlockException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Edit flock')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Update flock details',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Update the flock information below.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 28),

                AppTextField(
                  controller: _nameController,
                  label: 'Flock name',
                  hint: 'Example: Batch A',
                  prefixIcon: Icons.groups_outlined,
                  validator: (value) {
                    final name = value?.trim() ?? '';

                    if (name.length < 2) {
                      return 'Enter a valid flock name';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                AppTextField(
                  controller: _breedController,
                  label: 'Breed',
                  hint: 'Example: Ross 308',
                  prefixIcon: Icons.pets_outlined,
                  validator: (value) {
                    final breed = value?.trim() ?? '';

                    if (breed.length < 2) {
                      return 'Enter a valid breed';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                InkWell(
                  onTap: _isLoading ? null : _pickStartDate,
                  borderRadius: BorderRadius.circular(14),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Start date',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    child: Text(
                      _formatDate(_startDate),
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                AppTextField(
                  controller: _currentBirdCountController,
                  label: 'Current bird count',
                  hint: 'Example: 4950',
                  prefixIcon: Icons.calculate_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final count = int.tryParse(value?.trim() ?? '');

                    if (count == null || count <= 0) {
                      return 'Enter a valid current bird count';
                    }

                    if (count > widget.flock.initialBirdCount) {
                      return 'Current count cannot exceed initial count';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.info_outline),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(
                      value: 'completed',
                      child: Text('Completed'),
                    ),
                  ],
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          if (value == null) return;

                          setState(() {
                            _status = value;
                          });
                        },
                ),

                const SizedBox(height: 16),

                AppTextField(
                  controller: _notesController,
                  label: 'Notes',
                  hint: 'Optional notes about this flock',
                  prefixIcon: Icons.notes_outlined,
                  maxLines: 3,
                ),

                const SizedBox(height: 28),

                AppButton(
                  text: 'Save changes',
                  icon: Icons.save_outlined,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _saveChanges,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
