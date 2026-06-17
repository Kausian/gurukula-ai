import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Hosts the 5 primary tabs inside a persistent bottom navigation bar.
///
/// Uses [StatefulNavigationShell] so each tab keeps its own navigation state
/// when the user switches between them. A hairline top border separates the
/// nav bar from the content for a cleaner, less default-Material feel.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const List<NavigationDestination> _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.upload_file_outlined),
      selectedIcon: Icon(Icons.upload_file_rounded),
      label: 'Upload',
    ),
    NavigationDestination(
      icon: Icon(Icons.lightbulb_outline_rounded),
      selectedIcon: Icon(Icons.lightbulb_rounded),
      label: 'Idea Lab',
    ),
    NavigationDestination(
      icon: Icon(Icons.folder_outlined),
      selectedIcon: Icon(Icons.folder_rounded),
      label: 'Library',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Profile',
    ),
  ];

  void _onDestinationSelected(int index) {
    // Tapping the active tab again returns it to its initial route.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: theme.colorScheme.outline),
          ),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onDestinationSelected,
          destinations: _destinations,
        ),
      ),
    );
  }
}
