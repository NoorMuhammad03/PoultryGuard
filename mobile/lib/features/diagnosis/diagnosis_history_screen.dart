import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'models/diagnosis_history.dart';
import 'services/diagnosis_history_service.dart';

class DiagnosisHistoryScreen extends StatefulWidget {
  const DiagnosisHistoryScreen({super.key});

  @override
  State<DiagnosisHistoryScreen> createState() => _DiagnosisHistoryScreenState();
}

class _DiagnosisHistoryScreenState extends State<DiagnosisHistoryScreen> {
  late Future<List<DiagnosisHistory>> _historyFuture;
  bool _isClearing = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    _historyFuture = DiagnosisHistoryService.getHistory();
  }

  Future<void> _refreshHistory() async {
    setState(_loadHistory);
    await _historyFuture;
  }

  String _localizedLabel(AppLocalizations l10n, String label) {
    switch (label) {
      case 'Healthy':
        return l10n.diagnosisHealthy;

      case 'Coccidiosis':
        return l10n.diagnosisCoccidiosis;

      case 'Newcastle Disease':
        return l10n.diagnosisNewcastle;

      case 'Salmonellosis':
        return l10n.diagnosisSalmonellosis;

      default:
        return label;
    }
  }

  Future<void> _deleteDiagnosis(DiagnosisHistory diagnosis) async {
    final l10n = AppLocalizations.of(context);

    await DiagnosisHistoryService.deleteDiagnosis(diagnosis);

    if (!mounted) return;

    setState(_loadHistory);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.diagnosisHistoryRemoved)));
  }

  Future<void> _clearHistory() async {
    if (_isClearing) return;

    final l10n = AppLocalizations.of(context);

    final shouldClear = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.diagnosisHistoryClearTitle),
          content: Text(l10n.diagnosisHistoryClearMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(l10n.cancelButton),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(
                l10n.diagnosisHistoryClearAll,
                style: const TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldClear != true || !mounted) {
      return;
    }

    setState(() {
      _isClearing = true;
    });

    try {
      await DiagnosisHistoryService.clearHistory();

      if (!mounted) return;

      setState(_loadHistory);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.diagnosisHistoryCleared)));
    } finally {
      if (mounted) {
        setState(() {
          _isClearing = false;
        });
      }
    }
  }

  Widget _buildImage(DiagnosisHistory diagnosis) {
    if (kIsWeb) {
      return Image.network(
        diagnosis.imagePath,
        width: 76,
        height: 76,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return const _ImageFallback();
        },
      );
    }

    return Image.file(
      File(diagnosis.imagePath),
      width: 76,
      height: 76,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) {
        return const _ImageFallback();
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');

    final month = dateTime.month.toString().padLeft(2, '0');

    final hour = dateTime.hour.toString().padLeft(2, '0');

    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day/$month/${dateTime.year} $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.diagnosisHistoryTitle),
        actions: [
          IconButton(
            onPressed: _isClearing ? null : _clearHistory,
            tooltip: l10n.diagnosisHistoryClearTooltip,
            icon: _isClearing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<DiagnosisHistory>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _ErrorState(
                onRetry: () {
                  setState(_loadHistory);
                },
              );
            }

            final history = snapshot.data ?? [];

            if (history.isEmpty) {
              return const _EmptyState();
            }

            return RefreshIndicator(
              onRefresh: _refreshHistory,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                itemCount: history.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final diagnosis = history[index];

                  final isHealthy = diagnosis.label == 'Healthy';

                  return Dismissible(
                    key: ValueKey(diagnosis.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      padding: const EdgeInsetsDirectional.only(end: 22),
                      alignment: AlignmentDirectional.centerEnd,
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                      ),
                    ),
                    confirmDismiss: (_) async {
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            title: Text(l10n.diagnosisHistoryDeleteTitle),
                            content: Text(l10n.diagnosisHistoryDeleteMessage),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext, false);
                                },
                                child: Text(l10n.cancelButton),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext, true);
                                },
                                child: Text(
                                  l10n.deleteButton,
                                  style: const TextStyle(
                                    color: AppColors.danger,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      return result ?? false;
                    },
                    onDismissed: (_) {
                      _deleteDiagnosis(diagnosis);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _buildImage(diagnosis),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _localizedLabel(l10n, diagnosis.label),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isHealthy
                                        ? AppColors.success
                                        : AppColors.danger,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  diagnosis.confidencePercentage,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  _formatDateTime(diagnosis.createdAt),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Icon(
                            Icons.chevron_left,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      color: AppColors.primaryLight.withValues(alpha: 0.18),
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.primary,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.history_outlined,
              size: 64,
              color: AppColors.primary,
            ),

            const SizedBox(height: 18),

            Text(
              l10n.diagnosisHistoryEmptyTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              l10n.diagnosisHistoryEmptySubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: OutlinedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: Text(l10n.retryButton),
      ),
    );
  }
}
