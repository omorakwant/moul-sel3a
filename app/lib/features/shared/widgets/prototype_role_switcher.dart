import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../features/auth/providers/auth_providers.dart';

/// On web only: shows [← Site Web] and [Retailer | Supplier | Driver] chips to switch prototype role.
/// Tapping updates [prototypeRoleProvider] and navigates to the corresponding dashboard.
class PrototypeRoleSwitcher extends ConsumerWidget {
  const PrototypeRoleSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kIsWeb) return const SizedBox.shrink();

    final currentRole = ref.watch(currentRoleProvider) ?? 'retailer';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Chip(
          label: '← Site Web',
          isSelected: false,
          isAction: true,
          onTap: () {
            launchUrl(Uri.parse('/'), webOnlyWindowName: '_self');
          },
        ),
        const SizedBox(width: 8),
        _Chip(
          label: 'Retailer',
          isSelected: currentRole == 'retailer',
          onTap: () {
            ref.read(prototypeRoleProvider.notifier).state = 'retailer';
            context.go('/retailer/dashboard');
          },
        ),
        const SizedBox(width: 6),
        _Chip(
          label: 'Supplier',
          isSelected: currentRole == 'supplier',
          onTap: () {
            ref.read(prototypeRoleProvider.notifier).state = 'supplier';
            context.go('/supplier/dashboard');
          },
        ),
        const SizedBox(width: 6),
        _Chip(
          label: 'Driver',
          isSelected: currentRole == 'driver',
          onTap: () {
            ref.read(prototypeRoleProvider.notifier).state = 'driver';
            context.go('/driver/marketplace');
          },
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isAction;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.isSelected,
    this.isAction = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    if (isSelected) {
      bgColor = AppColors.accentOrange;
      textColor = Colors.white;
    } else if (isAction) {
      bgColor = Colors.black.withValues(alpha: 0.35);
      textColor = AppColors.accentOrange;
    } else {
      bgColor = AppColors.bgSurface;
      textColor = AppColors.textSecondary;
    }

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: isAction
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.accentOrange.withValues(alpha: 0.5),
                    width: 1,
                  ),
                )
              : null,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: isSelected || isAction ? FontWeight.w600 : FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
