import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'models/flock.dart';
import 'services/flock_service.dart';
import '../../app/app_router.dart';

class FlockDetailsScreen extends StatefulWidget {
  const FlockDetailsScreen({super.key, required this.flockId});

  final String flockId;

  @override
  State<FlockDetailsScreen> createState() => _FlockDetailsScreenState();
}

class _FlockDetailsScreenState extends State<FlockDetailsScreen> {
  late Future<Flock> _flockFuture;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadFlock();
  }

  void _loadFlock() {
    _flockFuture = FlockService.getFlock(widget.flockId);
  }

  Future<void> _refreshFlock() async {
    setState(_loadFlock);
    await _flockFuture;
  }

  Future<void> _deleteFlock(Flock flock) async {
    if (_isDeleting) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete flock'),
          content: Text(
            'Are you sure you want to delete "${flock.name}"? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      await FlockService.deleteFlock(flock.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flock deleted successfully.')),
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
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Flock details')),
      body: SafeArea(
        child: FutureBuilder<Flock>(
          future: _flockFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              final message = snapshot.error is FlockException
                  ? (snapshot.error! as FlockException).message
                  : 'Could not load flock details.';

              return _ErrorState(
                message: message,
                onRetry: () {
                  setState(_loadFlock);
                },
              );
            }

            final flock = snapshot.data!;

            return RefreshIndicator(
              onRefresh: _refreshFlock,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  _HeaderCard(flock: flock),

                  const SizedBox(height: 18),

                  _DetailsCard(flock: flock),

                  const SizedBox(height: 18),

                  _NotesCard(notes: flock.notes),

                  const SizedBox(height: 24),

                  OutlinedButton.icon(
                    onPressed: _isDeleting
                        ? null
                        : () async {
                            final changed = await Navigator.pushNamed(
                              context,
                              AppRouter.editFlock,
                              arguments: flock,
                            );

                            if (changed == true && mounted) {
                              setState(_loadFlock);
                            }
                          },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit flock'),
                  ),

                  const SizedBox(height: 12),

                  ElevatedButton.icon(
                    onPressed: _isDeleting
                        ? null
                        : () {
                            _deleteFlock(flock);
                          },
                    icon: _isDeleting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_outline),
                    label: Text(_isDeleting ? 'Deleting...' : 'Delete flock'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.flock});

  final Flock flock;

  @override
  Widget build(BuildContext context) {
    final isActive = flock.status == 'active';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.groups_outlined,
              size: 30,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  flock.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  flock.breed,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.success.withValues(alpha: 0.12)
                  : AppColors.border.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isActive ? 'Active' : 'Completed',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? AppColors.primaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.flock});

  final Flock flock;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Start date',
            value: _formatDate(flock.startDate),
          ),

          const Divider(height: 28),

          _DetailRow(
            icon: Icons.groups_outlined,
            label: 'Initial bird count',
            value: flock.initialBirdCount.toString(),
          ),

          const Divider(height: 28),

          _DetailRow(
            icon: Icons.calculate_outlined,
            label: 'Current bird count',
            value: flock.currentBirdCount.toString(),
          ),

          const Divider(height: 28),

          _DetailRow(
            icon: Icons.trending_down_outlined,
            label: 'Bird difference',
            value: (flock.initialBirdCount - flock.currentBirdCount).toString(),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),

        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.notes});

  final String? notes;

  @override
  Widget build(BuildContext context) {
    final hasNotes = notes != null && notes!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notes_outlined, color: AppColors.primary),
              SizedBox(width: 10),
              Text(
                'Notes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            hasNotes ? notes!.trim() : 'No notes were added for this flock.',
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppColors.danger),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
