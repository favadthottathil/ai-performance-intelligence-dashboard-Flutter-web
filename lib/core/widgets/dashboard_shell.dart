import 'package:flutter/material.dart';

class DashboardShell extends StatelessWidget {
  final Widget child;

  const DashboardShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _Sidebar(),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: Colors.grey.shade100,
      child: Column(
        children: [
          const SizedBox(height: 24),
          const Text(
            'AI Dashboard',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          _NavItem(
            icon: Icons.dashboard,
            label: 'Dashboard',
            onTap: () {
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
          ),
          _NavItem(
            icon: Icons.apps,
            label: 'Apps',
            onTap: () {
              Navigator.pushReplacementNamed(context, '/apps');
            },
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
    );
  }
}
