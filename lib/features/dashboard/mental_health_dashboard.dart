import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Constants (replace with real values and move to secure storage for prod)
const String helplinePhone = '+1-800-123-4567';
const String huggingfaceApiUrl = 'https://api-inference.huggingface.co/models/your-model';
const String huggingfaceApiKey = 'REPLACE_WITH_KEY';
const String dialogflowEndpoint = 'https://your-dialogflow-endpoint.com/query';

class ExperimentalMentalHealthDashboard extends StatelessWidget {
  const ExperimentalMentalHealthDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => _MoodModel() )],
      child: const _DashboardShell(),
    );
  }
}

class _DashboardShell extends StatefulWidget {
  const _DashboardShell();
  @override
  State<_DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<_DashboardShell> with SingleTickerProviderStateMixin {
  late final AnimationController _bgController;
  late final AnimationController _orbsController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat(reverse: true);
    _orbsController = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _orbsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              final t = _bgController.value;
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-1 + t, -1),
                    end: Alignment(1 - t, 1),
                    colors: [Colors.indigo.shade200, Colors.teal.shade200, Colors.purple.shade100],
                  ),
                ),
              );
            },
          ),
          // Floating soft orbs
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: AnimatedBuilder(
                animation: _orbsController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _OrbsPainter(progress: _orbsController.value),
                  );
                },
              ),
            ),
          ),
          Positioned.fill(child: _SafeLottie(asset: 'assets/particles.json', opacity: 0.12)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Welcome back', style: TextStyle(color: Colors.white70)),
                          SizedBox(height: 6),
                          Text('Student Dashboard', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const CircleAvatar(radius: 26, backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white))
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 0.95,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: [
                        _FeatureCard(icon: Icons.book, title: 'Daily Journal', onTap: () => _pushFancy(context, const _JournalScreen())).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2),
                        _FeatureCard(icon: Icons.chat, title: 'AI Chatbot', onTap: () => _pushFancy(context, const _ChatbotScreen())).animate(delay: 80.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2),
                        _FeatureCard(icon: Icons.bar_chart, title: 'Mood Stats', onTap: () => _pushFancy(context, const _MoodStatsScreen())).animate(delay: 160.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2),
                        _FeatureCard(icon: Icons.nature, title: 'Mood Garden', onTap: () => _pushFancy(context, const _MoodGardenScreen())).animate(delay: 240.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2),
                        _FeatureCard(icon: Icons.videogame_asset, title: 'Mini Games', onTap: () => _pushFancy(context, const _MiniGamesHome())).animate(delay: 320.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2),
                        _FeatureCard(icon: Icons.forum, title: 'Peer Forum', onTap: () => _pushFancy(context, const _ForumScreen())).animate(delay: 400.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon; final String title; final VoidCallback onTap;
  const _FeatureCard({required this.icon, required this.title, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(2, 4))],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(backgroundColor: Colors.indigo.shade50, child: Icon(icon, color: Colors.indigo, size: 28)),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// State model
class _MoodModel extends ChangeNotifier {
  int todaysScore = 5;
  List<_MoodEntry> history = <_MoodEntry>[];

  _MoodModel() {
    _loadFromFirestore();
  }

  Future<void> _ensureAuth() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
    } catch (_) {}
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }
  }

  Future<void> _loadFromFirestore() async {
    try {
      await _ensureAuth();
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final snap = await FirebaseFirestore.instance
          .collection('users').doc(uid).collection('moods')
          .orderBy('timestamp', descending: true)
          .limit(30)
          .get();
      history = snap.docs.map((d) {
        final data = d.data();
        data['id'] = d.id;
        return _MoodEntry.fromMap(data);
      }).toList();
      if (history.isNotEmpty) todaysScore = history.first.score;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading moods: $e');
    }
  }

  Future<void> addMood(int score, String note) async {
    try {
      await _ensureAuth();
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc = await FirebaseFirestore.instance
          .collection('users').doc(uid).collection('moods')
          .add({'score': score, 'note': note, 'timestamp': FieldValue.serverTimestamp()});
      final entry = _MoodEntry(id: doc.id, score: score, note: note, timestamp: DateTime.now());
      history.insert(0, entry);
      todaysScore = score;
      notifyListeners();
    } catch (e) {
      debugPrint('addMood failed: $e');
    }
  }
}

