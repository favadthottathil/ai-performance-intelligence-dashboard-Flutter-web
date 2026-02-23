import 'package:ai_performance_intelligence_platfrom/core/di/injection.dart';
import 'package:ai_performance_intelligence_platfrom/core/storage/token_storage.dart';
import 'package:ai_performance_intelligence_platfrom/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:ai_performance_intelligence_platfrom/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:ai_performance_intelligence_platfrom/features/dashboard/presentation/widgets/dashboard_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends StatelessWidget {
  final Widget child;
  const DashboardPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final String location = GoRouterState.of(context).uri.toString();

    // Determine selected bottom nav index
    int bottomNavIndex = 0;
    if (location.contains('/apps')) bottomNavIndex = 1;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.insights,
                color: Color(0xFF3B82F6),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'AI Monitor',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        // On mobile show hamburger for drawer; on desktop no leading
        leading: isMobile
            ? Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              )
            : null,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              context.read<DashboardBloc>().add(RefreshDashboard());
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Colors.white),
            onPressed: () async {
              await sl<TokenStorage>().clear();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),

      // Drawer shown only on mobile via hamburger
      drawer: isMobile ? const _MobileDrawer() : null,

      // Bottom nav bar only on mobile
      bottomNavigationBar: isMobile
          ? BottomNavigationBar(
              currentIndex: bottomNavIndex,
              backgroundColor: const Color(0xFF1E293B),
              selectedItemColor: const Color(0xFF3B82F6),
              unselectedItemColor: Colors.white54,
              onTap: (index) {
                if (index == 0) context.go('/dashboard/analytics');
                if (index == 1) context.go('/dashboard/apps');
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.analytics_outlined),
                  activeIcon: Icon(Icons.analytics),
                  label: 'Analytics',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.apps_outlined),
                  activeIcon: Icon(Icons.apps),
                  label: 'Applications',
                ),
              ],
            )
          : null,

      body: isMobile
          // Mobile: full-width content only
          ? child
          // Tablet/Desktop: persistent sidebar + content
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DashboardSidebar(),
                Flexible(child: child),
              ],
            ),
    );
  }
}

/// Drawer used on mobile — mirrors the sidebar nav items
class _MobileDrawer extends StatelessWidget {
  const _MobileDrawer();

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();

    return Drawer(
      backgroundColor: const Color(0xFF1E293B),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.insights,
                      color: Color(0xFF3B82F6),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'AI Monitor',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.white.withOpacity(0.1), height: 1),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'MAIN MENU',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _DrawerNavItem(
              label: 'Analytics',
              icon: Icons.analytics_outlined,
              selected: location.contains('/analytics'),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/dashboard/analytics');
              },
            ),
            const SizedBox(height: 4),
            _DrawerNavItem(
              label: 'Applications',
              icon: Icons.apps,
              selected: location.contains('/apps'),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/dashboard/apps');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerNavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerNavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        color: selected
            ? const Color(0xFF3B82F6).withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: selected
                      ? const Color(0xFF3B82F6)
                      : Colors.white.withOpacity(0.7),
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    color: selected
                        ? Colors.white
                        : Colors.white.withOpacity(0.7),
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
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
