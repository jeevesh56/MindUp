import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GlowDoodleScreen extends StatefulWidget {
  const GlowDoodleScreen({super.key});

  @override
  State<GlowDoodleScreen> createState() => _GlowDoodleScreenState();
}

class _GlowDoodleScreenState extends State<GlowDoodleScreen>
    with TickerProviderStateMixin {
  final List<DrawingPath> _paths = [];
  Color _currentColor = const Color(0xFF9C27B0); // Purple
  bool _soundEnabled = true;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<Color> _neonColors = [
    const Color(0xFF9C27B0), // Purple
    const Color(0xFF00E5FF), // Cyan
    const Color(0xFF00FF7F), // Neon Green
    const Color(0xFF3F51B5), // Electric Blue
    const Color(0xFFFF4081), // Pink
    const Color(0xFFFF5722), // Orange
    const Color(0xFFE91E63), // Magenta
    const Color(0xFF00BCD4), // Teal
    const Color(0xFF4CAF50), // Green
    const Color(0xFFFFEB3B), // Yellow
    const Color(0xFF795548), // Brown
    const Color(0xFF607D8B), // Blue Grey
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _playSound(String type) {
    if (!_soundEnabled) return;
    switch (type) {
      case 'stroke':
        HapticFeedback.lightImpact();
        break;
      case 'clear':
        HapticFeedback.mediumImpact();
        break;
      case 'save':
        HapticFeedback.selectionClick();
        break;
    }
  }

  void _addPath(Offset point) {
    setState(() {
      _paths.add(DrawingPath(
        points: [point],
        color: _currentColor,
        id: DateTime.now().millisecondsSinceEpoch,
      ));
    });
    _playSound('stroke');
  }

  void _updatePath(Offset point) {
    if (_paths.isNotEmpty) {
      final lastPath = _paths.last;
      // Only add point if it's far enough from the last point to reduce lag
      if (lastPath.points.isEmpty || 
          (point - lastPath.points.last).distance > 2.0) {
        setState(() {
          lastPath.points.add(point);
        });
      }
    }
  }

  void _undo() {
    if (_paths.isNotEmpty) {
      setState(() {
        _paths.removeLast();
      });
      _playSound('stroke');
    }
  }

  void _clearCanvas() {
    setState(() {
      _paths.clear();
    });
    _playSound('clear');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D1B69),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2D1B69),
              Color(0xFF1A0B3D),
              Color(0xFF0F0522),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '🌌 Glow Doodle',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: _currentColor.withOpacity(0.8),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _soundEnabled = !_soundEnabled;
                        });
                      },
                      icon: Icon(
                        _soundEnabled ? Icons.volume_up : Icons.volume_off,
                        color: _soundEnabled ? _currentColor : Colors.grey,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              // Drawing Canvas
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _currentColor.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _currentColor.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: GestureDetector(
                      onPanStart: (details) => _addPath(details.localPosition),
                      onPanUpdate: (details) => _updatePath(details.localPosition),
                      child: RepaintBoundary(
                        child: CustomPaint(
                          painter: GlowDoodlePainter(
                            paths: _paths,
                            pulseAnimation: _pulseAnimation,
                          ),
                          size: Size.infinite,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Color Palette
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: _neonColors.map((color) {
                    final isSelected = color == _currentColor;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentColor = color;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withOpacity(0.2),
                          border: Border.all(
                            color: isSelected ? color : color.withOpacity(0.5),
                            width: isSelected ? 3 : 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.6),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.8),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // Control Buttons
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(
                      icon: Icons.undo,
                      label: 'Undo',
                      color: Colors.red,
                      onTap: _undo,
                    ),
                    _buildControlButton(
                      icon: Icons.clear,
                      label: 'Clear',
                      color: Colors.white,
                      onTap: _clearCanvas,
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: color.withOpacity(0.6), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawingPath {
  List<Offset> points;
  Color color;
  int id;

  DrawingPath({
    required this.points,
    required this.color,
    required this.id,
  });
}

class GlowDoodlePainter extends CustomPainter {
  final List<DrawingPath> paths;
  final Animation<double> pulseAnimation;

  GlowDoodlePainter({
    required this.paths,
    required this.pulseAnimation,
  }) : super(repaint: pulseAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    for (final path in paths) {
      if (path.points.length < 2) continue;

      // Optimize: draw path as connected lines instead of individual points
      final pathData = Path();
      pathData.moveTo(path.points.first.dx, path.points.first.dy);
      
      for (int i = 1; i < path.points.length; i++) {
        pathData.lineTo(path.points[i].dx, path.points[i].dy);
      }

      final glowPaint = Paint()
        ..color = path.color.withOpacity(0.4)
        ..strokeWidth = 8.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      final mainPaint = Paint()
        ..color = path.color
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      // Draw glow effect
      canvas.drawPath(pathData, glowPaint);
      
      // Draw main stroke
      canvas.drawPath(pathData, mainPaint);

      // Add subtle pulsing effect only for the last path
      if (path == paths.last) {
        final pulsePaint = Paint()
          ..color = path.color.withOpacity(0.15 * pulseAnimation.value)
          ..strokeWidth = 15.0 * pulseAnimation.value
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

        canvas.drawPath(pathData, pulsePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
