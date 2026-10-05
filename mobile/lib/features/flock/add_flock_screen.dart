import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import 'services/flock_service.dart';

class AddFlockScreen extends StatefulWidget {
  const AddFlockScreen({super.key});

  @override
  State<AddFlockScreen> createState() => _AddFlockScreenState();
}

class _AddFlockScreenState extends State<AddFlockScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _initialBirdCountController = TextEditingController();
  final _currentBirdCountController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _startDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _initialBirdCountController.dispose();
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

  Future<void> _createFlock() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FlockService.createFlock(
        name: _nameController.text,
        breed: _breedController.text,
        startDate: _startDate,
        initialBirdCount: int.parse(_initialBirdCountController.text.trim()),
        currentBirdCount: int.parse(_currentBirdCountController.text.trim()),
        notes: _notesController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flock created successfully.')),
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
      appBar: AppBar(title: const Text('Add flock')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Create a new flock',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Add the basic details for this poultry batch.',
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

                    if (name.isEmpty) {
                      return 'Enter the flock name';
                    }

                    if (name.length < 2) {
                      return 'Flock name is too short';
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

                    if (breed.isEmpty) {
                      return 'Enter the breed';
                    }

                    if (breed.length < 2) {
                      return 'Breed name is too short';
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
                  controller: _initialBirdCountController,
                  label: 'Initial bird count',
                  hint: 'Example: 5000',
                  prefixIcon: Icons.numbers_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final count = int.tryParse(value?.trim() ?? '');

                    if (count == null || count <= 0) {
                      return 'Enter a valid initial bird count';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                AppTextField(
                  controller: _currentBirdCountController,
                  label: 'Current bird count',
                  hint: 'Example: 4975',
                  prefixIcon: Icons.calculate_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final currentCount = int.tryParse(value?.trim() ?? '');

                    if (currentCount == null || currentCount <= 0) {
                      return 'Enter a valid current bird count';
                    }

                    final initialCount = int.tryParse(
                      _initialBirdCountController.text.trim(),
                    );

                    if (initialCount != null && currentCount > initialCount) {
                      return 'Current count cannot exceed initial count';
                    }

                    return null;
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
                  text: 'Create flock',
                  icon: Icons.add_circle_outline,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _createFlock,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