class _MoodEntry {
  final String id; final int score; final String note; final DateTime timestamp;
  _MoodEntry({required this.id, required this.score, required this.note, required this.timestamp});
  factory _MoodEntry.fromMap(Map<String, dynamic> m) {
    final ts = m['timestamp'];
    return _MoodEntry(
      id: (m['id'] ?? '') as String,
      score: (m['score'] ?? 5) as int,
      note: (m['note'] ?? '') as String,
      timestamp: ts is Timestamp ? ts.toDate() : DateTime.now(),
    );
  }
}

class _JournalScreen extends StatefulWidget {
  const _JournalScreen();
  @override
  State<_JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<_JournalScreen> {
  final TextEditingController _noteController = TextEditingController();
  int _score = 5; bool _sending = false;
  bool _saved = false;

  @override
  void dispose() { _noteController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<_MoodModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Journal'), backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('How are you feeling today?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(11, (i) => GestureDetector(
                onTap: () => setState(() => _score = i),
                child: Column(children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 1.0, end: _score == i ? 1.2 : 1.0), duration: 200.ms,
                    builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                    child: Text(_emojiFor(i), style: const TextStyle(fontSize: 22)),
                  ),
                  if (_score == i) const Icon(Icons.check_circle, color: Colors.indigo, size: 16)
                ]),
              )),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _noteController, maxLines: 5,
              decoration: InputDecoration(hintText: 'Write anything you want to share (optional)...', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sending ? null : () async {
                  setState(() => _sending = true);
                  final note = _noteController.text.trim();
                  final risky = await _checkForRisk(note);
                  if (risky && mounted) { _showHelplinePopup(context); setState(() => _sending = false); return; }
                  await model.addMood(_score, note);
                  if (!mounted) return; setState(() { _sending = false; _saved = true; });
                  await Future.delayed(600.ms);
                  if (!mounted) return; Navigator.of(context).pop();
                },
                child: AnimatedSwitcher(
                  duration: 250.ms,
                  child: _sending
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : _saved
                          ? Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.check_circle, color: Colors.white), SizedBox(width: 8), Text('Saved!', style: TextStyle(fontSize: 16))])
                          : const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Save Entry', style: TextStyle(fontSize: 16))),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  String _emojiFor(int i) { const list = ['😞','😕','😐','🙂','😊','😄','😁','🤩','🥳','🤗','😇']; return list[i.clamp(0, list.length - 1)]; }

  Future<bool> _checkForRisk(String text) async {
    if (text.isEmpty) return false;
    final lowered = text.toLowerCase();
    const triggers = ['suicide','kill myself','self harm','end my life','cant go on','worthless','die'];
    for (final t in triggers) { if (lowered.contains(t)) return true; }
    try {
      final resp = await http.post(Uri.parse(huggingfaceApiUrl), headers: {'Authorization': 'Bearer $huggingfaceApiKey', 'Content-Type': 'application/json'}, body: jsonEncode({'inputs': text})).timeout(const Duration(seconds: 6));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data is List && data.isNotEmpty) {
          final first = data.first;
          final label = (first is Map && first['label'] is String) ? (first['label'] as String).toLowerCase() : '';
          if (label.contains('self') || label.contains('suicide')) return true;
        }
      }
    } catch (e) { debugPrint('Classifier failed: $e'); }
    return false;
  }

  void _showHelplinePopup(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Immediate Help'), content: Column(mainAxisSize: MainAxisSize.min, children: [const Text('If you are in immediate danger, please call the helpline below or your local emergency number.'), const SizedBox(height: 12), SelectableText(helplinePhone, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 12), ElevatedButton.icon(onPressed: () { Navigator.of(context).pop(); }, icon: const Icon(Icons.call), label: const Text('Call Helpline'))],)));
  }
}

