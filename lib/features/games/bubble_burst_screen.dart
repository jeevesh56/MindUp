import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class BubbleBurstScreen extends StatefulWidget {
  const BubbleBurstScreen({super.key});

  @override
  State<BubbleBurstScreen> createState() => _BubbleBurstScreenState();
}

class _BubbleBurstScreenState extends State<BubbleBurstScreen>
    with TickerProviderStateMixin {
  final List<Bubble> _bubbles = [];
  final List<Confetti> _confetti = [];
  int _score = 0;
  bool _relaxMode = false;
  bool _soundEnabled = true;
  late AnimationController _bubbleController;
  late AnimationController _confettiController;
  final math.Random _random = math.Random();

  final List<Color> _bubbleColors = [
    const Color(0xFF9C27B0), // Electric Purple
    const Color(0xFF00E5FF), // Neon Cyan
    const Color(0xFF39FF14), // Neon Green
    const Color(0xFFFF1493), // Hot Pink
    const Color(0xFF1E90FF), // Electric Blue
    const Color(0xFFFFD300), // Vibrant Yellow
  ];

  @override
  void initState() {
    super.initState();
    _bubbleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _startBubbleGeneration();
    _startAnimationLoop();
  }

  void _startAnimationLoop() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 16)); // 60 FPS
      if (mounted) {
        _updateBubbles();
        _updateConfetti();
        return true;
      }
      return false;
    });
  }

  void _updateBubbles() {
    setState(() {
      _bubbles.removeWhere((bubble) {
        bubble.y -= bubble.speed;
        return bubble.y < -50;
      });
    });
  }

  void _updateConfetti() {
    setState(() {
      _confetti.removeWhere((confetti) {
        confetti.x += confetti.vx;
        confetti.y += confetti.vy;
        confetti.vy += 0.3; // gravity
        confetti.life -= 0.02;
        return confetti.life <= 0 || confetti.y > 700;
      });
    });
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _startBubbleGeneration() {
    _bubbleController.addListener(() {
      if (_bubbleController.isCompleted) {
        _bubbleController.reset();
      }
    });
    _bubbleController.repeat();
    
    // Generate bubbles with random intervals
    _generateRandomBubbles();
  }

  void _generateRandomBubbles() {
    Future.doWhile(() async {
      // Random delay between 300ms to 1500ms for more varied spawning
      final randomDelay = _random.nextInt(1200) + 300;
      await Future.delayed(Duration(milliseconds: randomDelay));
      
      if (mounted) {
        // Sometimes spawn multiple bubbles at once (burst effect)
        final spawnCount = _random.nextDouble() < 0.2 ? _random.nextInt(3) + 1 : 1;
        for (int i = 0; i < spawnCount; i++) {
          _addBubble();
        }
        return true;
      }
      return false;
    });
  }

  void _addBubble() {
    setState(() {
      // Get screen dimensions dynamically for web compatibility
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      final gameAreaWidth = screenWidth - 40; // Account for 20px margins on each side
      
      // Make bubble sizes responsive to screen size
      final baseSize = screenWidth > 600 ? 20.0 : 15.0; // Larger bubbles on bigger screens
      final sizeVariation = screenWidth > 600 ? 25.0 : 20.0;
      
      _bubbles.add(Bubble(
        x: _random.nextDouble() * gameAreaWidth + 20, // Dynamic width based on screen size
        y: screenHeight * 0.8 + _random.nextDouble() * 20, // Responsive starting height
        size: _random.nextDouble() * sizeVariation + baseSize, // Responsive size variation
        color: _bubbleColors[_random.nextInt(_bubbleColors.length)],
        speed: _random.nextDouble() * 2.0 + 0.3, // Wider speed range (0.3-2.3)
        id: DateTime.now().millisecondsSinceEpoch + _random.nextInt(1000), // More unique IDs
      ));
    });
  }

  void _popBubble(Bubble bubble) {
    setState(() {
      _bubbles.remove(bubble);
      if (!_relaxMode) {
        _score++;
      }
      _createConfetti(bubble.x, bubble.y, bubble.color);
    });
    _playSound('pop');
  }

  void _createConfetti(double x, double y, Color color) {
    for (int i = 0; i < 8; i++) {
      _confetti.add(Confetti(
        x: x,
        y: y,
        vx: (_random.nextDouble() - 0.5) * 8,
        vy: _random.nextDouble() * -5 - 2,
        color: _bubbleColors[_random.nextInt(_bubbleColors.length)],
        size: _random.nextDouble() * 6 + 3,
        life: 1.0,
      ));
    }
    _confettiController.forward().then((_) {
      _confettiController.reset();
    });
  }

  void _playSound(String type) {
    if (!_soundEnabled) return;
    switch (type) {
      case 'pop':
        HapticFeedback.lightImpact();
        break;
    }
  }

  void _resetGame() {
    setState(() {
      _bubbles.clear();
      _confetti.clear();
      _score = 0;
    });
    _playSound('pop');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D0D0D),
              Color(0xFF1A0F2E),
              Color(0xFF0D0D0D),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar - Neon Glow Design
              Container(
                margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withOpacity(0.6),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00E5FF), Color(0xFF1E90FF)],
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00E5FF).withOpacity(0.5),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.bubble_chart,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 15),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF00E5FF), Color(0xFF9C27B0), Color(0xFFFF1493)],
                          ).createShader(bounds),
                          child: const Text(
                            '✨ Bubble Burst',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _relaxMode = !_relaxMode;
                              if (_relaxMode) _score = 0;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _relaxMode ? const Color(0xFF9C27B0).withOpacity(0.2) : const Color(0xFF00E5FF).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: _relaxMode ? const Color(0xFF9C27B0) : const Color(0xFF00E5FF),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (_relaxMode ? const Color(0xFF9C27B0) : const Color(0xFF00E5FF)).withOpacity(0.4),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Text(
                              _relaxMode ? 'RELAX MODE' : 'SCORE MODE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _relaxMode ? const Color(0xFF9C27B0) : const Color(0xFF00E5FF),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!_relaxMode)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00E5FF), Color(0xFF1E90FF)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E5FF).withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$_score',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              // Game Area - Neon Glow Design
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFF00E5FF).withOpacity(0.4),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(27),
                    child: GestureDetector(
                      onTapDown: (details) {
                        final tapX = details.localPosition.dx;
                        final tapY = details.localPosition.dy;
                        
                        for (final bubble in _bubbles.reversed) {
                          final distance = math.sqrt(
                            math.pow(tapX - bubble.x, 2) + math.pow(tapY - bubble.y, 2),
                          );
                          if (distance <= bubble.size) {
                            _popBubble(bubble);
                            break;
                          }
                        }
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF0D0D0D),
                              Color(0xFF1A0F2E),
                              Color(0xFF0D0D0D),
                            ],
                          ),
                        ),
                        child: CustomPaint(
                          painter: BubbleBurstPainter(
                            bubbles: _bubbles,
                            confetti: _confetti,
                          ),
                          size: Size.infinite,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Control Buttons - Neon Glow Design
              Container(
                margin: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(
                      icon: Icons.refresh,
                      label: 'Reset Game',
                      color: const Color(0xFFFF1493), // Neon red
                      onTap: _resetGame,
                    ),
                    _buildControlButton(
                      icon: _soundEnabled ? Icons.volume_up : Icons.volume_off,
                      label: _soundEnabled ? 'Mute' : 'Unmute',
                      color: const Color(0xFFFFD300), // Neon yellow
                      onTap: () {
                        setState(() {
                          _soundEnabled = !_soundEnabled;
                        });
                      },
                    ),
                    _buildControlButton(
                      icon: Icons.exit_to_app,
                      label: 'Exit',
                      color: const Color(0xFF9C27B0), // Neon purple
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.6), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 0.8,
                shadows: [
                  Shadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Bubble {
  double x, y, size, speed;
  Color color;
  int id;

  Bubble({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.speed,
    required this.id,
  });
}

class Confetti {
  double x, y, vx, vy, size, life;
  Color color;

  Confetti({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.life,
  });
}

class BubbleBurstPainter extends CustomPainter {
  final List<Bubble> bubbles;
  final List<Confetti> confetti;

  BubbleBurstPainter({
    required this.bubbles,
    required this.confetti,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw bubbles
    for (final bubble in bubbles) {
      // Outer glow
      final outerGlowPaint = Paint()
        ..color = bubble.color.withOpacity(0.4)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

      canvas.drawCircle(
        Offset(bubble.x, bubble.y),
        bubble.size + 15,
        outerGlowPaint,
      );

      // Inner glow
      final innerGlowPaint = Paint()
        ..color = bubble.color.withOpacity(0.6)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(
        Offset(bubble.x, bubble.y),
        bubble.size + 8,
        innerGlowPaint,
      );

      // Main bubble
      final bubblePaint = Paint()
        ..color = bubble.color.withOpacity(0.8)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(bubble.x, bubble.y),
        bubble.size,
        bubblePaint,
      );

      // Highlight for glassy effect
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(bubble.x - bubble.size * 0.3, bubble.y - bubble.size * 0.3),
        bubble.size * 0.3,
        highlightPaint,
      );

      // Pulsating neon border
      final borderPaint = Paint()
        ..color = bubble.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(
        Offset(bubble.x, bubble.y),
        bubble.size,
        borderPaint,
      );
    }

    // Draw confetti
    for (final confetti in confetti) {
      final paint = Paint()
        ..color = confetti.color.withOpacity(confetti.life)
        ..style = PaintingStyle.fill;

      final glowPaint = Paint()
        ..color = confetti.color.withOpacity(confetti.life * 0.8)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      // Draw glow
      canvas.drawCircle(
        Offset(confetti.x, confetti.y),
        confetti.size + 5,
        glowPaint,
      );

      // Draw confetti piece
      canvas.drawCircle(
        Offset(confetti.x, confetti.y),
        confetti.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
