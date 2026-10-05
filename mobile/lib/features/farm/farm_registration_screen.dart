import 'package:flutter/material.dart';

import '../../app/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../l10n/app_localizations.dart';
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

      final l10n = AppLocalizations.of(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.unexpectedError)));
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
    final l10n = AppLocalizations.of(context);

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
                  alignment: AlignmentDirectional.centerStart,
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

                Text(
                  l10n.farmRegistrationTitle,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  l10n.farmRegistrationSubtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 32),

                AppTextField(
                  controller: _farmNameController,
                  label: l10n.farmName,
                  hint: l10n.farmNameHint,
                  prefixIcon: Icons.agriculture_outlined,
                  validator: (value) {
                    final farmName = value?.trim() ?? '';

                    if (farmName.isEmpty) {
                      return l10n.farmNameRequired;
                    }

                    if (farmName.length < 2) {
                      return l10n.farmNameTooShort;
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                AppTextField(
                  controller: _capacityController,
                  label: l10n.birdCapacity,
                  hint: l10n.birdCapacityHint,
                  prefixIcon: Icons.groups_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final capacity = int.tryParse(value?.trim() ?? '');

                    if (capacity == null || capacity <= 0) {
                      return l10n.birdCapacityInvalid;
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                AppTextField(
                  controller: _addressController,
                  label: l10n.farmAddress,
                  hint: l10n.farmAddressHint,
                  prefixIcon: Icons.location_on_outlined,
                  maxLines: 2,
                  validator: (value) {
                    if ((value?.trim() ?? '').isEmpty) {
                      return l10n.farmAddressRequired;
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
                  label: Text(l10n.useCurrentLocation),
                ),

                const SizedBox(height: 32),

                Text(
                  l10n.notificationPreferences,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),

                const SizedBox(height: 12),

                _PreferenceCard(
                  title: l10n.sensorAlerts,
                  subtitle: l10n.sensorAlertsSubtitle,
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
                  title: l10n.diseaseAlerts,
                  subtitle: l10n.diseaseAlertsSubtitle,
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
                  title: l10n.communityAlerts,
                  subtitle: l10n.communityAlertsSubtitle,
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
                  text: l10n.saveFarm,
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