class _ChatbotScreen extends StatefulWidget { const _ChatbotScreen(); @override State<_ChatbotScreen> createState() => _ChatbotScreenState(); }
class _ChatbotScreenState extends State<_ChatbotScreen> {
  final List<Map<String, String>> _messages = <Map<String, String>>[];
  final TextEditingController _input = TextEditingController(); bool _sending = false;
  bool _botTyping = false;
  @override void initState() { super.initState(); _messages.add({'from':'bot','text':'Hi — I am here to listen. What would you like to talk about?'}); }
  @override void dispose() { _input.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Chatbot'), backgroundColor: Colors.transparent, elevation: 0),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            reverse: true,
            itemCount: _messages.length + (_botTyping ? 1 : 0),
            itemBuilder: (_, i) {
              final isTypingRow = _botTyping && i == 0;
              if (isTypingRow) {
                return Align(alignment: Alignment.centerLeft, child: _TypingIndicator().animate().fadeIn(duration: 200.ms));
              }
              final msg = _messages[_messages.length - 1 - (i - (_botTyping ? 1 : 0))];
              final isUser = msg['from'] == 'user';
              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: isUser ? Colors.indigo.shade50 : Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Text(msg['text'] ?? ''),
                ).animate().fadeIn(duration: 250.ms).slideX(begin: isUser ? 0.1 : -0.1),
              );
            },
          ),
        ),
        SafeArea(
          child: Row(children: [
            Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: TextField(controller: _input, decoration: const InputDecoration(hintText: 'Type a message...'),))),
            IconButton(icon: const Icon(Icons.send), onPressed: _sending ? null : _send)
          ]),
        )
      ]),
    );
  }
  Future<void> _send() async {
    final text = _input.text.trim(); if (text.isEmpty) return; setState(() { _messages.add({'from':'user','text':text}); _sending = true; _botTyping = true; _input.clear(); });
    final lowered = text.toLowerCase(); const triggers = ['suicide','kill myself','hurt myself','end my life','dont want to live']; for (final t in triggers) { if (lowered.contains(t)) { _messages.add({'from':'bot','text':'I\'m sorry you\'re feeling this way. If you are in immediate danger, please call the helpline: $helplinePhone'}); setState(() { _sending = false; }); return; } }
    try {
      final resp = await http.post(Uri.parse(dialogflowEndpoint), headers: const {'Content-Type':'application/json'}, body: jsonEncode({'message': text})).timeout(const Duration(seconds: 6));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final reply = (data is Map && data['reply'] is String) ? data['reply'] as String : 'Sorry, I couldn\'t process that.';
        _messages.add({'from':'bot','text': reply});
      } else {
        _messages.add({'from':'bot','text':'Service unavailable. Please try later.'});
      }
    } catch (e) { _messages.add({'from':'bot','text':'Network error. Try again.'}); }
    if (mounted) setState(() { _sending = false; _botTyping = false; });
  }
}

class _MoodStatsScreen extends StatelessWidget {
  const _MoodStatsScreen();
  @override
  Widget build(BuildContext context) {
    final history = Provider.of<_MoodModel>(context).history;
    final spots = history.reversed.toList().asMap().entries.map((e)=> FlSpot(e.key.toDouble(), e.value.score.toDouble())).toList();
    final hasData = spots.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('Mood Statistics'), backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          const SizedBox(height: 12),
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: hasData
                    ? LineChart(LineChartData(minY: 0, maxY: 10, gridData: const FlGridData(show: true), titlesData: const FlTitlesData(show: false), lineBarsData: [LineChartBarData(spots: spots, isCurved: true, color: Colors.indigo, barWidth: 3, dotData: const FlDotData(show: false))]))
                        .animate().fadeIn(duration: 400.ms).slideY(begin: 0.1)
                    : _ChartSkeleton().animate().shimmer(delay: 100.ms, duration: 1200.ms),
              ),
            ),
          )
        ]),
      ),
    );
  }
}

