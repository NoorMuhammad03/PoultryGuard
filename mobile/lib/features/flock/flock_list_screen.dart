import 'package:flutter/material.dart';

import '../../app/app_router.dart';
import '../../core/theme/app_colors.dart';
import 'models/flock.dart';
import 'services/flock_service.dart';

class FlockListScreen extends StatefulWidget {
  const FlockListScreen({super.key});

  @override
  State<FlockListScreen> createState() => _FlockListScreenState();
}

class _FlockListScreenState extends State<FlockListScreen> {
  late Future<List<Flock>> _flocksFuture;

  @override
  void initState() {
    super.initState();
    _loadFlocks();
  }

  void _loadFlocks() {
    _flocksFuture = FlockService.getFlocks();
  }

  Future<void> _refreshFlocks() async {
    setState(_loadFlocks);
    await _flocksFuture;
  }

  Future<void> _openAddFlock() async {
    final created = await Navigator.pushNamed(context, AppRouter.addFlock);

    if (created == true && mounted) {
      setState(_loadFlocks);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Flocks'),
        actions: [
          IconButton(
            onPressed: _openAddFlock,
            tooltip: 'Add flock',
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddFlock,
        icon: const Icon(Icons.add),
        label: const Text('Add flock'),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Flock>>(
          future: _flocksFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              final message = snapshot.error is FlockException
                  ? (snapshot.error! as FlockException).message
                  : 'Could not load flocks.';

              return _ErrorState(
                message: message,
                onRetry: () {
                  setState(_loadFlocks);
                },
              );
            }

            final flocks = snapshot.data ?? [];

            if (flocks.isEmpty) {
              return _EmptyState(onAddFlock: _openAddFlock);
            }

            return RefreshIndicator(
              onRefresh: _refreshFlocks,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                itemCount: flocks.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final flock = flocks[index];

                  return _FlockCard(
                    flock: flock,
                    onTap: () async {
                      final changed = await Navigator.pushNamed(
                        context,
                        AppRouter.flockDetails,
                        arguments: flock.id,
                      );

                      if (changed == true && mounted) {
                        setState(_loadFlocks);
                      }
                    },
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

class _FlockCard extends StatelessWidget {
  const _FlockCard({required this.flock, required this.onTap});

  final Flock flock;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = flock.status == 'active';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.groups_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        flock.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        flock.breed,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
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
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Initial birds',
                    value: flock.initialBirdCount.toString(),
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Current birds',
                    value: flock.currentBirdCount.toString(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatDate(flock.startDate),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddFlock});

  final VoidCallback onAddFlock;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.groups_outlined,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 18),
            const Text(
              'No flocks yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first flock to start tracking bird counts and flock status.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.45),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: onAddFlock,
              icon: const Icon(Icons.add),
              label: const Text('Add flock'),
            ),
          ],
        ),
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
