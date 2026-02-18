import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/auth/providers/auth_providers.dart';
import '../providers/supplier_verification_providers.dart';

/// Web breakpoint — above this we show the sidebar layout.
const kWebBreakpoint = 1024.0;

/// Whether the current viewport qualifies as web/tablet.
bool isWebLayout(BuildContext context) =>
    MediaQuery.sizeOf(context).width > kWebBreakpoint;

/// Shared sidebar shell for all Supplier web screens.
///
/// Design reference: UI&UX.pen — Screen F (dZFuG) & Screen G (Lgg5P).
/// Sidebar: 260px, #1C1917, brand + nav items + quick stats + user profile.
class SupplierWebShell extends ConsumerWidget {
  /// The currently active route name for highlighting the nav item.
  final String activeRoute;

  /// The main content to display next to the sidebar.
  final Widget child;

  const SupplierWebShell({
    super.key,
    required this.activeRoute,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On mobile, just show the child without sidebar
    if (!isWebLayout(context)) return child;

    final l10n = AppLocalizations.of(context);
    final pendingCount = ref.watch(pendingVerificationsProvider).whenOrNull(
          data: (list) => list.length,
        ) ?? 0;

    return Scaffold(
      body: Row(
        children: [
          // ── Sidebar ──
          _Sidebar(
            activeRoute: activeRoute,
            pendingVerifications: pendingCount,
            l10n: l10n,
          ),
          // ── Main Content ──
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final String activeRoute;
  final int pendingVerifications;
  final AppLocalizations l10n;

  const _Sidebar({
    required this.activeRoute,
    required this.pendingVerifications,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: AppColors.webSidebarBg,
      child: Column(
        children: [
          // ── Brand ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'م',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Moul Sel3a',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.webSidebarTextActive,
                        ),
                      ),
                      Text(
                        l10n.isDarija ? 'المولي' : 'Grossiste',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: AppColors.webSidebarText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            color: AppColors.webSidebarHover,
            height: 1,
            indent: 20,
            endIndent: 20,
          ),
          const SizedBox(height: 16),

          // ── Navigation Label ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'NAVIGATION',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: AppColors.webSidebarText.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Nav Items ──
          _NavItem(
            icon: Icons.dashboard_outlined,
            label: l10n.isDarija ? 'لوحة التحكم' : 'Dashboard',
            isActive: activeRoute == 'supplier-dashboard',
            onTap: () => context.goNamed('supplier-dashboard'),
          ),
          _NavItem(
            icon: Icons.inventory_2_outlined,
            label: l10n.isDarija ? 'المخزون' : 'Inventaire',
            isActive: activeRoute == 'supplier-inventory',
            onTap: () => context.goNamed('supplier-inventory'),
          ),
          _NavItem(
            icon: Icons.menu_book_outlined,
            label: l10n.isDarija ? 'الزبناء' : 'Clients (Carnet)',
            isActive: activeRoute == 'supplier-clients',
            onTap: () => context.goNamed('supplier-dashboard'),
          ),
          _NavItem(
            icon: Icons.verified_user_outlined,
            label: l10n.isDarija ? 'التحقق' : 'Vérifications',
            isActive: activeRoute == 'supplier-verification',
            badge: pendingVerifications > 0 ? pendingVerifications : null,
            onTap: () => context.goNamed('supplier-verification'),
          ),
          _NavItem(
            icon: Icons.local_shipping_outlined,
            label: l10n.isDarija ? 'التوصيل' : 'Logistique',
            isActive: activeRoute == 'supplier-deliveries',
            onTap: () => context.goNamed('supplier-deliveries'),
          ),

          const Spacer(),

          // ── User Profile ──
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.webSidebarHover,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.webSidebarBg,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(
                    child: Text(
                      'MK',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.webSidebarTextActive,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mohamed Karim',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.webSidebarTextActive,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        l10n.isDarija ? 'درب عمر' : 'Grossiste Derb Omar',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: AppColors.webSidebarText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => context.goNamed('supplier-profile'),
                  child: const Icon(
                    Icons.settings_outlined,
                    size: 18,
                    color: AppColors.webSidebarText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final int? badge;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? AppColors.webSidebarHover : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive
                      ? AppColors.accentOrange
                      : AppColors.webSidebarText,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive
                          ? AppColors.webSidebarTextActive
                          : AppColors.webSidebarText,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$badge',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