class _MoodGardenScreen extends StatelessWidget {
  const _MoodGardenScreen();
  @override
  Widget build(BuildContext context) {
    final score = context.watch<_MoodModel>().todaysScore; final stage = (score / 10.0).clamp(0.0, 1.0);
    return Scaffold(
      appBar: AppBar(title: const Text('Mood Garden'), backgroundColor: Colors.transparent, elevation: 0),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('Your mood grows a plant 🌱', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          Stack(alignment: Alignment.center, children: [
            const _SafeLottie(asset: 'assets/soil.json', width: 220),
            Transform.scale(scale: 0.6 + stage * 1.4, child: const _SafeLottie(asset: 'assets/plant_bloom.json', width: 220))
          ]).animate().scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0), duration: 800.ms).shake(hz: 1, curve: Curves.easeInOut, duration: 3000.ms),
          const SizedBox(height: 16),
          Text('Mood score: $score/10', style: const TextStyle(fontSize: 16))
        ]),
      ),
    );
  }
}

class _MiniGamesHome extends StatelessWidget { const _MiniGamesHome(); @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text('Stress-Busting Mini Games')), body: ListView(padding: const EdgeInsets.all(16), children: [ListTile(leading: const Icon(Icons.bubble_chart), title: const Text('Bubble Pop (Flame)'), subtitle: const Text('Lightweight pop game'), onTap: () {}), ListTile(leading: const Icon(Icons.self_improvement), title: const Text('Breathing Circle'), subtitle: const Text('2-minute guided breathing'), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_)=> const _BreathingExercise()))), ListTile(leading: const Icon(Icons.memory), title: const Text('Memory Match'), subtitle: const Text('Simple card flip memory'), onTap: () {})])); } }

class _BreathingExercise extends StatefulWidget { const _BreathingExercise(); @override State<_BreathingExercise> createState() => _BreathingExerciseState(); }
class _BreathingExerciseState extends State<_BreathingExercise> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat(reverse: true); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Breathing Circle')),
      body: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            final scale = 0.6 + 0.4 * _ctrl.value;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [Colors.indigo.withOpacity(0.25), Colors.indigo.withOpacity(0.05)]),
                  ),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.indigo.withOpacity(0.25))),
                  ),
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 24),
                Text(_ctrl.value < 0.5 ? 'Breathe In' : 'Breathe Out', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)).animate().fadeIn(duration: 300.ms),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ForumScreen extends StatefulWidget { const _ForumScreen(); @override State<_ForumScreen> createState() => _ForumScreenState(); }
