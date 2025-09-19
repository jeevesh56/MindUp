import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class MoodCheckScreen extends StatefulWidget {
  const MoodCheckScreen({super.key});

  @override
  State<MoodCheckScreen> createState() => _MoodCheckScreenState();
}

class _MoodCheckScreenState extends State<MoodCheckScreen>
    with TickerProviderStateMixin {
  String? _selectedResponse;
  late AnimationController _fadeController;
  late AnimationController _glowController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;
  final math.Random _random = math.Random();

  final List<Map<String, String>> _responses = [
    {
      'yes': 'It\'s okay to feel this way 🌱',
      'no': 'Keep shining ✨',
      'if': 'Your journey is unique 🌌',
    },
    {
      'yes': 'You are stronger than you know 💪',
      'no': 'Every storm passes eventually 🌈',
      'if': 'Trust the process 🌟',
    },
    {
      'yes': 'Your feelings are valid 💜',
      'no': 'You\'ve got this! 🚀',
      'if': 'Embrace the unknown 🌊',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _selectResponse(String choice) {
    setState(() {
      _selectedResponse = choice;
    });
    _fadeController.forward();
    _playSound('click');
  }

  void _resetGame() {
    setState(() {
      _selectedResponse = null;
    });
    _fadeController.reset();
    _playSound('reset');
  }

  void _playSound(String type) {
    switch (type) {
      case 'click':
        HapticFeedback.lightImpact();
        break;
      case 'reset':
        HapticFeedback.mediumImpact();
        break;
    }
  }

  String _getRandomResponse(String choice) {
    final responseSet = _responses[_random.nextInt(_responses.length)];
    return responseSet[choice] ?? 'You are amazing! 🌟';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF121212),
              Color(0xFF1A1A2E),
              Color(0xFF121212),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_selectedResponse == null) ...[
                    // Main Question
                    _buildQuestion(),
                    const SizedBox(height: 60),
                    // Response Buttons
                    _buildResponseButtons(),
                  ] else ...[
                    // Response Display
                    _buildResponseDisplay(),
                    const SizedBox(height: 40),
                    // Reset Button
                    _buildResetButton(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestion() {
    return Column(
      children: [
        // Glowing Question Text
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF7E57C2), Color(0xFFB39DDB)],
          ).createShader(bounds),
          child: const Text(
            'How do you feel right now?',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        // Subtitle
        Text(
          'Choose what resonates with you',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildResponseButtons() {
    return Column(
      children: [
        _buildGlowButton('Yes', const Color(0xFF7E57C2), () => _selectResponse('yes')),
        const SizedBox(height: 20),
        _buildGlowButton('No', const Color(0xFF00E5FF), () => _selectResponse('no')),
        const SizedBox(height: 20),
        _buildGlowButton('If', const Color(0xFF39FF14), () => _selectResponse('if')),
      ],
    );
  }

  Widget _buildGlowButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            width: 200,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.3),
                  color.withOpacity(0.1),
                ],
              ),
              border: Border.all(
                color: color.withOpacity(0.8),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5 * _glowAnimation.value),
                  blurRadius: 20 * _glowAnimation.value,
                  spreadRadius: 5 * _glowAnimation.value,
                ),
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: color.withOpacity(0.8),
                      blurRadius: 10,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResponseDisplay() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Response Text
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.1),
                ],
              ),
              border: Border.all(
                color: const Color(0xFF7E57C2).withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7E57C2).withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Text(
              _getRandomResponse(_selectedResponse!),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 30),
          // Glowing Abstract Shapes
          _buildGlowingShapes(),
        ],
      ),
    );
  }

  Widget _buildGlowingShapes() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return SizedBox(
          width: 200,
          height: 100,
          child: Stack(
            children: [
              // Purple Circle
              Positioned(
                left: 20,
                top: 20,
                child: Container(
                  width: 40 * _glowAnimation.value,
                  height: 40 * _glowAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF7E57C2).withOpacity(0.8),
                        const Color(0xFF7E57C2).withOpacity(0.2),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7E57C2).withOpacity(0.6),
                        blurRadius: 20 * _glowAnimation.value,
                        spreadRadius: 5 * _glowAnimation.value,
                      ),
                    ],
                  ),
                ),
              ),
              // Cyan Triangle
              Positioned(
                right: 30,
                top: 10,
                child: Transform.rotate(
                  angle: _glowAnimation.value * 2 * math.pi,
                  child: Container(
                    width: 35 * _glowAnimation.value,
                    height: 35 * _glowAnimation.value,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00E5FF).withOpacity(0.8),
                          const Color(0xFF00E5FF).withOpacity(0.2),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E5FF).withOpacity(0.6),
                          blurRadius: 15 * _glowAnimation.value,
                          spreadRadius: 3 * _glowAnimation.value,
                        ),
                      ],
                    ),
                    child: CustomPaint(
                      painter: TrianglePainter(),
                    ),
                  ),
                ),
              ),
              // Green Square
              Positioned(
                left: 80,
                bottom: 20,
                child: Transform.rotate(
                  angle: _glowAnimation.value * math.pi,
                  child: Container(
                    width: 30 * _glowAnimation.value,
                    height: 30 * _glowAnimation.value,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF39FF14).withOpacity(0.8),
                          const Color(0xFF39FF14).withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF39FF14).withOpacity(0.6),
                          blurRadius: 18 * _glowAnimation.value,
                          spreadRadius: 4 * _glowAnimation.value,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResetButton() {
    return GestureDetector(
      onTap: _resetGame,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(
            colors: [Color(0xFF7E57C2), Color(0xFFB39DDB)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7E57C2).withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Text(
          'Play Again',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

