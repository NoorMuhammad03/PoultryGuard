import 'package:flutter/material.dart';

import '../../app/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../authentication/services/registration_draft.dart';
import 'services/farm_service.dart';

class FarmRegistrationScreen extends StatefulWidget {
  const FarmRegistrationScreen({super.key});

  @override
  State<FarmRegistrationScreen> createState() => _FarmRegistrationScreenState();
}

class _FarmRegistrationScreenState extends State<FarmRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _farmNameController = TextEditingController();
  final _capacityController = TextEditingController();
  final _addressController = TextEditingController();

  bool sensorAlertsEnabled = true;
  bool diseaseAlertsEnabled = true;
  bool communityAlertsEnabled = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _farmNameController.dispose();
    _capacityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> saveFarm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FarmService.createFarm(
        farmName: _farmNameController.text.trim(),
        address: _addressController.text.trim(),
        birdCapacity: int.parse(_capacityController.text.trim()),
        latitude: null,
        longitude: null,
        sensorAlerts: sensorAlertsEnabled,
        diseaseAlerts: diseaseAlertsEnabled,
        communityAlerts: communityAlertsEnabled,
      );

      RegistrationDraft.clear();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.farmerDashboard,
        (route) => false,
      );
    } on FarmException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An unexpected error occurred. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            Navigator.pop(context);
                          },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Register your farm',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Add the basic information for your poultry farm.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 32),

                AppTextField(
                  controller: _farmNameController,
                  label: 'Farm name',
                  hint: 'Example: Ali Poultry Farm',
                  prefixIcon: Icons.agriculture_outlined,
                  validator: (value) {
                    final farmName = value?.trim() ?? '';

                    if (farmName.isEmpty) {
                      return 'Please enter the farm name';
                    }

                    if (farmName.length < 2) {
                      return 'Farm name is too short';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                AppTextField(
                  controller: _capacityController,
                  label: 'Maximum bird capacity',
                  hint: 'Example: 5000',
                  prefixIcon: Icons.groups_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final capacity = int.tryParse(value?.trim() ?? '');

                    if (capacity == null || capacity <= 0) {
                      return 'Enter a valid bird capacity';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                AppTextField(
                  controller: _addressController,
                  label: 'Farm address',
                  hint: 'Village, city or nearby landmark',
                  prefixIcon: Icons.location_on_outlined,
                  maxLines: 2,
                  validator: (value) {
                    if ((value?.trim() ?? '').isEmpty) {
                      return 'Please enter the farm address';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 14),

                OutlinedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () {
                          // GPS integration will be added later.
                        },
                  icon: const Icon(Icons.my_location),
                  label: const Text('Use current location'),
                ),

                const SizedBox(height: 32),

                const Text(
                  'Notification preferences',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),

                const SizedBox(height: 12),

                _PreferenceCard(
                  title: 'Sensor alerts',
                  subtitle: 'Temperature, humidity, ammonia and smoke warnings',
                  value: sensorAlertsEnabled,
                  icon: Icons.sensors_outlined,
                  enabled: !_isLoading,
                  onChanged: (value) {
                    setState(() {
                      sensorAlertsEnabled = value;
                    });
                  },
                ),

                const SizedBox(height: 12),

                _PreferenceCard(
                  title: 'Disease alerts',
                  subtitle:
                      'AI diagnosis results and disease-risk notifications',
                  value: diseaseAlertsEnabled,
                  icon: Icons.health_and_safety_outlined,
                  enabled: !_isLoading,
                  onChanged: (value) {
                    setState(() {
                      diseaseAlertsEnabled = value;
                    });
                  },
                ),

                const SizedBox(height: 12),

                _PreferenceCard(
                  title: 'Community alerts',
                  subtitle: 'Warnings about nearby poultry disease outbreaks',
                  value: communityAlertsEnabled,
                  icon: Icons.location_city_outlined,
                  enabled: !_isLoading,
                  onChanged: (value) {
                    setState(() {
                      communityAlertsEnabled = value;
                    });
                  },
                ),

                const SizedBox(height: 28),

                AppButton(
                  text: 'Save farm',
                  icon: Icons.check_circle_outline,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : saveFarm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PreferenceCard extends StatelessWidget {
  const _PreferenceCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.enabled,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final IconData icon;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile(
        value: value,
        onChanged: enabled ? onChanged : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        secondary: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