class _ForumScreenState extends State<_ForumScreen> {
  final TextEditingController _controller = TextEditingController();
  @override void dispose() { _controller.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Peer Forum (Anonymous)'), backgroundColor: Colors.transparent, elevation: 0), body: Column(children: [Expanded(child: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('forum_posts').orderBy('createdAt', descending: true).snapshots(), builder: (context, snap) { if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator()); if (snap.hasError) return const Center(child: Text('Failed to load posts')); final docs = snap.data?.docs ?? <QueryDocumentSnapshot>[]; if (docs.isEmpty) return const Center(child: Text('No posts yet')); return ListView.builder(itemCount: docs.length, itemBuilder: (_, i) { final d = docs[i].data() as Map<String, dynamic>; final shortId = (d['anonId'] ?? 'Anonymous').toString(); return ListTile(title: Text(d['text'] ?? ''), subtitle: Text(shortId), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.favorite_border), onPressed: () => _react(docs[i].id, 'hug')), IconButton(icon: const Icon(Icons.handshake), onPressed: () => _react(docs[i].id, 'highfive'))])); }); })), Padding(padding: const EdgeInsets.all(8.0), child: Row(children: [Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Share something (anonymous)'))), IconButton(icon: const Icon(Icons.send), onPressed: _send)]) )]));
  }
  Future<void> _send() async { final text = _controller.text.trim(); if (text.isEmpty) return; final anonId = 'Anonymous #${DateTime.now().millisecondsSinceEpoch % 10000}'; await FirebaseFirestore.instance.collection('forum_posts').add({'text': text, 'anonId': anonId, 'createdAt': FieldValue.serverTimestamp(), 'reactions': {'hug': 0, 'highfive': 0}}); _controller.clear(); }
  Future<void> _react(String docId, String type) async { final docRef = FirebaseFirestore.instance.collection('forum_posts').doc(docId); await FirebaseFirestore.instance.runTransaction((tx) async { final snap = await tx.get(docRef); final data = snap.data() as Map<String, dynamic>; final reactions = Map<String, dynamic>.from(data['reactions'] ?? {'hug':0,'highfive':0}); reactions[type] = (reactions[type] ?? 0) + 1; tx.update(docRef, {'reactions': reactions}); }); }
}

class _SafeLottie extends StatelessWidget {
  final String asset; final double? width; final double opacity;
  const _SafeLottie({required this.asset, this.width, this.opacity = 1.0});
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: FutureBuilder<bool>(
        future: _assetExists(context, asset),
        builder: (context, snapshot) {
          if (snapshot.data == true) {
            return Lottie.asset(asset, width: width, fit: BoxFit.cover);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Future<bool> _assetExists(BuildContext context, String key) async {
    try {
      final bundle = DefaultAssetBundle.of(context);
      final data = await bundle.load(key);
      return data.lengthInBytes > 0;
    } catch (_) { return false; }
  }
}

// Fancy page transition (fade + slight scale)
void _pushFancy(BuildContext context, Widget page) {
  Navigator.of(context).push(PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(opacity: curved, child: ScaleTransition(scale: Tween<double>(begin: 0.98, end: 1.0).animate(curved), child: child));
    },
  ));
}

// Simple painter for softly moving orbs
class _OrbsPainter extends CustomPainter {
  final double progress;
  _OrbsPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final paints = [
      Paint()..color = Colors.white.withOpacity(0.05),
      Paint()..color = Colors.white.withOpacity(0.04),
      Paint()..color = Colors.white.withOpacity(0.03),
    ];
    for (int i = 0; i < 12; i++) {
      final p = (progress + i * 0.08) % 1.0;
      final dx = (size.width * (i % 3) / 2.5) + (size.width * 0.2 * (i.isEven ? p : 1 - p));
      final dy = size.height * ((i * 0.11 + p) % 1.0);
      canvas.drawCircle(Offset(dx, dy), 30 + (i % 3) * 8.0, paints[i % paints.length]);
    }
  }
  @override
  bool shouldRepaint(covariant _OrbsPainter oldDelegate) => oldDelegate.progress != progress;
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _dot(delayMs: 0), const SizedBox(width: 4), _dot(delayMs: 150), const SizedBox(width: 4), _dot(delayMs: 300),
      ]),
    );
  }
  Widget _dot({required int delayMs}) {
    return Animate(
      delay: delayMs.ms,
      onPlay: (controller) => controller.repeat(reverse: true),
      effects: [
        ScaleEffect(begin: const Offset(0.7, 0.7), end: const Offset(1, 1), duration: 400.ms),
      ],
      child: Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black54)),
    );
  }
}

class _ChartSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Row(children: List.generate(5, (i) => Expanded(child: Container(height: 8, margin: EdgeInsets.only(right: i==4?0:6), decoration: BoxDecoration(color: Colors.grey.withOpacity(0.12), borderRadius: BorderRadius.circular(4))))))
    ]);
  }
}


