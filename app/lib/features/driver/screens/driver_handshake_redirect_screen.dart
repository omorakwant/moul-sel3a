import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/driver_providers.dart';

/// Redirects /driver/handshake/:orderId to /driver/active-trip/:jobId.
/// Active trip is keyed by job id; this screen resolves the job from order id
/// and navigates to the correct active trip screen.
class DriverHandshakeRedirectScreen extends ConsumerStatefulWidget {
  final String orderId;

  const DriverHandshakeRedirectScreen({
    super.key,
    required this.orderId,
  });

  @override
  ConsumerState<DriverHandshakeRedirectScreen> createState() =>
      _DriverHandshakeRedirectScreenState();
}

class _DriverHandshakeRedirectScreenState
    extends ConsumerState<DriverHandshakeRedirectScreen> {
  bool _redirectScheduled = false;

  @override
  Widget build(BuildContext context) {
    final jobAsync = ref.watch(deliveryJobByOrderIdProvider(widget.orderId));

    return jobAsync.when(
      data: (job) {
        if (job == null) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: AppColors.alertRed,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Commande ou livraison introuvable',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => context.goNamed('driver-marketplace'),
                      child: const Text('Retour au marché'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        // Redirect to active trip by job id (not order id), once per screen
        if (!_redirectScheduled) {
          _redirectScheduled = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.goNamed(
                'driver-active-trip',
                pathParameters: {'jobId': job.id},
              );
            }
          });
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: AppColors.accentOrange),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accentOrange),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.alertRed,
                ),
                const SizedBox(height: 16),
                Text(
                  e.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.goNamed('driver-marketplace'),
                  child: const Text('Retour au marché'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
