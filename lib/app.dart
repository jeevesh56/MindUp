import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/chatbot/chatbot_screen.dart';
import 'features/mood/mood_tracker_screen.dart';
import 'features/garden/mood_garden_screen.dart';
import 'features/games/games_hub_screen.dart';
import 'features/forum/forum_screen.dart';
import 'utils/theme_controller.dart';

class StressApp extends StatelessWidget {
  const StressApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
      useMaterial3: true,
      textTheme: GoogleFonts.interTextTheme(),
    );
    return MaterialApp(
      title: 'MindCare',
      debugShowCheckedModeBanner: false,
      theme: baseTheme,
      home: const LoginScreen(),
      routes: {'/dashboard': (context) => const _HomeShell()},
    );
  }
}

class _HomeShell extends StatefulWidget {
  const _HomeShell();

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int _selectedIndex = 0;

  late final List<Widget> _pages = <Widget>[
    DashboardScreen(),
    const ChatbotScreen(),
    const MoodTrackerScreen(),
    const MoodGardenScreen(),
    const GamesHubScreen(),
    const ForumScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          [
            'Dashboard',
            'Chatbot',
            'Mood',
            'Garden',
            'Games',
            'Forum',
          ][_selectedIndex],
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: AppThemeController().themeMode,
            builder: (context, mode, _) {
              return IconButton(
                onPressed: () {
                  AppThemeController().toggleTheme();
                },
                icon: Icon(
                  mode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                  color: Theme.of(context).colorScheme.primary,
                ),
                tooltip:
                    mode == ThemeMode.dark
                        ? 'Switch to Light Mode'
                        : 'Switch to Dark Mode',
              );
            },
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected:
            (value) => setState(() => _selectedIndex = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy),
            label: 'Chatbot',
          ),
          NavigationDestination(
            icon: Icon(Icons.mood_outlined),
            selectedIcon: Icon(Icons.mood),
            label: 'Mood',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_florist_outlined),
            selectedIcon: Icon(Icons.local_florist),
            label: 'Garden',
          ),
          NavigationDestination(
            icon: Icon(Icons.videogame_asset_outlined),
            selectedIcon: Icon(Icons.videogame_asset),
            label: 'Games',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: 'Forum',
          ),
        ],
      ),
    );
  }
}
