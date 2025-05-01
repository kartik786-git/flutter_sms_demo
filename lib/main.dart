import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Used to detect if running on Web
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dashboard_screen.dart';
import 'student_feature.dart';
import 'class_feature.dart';
import 'student_service.dart';
import 'class_service.dart';
import 'platform_utils.dart';

void main() {
    runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StudentService()),
        ChangeNotifierProvider(create: (_) => ClassService()),
      ],
      child: const MyApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainScaffold(selectedIndex: 0),
    ),
    GoRoute(
      path: '/students',
      builder: (context, state) => const MainScaffold(selectedIndex: 1),
    ),
    GoRoute(
      path: '/classes',
      builder: (context, state) => const MainScaffold(selectedIndex: 2),
    ),
  ],
);


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
       routerConfig: _router,
    );
  }
}


class MainScaffold extends StatefulWidget {
  final int selectedIndex;
  const MainScaffold({super.key, required this.selectedIndex});
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  

  void _onNavTap(BuildContext context, int index) {
    final routes = ['/', '/students', '/classes'];
    final currentLocation = GoRouter.of(context).routeInformationProvider.value.location;
    if (currentLocation != routes[index]) {
      context.go(routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = isMobilePlatform();
    final isWeb = kIsWeb;
    final isDesktop = isDesktopPlatform();
    Widget content;
    if (widget.selectedIndex == 0) {
      content = const DashboardScreen();
    } else if (widget.selectedIndex == 1) {
      content = const StudentFeature();
    } else {
      content = const ClassFeature();
    }
    Widget navBar;
    if (isWeb) {
      navBar = Container(
        color: Colors.deepPurple.shade100,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Row(
          children: [
            _WebNavButton(label: 'Dashboard', icon: Icons.dashboard, selected: widget.selectedIndex == 0, onTap: () => _onNavTap(context, 0)),
            const SizedBox(width: 16),
            _WebNavButton(label: 'Students', icon: Icons.people, selected: widget.selectedIndex == 1, onTap: () => _onNavTap(context, 1)),
            const SizedBox(width: 16),
            _WebNavButton(label: 'Classes', icon: Icons.class_, selected: widget.selectedIndex == 2, onTap: () => _onNavTap(context, 2)),
          ],
        ),
      );
    } else if (isDesktop) {
      navBar = NavigationRail(
        selectedIndex: widget.selectedIndex,
        onDestinationSelected: (i) => _onNavTap(context, i),
        labelType: NavigationRailLabelType.all,
        destinations: const [
          NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Dashboard')),
          NavigationRailDestination(icon: Icon(Icons.people), label: Text('Students')),
          NavigationRailDestination(icon: Icon(Icons.class_), label: Text('Classes')),
        ],
        selectedIconTheme: const IconThemeData(color: Colors.deepPurple),
        selectedLabelTextStyle: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
      );
    } else {
      navBar = BottomNavigationBar(
        currentIndex: widget.selectedIndex,
        onTap: (i) => _onNavTap(context, i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Students'),
          BottomNavigationBarItem(icon: Icon(Icons.class_), label: 'Classes'),
        ],
        selectedItemColor: Colors.deepPurple,
      );
    }
    return Scaffold(
      appBar: AppBar(
        
        backgroundColor: Colors.deepPurple,
        title: const Text('Flutter Demo Home Page', style: TextStyle(color: Colors.white)),
      ),
      body: isDesktop
          ? Row(
              children: [
                navBar,
                Expanded(child: content),
              ],
            )
          : Column(
              children: [
                if (isWeb) navBar,
                Expanded(child: content),
              ],
            ),
      bottomNavigationBar: isMobile ? navBar : null,
    );
  }
}


class _WebNavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _WebNavButton({required this.label, required this.icon, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: Icon(icon, color: selected ? Colors.deepPurple : Colors.black54),
      label: Text(label, style: TextStyle(color: selected ? Colors.deepPurple : Colors.black54)),
      onPressed: onTap,
    );
  }
}

