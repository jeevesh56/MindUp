import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/chatbot/chatbot_screen.dart';
import 'features/mood/mood_tracker_screen.dart';
import 'features/garden/mood_garden_screen.dart';
import 'features/games/games_hub_screen.dart';
import 'features/forum/forum_screen.dart';
import 'features/assessments/assessments_screen.dart';
import 'features/sos/sos_help_screen.dart';
import 'features/resources/resources_screen.dart';
import 'features/settings/settings_screen.dart';
import 'utils/theme_controller.dart';

class StressApp extends StatefulWidget {
	const StressApp({super.key});

	@override
	State<StressApp> createState() => _StressAppState();
}

class _StressAppState extends State<StressApp> {
	final AppThemeController _theme = AppThemeController();

	@override
	void initState() {
		super.initState();
		_theme.load();
	}

	@override
	Widget build(BuildContext context) {
		final baseTheme = ThemeData(
			colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
			useMaterial3: true,
			textTheme: GoogleFonts.interTextTheme(),
			navigationBarTheme: const NavigationBarThemeData(
				height: 68,
				labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
				indicatorShape: StadiumBorder(),
			),
		);
		final darkTheme = ThemeData(
			colorScheme: ColorScheme.fromSeed(brightness: Brightness.dark, seedColor: const Color(0xFF6750A4)),
			useMaterial3: true,
			textTheme: GoogleFonts.interTextTheme(ThemeData(brightness: Brightness.dark).textTheme),
			navigationBarTheme: const NavigationBarThemeData(
				height: 68,
				labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
				indicatorShape: StadiumBorder(),
			),
		);
		return ValueListenableBuilder<ThemeMode>(
			valueListenable: _theme.themeMode,
			builder: (context, mode, _) {
				return MaterialApp(
					title: 'MindCare',
					debugShowCheckedModeBanner: false,
					theme: baseTheme,
					darkTheme: darkTheme,
					themeMode: mode,
					home: const _HomeShell(),
					routes: {
						'/assessments': (_) => const AssessmentsScreen(),
						'/sos': (_) => const SosHelpScreen(),
						'/resources': (_) => const ResourcesScreen(),
						'/settings': (_) => SettingsScreen(controller: _theme),
					},
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
					['Dashboard','Chatbot','Mood','Forum'][_selectedIndex],
					style: Theme.of(context).textTheme.titleLarge,
				),
			),
			drawer: Drawer(
				child: SafeArea(
					child: ListView(
						padding: EdgeInsets.zero,
						children: [
							DrawerHeader(
								margin: const EdgeInsets.only(bottom: 8),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text('MindCare', style: Theme.of(context).textTheme.headlineSmall),
										const SizedBox(height: 4),
										Text('Wellness tools and support for students', style: Theme.of(context).textTheme.bodySmall),
									],
								),
							),
							ListTile(
								leading: const Icon(Icons.assignment_turned_in_outlined),
								title: const Text('Assessments'),
								onTap: () {
									Navigator.of(context).pop();
									Navigator.of(context).pushNamed('/assessments');
								},
							),
							ListTile(
								leading: const Icon(Icons.local_florist_outlined),
								title: const Text('Garden'),
								onTap: () {
									Navigator.of(context).pop();
									Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MoodGardenScreen()));
								},
							),
							ListTile(
								leading: const Icon(Icons.menu_book_outlined),
								title: const Text('Resources'),
								onTap: () {
									Navigator.of(context).pop();
									Navigator.of(context).pushNamed('/resources');
								},
							),
							ListTile(
								leading: const Icon(Icons.videogame_asset_outlined),
								title: const Text('Games'),
								onTap: () {
									Navigator.of(context).pop();
									Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GamesHubScreen()));
								},
							),
							ListTile(
								leading: const Icon(Icons.sos_outlined),
								title: const Text('SOS Help'),
								onTap: () {
									Navigator.of(context).pop();
									Navigator.of(context).pushNamed('/sos');
								},
							),
							const Divider(),
							ListTile(
								leading: const Icon(Icons.settings_outlined),
								title: const Text('Settings'),
								onTap: () {
									Navigator.of(context).pop();
									Navigator.of(context).pushNamed('/settings');
								},
							),
						],
					),
				),
			),
			body: IndexedStack(
				index: _selectedIndex,
				children: _pages,
			),
			bottomNavigationBar: NavigationBar(
				selectedIndex: _selectedIndex,
				onDestinationSelected: (value) => setState(() => _selectedIndex = value),
				destinations: const [
					NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
					NavigationDestination(icon: Icon(Icons.smart_toy_outlined), selectedIcon: Icon(Icons.smart_toy), label: 'Chatbot'),
					NavigationDestination(icon: Icon(Icons.mood_outlined), selectedIcon: Icon(Icons.mood), label: 'Mood'),
					NavigationDestination(icon: Icon(Icons.forum_outlined), selectedIcon: Icon(Icons.forum), label: 'Forum'),
				],
			),
		);
	}
}
