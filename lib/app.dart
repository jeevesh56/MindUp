import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/chatbot/chatbot_screen.dart';
import 'features/mood/mood_tracker_screen.dart';
import 'features/assessments/assessments_screen.dart';
import 'features/resources/resources_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/sos/sos_help_screen.dart';
import 'features/forum/forum_screen.dart';
import 'features/games/games_hub_screen.dart';
import 'utils/theme_controller.dart';

class StressApp extends StatelessWidget {
  const StressApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
      useMaterial3: true,
      textTheme: GoogleFonts.interTextTheme(),
      brightness: Brightness.light,
    );
    final darkTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6750A4),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      brightness: Brightness.dark,
    );
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeController().themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'MindCare',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: mode,
          home: const LoginScreen(),
          routes: {'/dashboard': (context) => const _HomeShell()},
        );
      },
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
    const ForumScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ['Home', 'Chatbot', 'Mood', 'Forum'][_selectedIndex],
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
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              DrawerHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MindCare',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Quick actions',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.sos_outlined,
                  color: Colors.redAccent,
                ),
                title: const Text('SOS'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SosHelpScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.assignment_outlined),
                title: const Text('Assessments'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AssessmentsScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: const Text('Resources'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ResourcesScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.videogame_asset_outlined),
                title: const Text('Games'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const GamesHubScreen()),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) =>
                              SettingsScreen(controller: AppThemeController()),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
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
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: 'Forum',
          ),
        ],
      ),
    );
  }
}
