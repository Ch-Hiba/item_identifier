import 'package:flutter/material.dart';
import 'dart:math' as math;

class AISplashScreen extends StatefulWidget {
  const AISplashScreen({Key? key}) : super(key: key);

  @override
  State<AISplashScreen> createState() => _AISplashScreenState();
}

class _AISplashScreenState extends State<AISplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _pulseController;
  late AnimationController _particleController;
  late AnimationController _progressController;

  late Animation<double> _backgroundAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    // Contrôleurs d'animation
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Animations
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    // Séquence d'animations optimisée
    _backgroundController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();
    _particleController.repeat();
    
    await Future.delayed(const Duration(milliseconds: 600));
    _textController.forward();
    _progressController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _backgroundController,
          _logoController,
          _textController,
          _pulseController,
          _particleController,
          _progressController,
        ]),
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(Colors.black, const Color(0xFF0D1B2A), _backgroundAnimation.value)!,
                  Color.lerp(Colors.black, const Color(0xFF1B263B), _backgroundAnimation.value)!,
                  Color.lerp(Colors.black, const Color(0xFF0F3460), _backgroundAnimation.value)!,
                  Color.lerp(Colors.black, const Color(0xFF16213E), _backgroundAnimation.value)!,
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Particules de fond
                ...List.generate(25, (index) => _buildParticle(index)),
                
                // Logo principal et contenu
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo IA avec effet de pulsation
                      Transform.scale(
                        scale: _logoScaleAnimation.value * _pulseAnimation.value,
                        child: Opacity(
                          opacity: _logoOpacityAnimation.value,
                          child: Container(
                            width: 140,
                            height: 140,
                            child: CustomPaint(
                              painter: AILogoPainter(
                                animationValue: _particleAnimation.value,
                                glowIntensity: _pulseAnimation.value,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 80),
                      
                      // Texte "Initializing AI..."
                      Opacity(
                        opacity: _textAnimation.value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - _textAnimation.value)),
                          child: Column(
                            children: [
                              Text(
                                'Initializing AI',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 3.0,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              
                              const SizedBox(height: 8),
                              
                              Text(
                                'Intelligence Artificielle',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 1.5,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              
                              const SizedBox(height: 30),
                              
                              // Barre de progression personnalisée
                              Container(
                                width: 250,
                                height: 3,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: Colors.white.withOpacity(0.1),
                                ),
                                child: Stack(
                                  children: [
                                    // Barre de progression principale
                                    Container(
                                      width: 250 * _progressAnimation.value,
                                      height: 3,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(2),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF00D9FF),
                                            Color(0xFF00FF88),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF00D9FF).withOpacity(0.5),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Effet de brillance qui se déplace
                                    Positioned(
                                      left: (250 * _progressAnimation.value) - 20,
                                      child: Container(
                                        width: 20,
                                        height: 3,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(2),
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              Colors.white.withOpacity(0.6),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 15),
                              
                              // Pourcentage de progression
                              Text(
                                '${(_progressAnimation.value * 100).toInt()}%',
                                style: TextStyle(
                                  color: const Color(0xFF00D9FF).withOpacity(0.8),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Logo de l'entreprise en bas
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: _textAnimation.value * 0.7,
                    child: Column(
                      children: [
                        Text(
                          'POWERED BY',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 10,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 2.0,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'AI VISION',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildParticle(int index) {
    final random = math.Random(index * 42);
    final x = random.nextDouble();
    final y = random.nextDouble();
    final size = random.nextDouble() * 4 + 1;
    final speed = random.nextDouble() * 0.4 + 0.2;
    final phase = random.nextDouble() * 2 * math.pi;
    
    return Positioned(
      left: MediaQuery.of(context).size.width * x,
      top: MediaQuery.of(context).size.height * y,
      child: Opacity(
        opacity: (0.2 + (math.sin(_particleAnimation.value * 2 * math.pi + phase) * 0.1)) * _backgroundAnimation.value,
        child: Transform.translate(
          offset: Offset(
            math.sin(_particleAnimation.value * 2 * math.pi * speed + phase) * 25,
            math.cos(_particleAnimation.value * 2 * math.pi * speed + phase) * 20,
          ),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF00D9FF).withOpacity(0.8),
                  const Color(0xFF00D9FF).withOpacity(0.2),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D9FF).withOpacity(0.3),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AILogoPainter extends CustomPainter {
  final double animationValue;
  final double glowIntensity;

  AILogoPainter({
    required this.animationValue,
    required this.glowIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3.5;

    // Pinceau pour les connexions
    final connectionPaint = Paint()
      ..color = const Color(0xFF00D9FF).withOpacity(0.7)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Pinceau pour les nœuds
    final nodePaint = Paint()
      ..color = const Color(0xFF00D9FF)
      ..style = PaintingStyle.fill;

    // Pinceau pour l'effet de glow
    final glowPaint = Paint()
      ..color = const Color(0xFF00D9FF).withOpacity(0.4)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    // Dessiner les nœuds du réseau neuronal
    final nodes = <Offset>[];
    for (int i = 0; i < 10; i++) {
      final angle = (i * 2 * math.pi / 10) + (animationValue * math.pi / 6);
      final nodeRadius = radius + (math.sin(animationValue * 3 * math.pi + i) * 8);
      final x = center.dx + math.cos(angle) * nodeRadius;
      final y = center.dy + math.sin(angle) * nodeRadius;
      nodes.add(Offset(x, y));
    }

    // Nœud central
    nodes.add(center);

    // Dessiner les connexions avec animation
    for (int i = 0; i < nodes.length - 1; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        if (i < 10 && j == 10) { // Connexions vers le centre
          final opacity = (math.sin(animationValue * 4 * math.pi + i) + 1) / 2;
          connectionPaint.color = const Color(0xFF00D9FF).withOpacity(opacity * 0.8);
          canvas.drawLine(nodes[i], nodes[j], connectionPaint);
        } else if (i < 10 && j < 10 && (j - i) <= 3 && (j - i) > 0) { // Connexions entre nœuds adjacents
          final opacity = (math.sin(animationValue * 2 * math.pi + i + j) + 1) / 2;
          connectionPaint.color = const Color(0xFF00D9FF).withOpacity(opacity * 0.5);
          canvas.drawLine(nodes[i], nodes[j], connectionPaint);
        }
      }
    }

    // Dessiner les nœuds avec effet de glow
    for (int i = 0; i < nodes.length; i++) {
      final nodeSize = (i == nodes.length - 1) ? 10.0 : 5.0;
      final pulseSize = nodeSize + (math.sin(animationValue * 3 * math.pi + i) * 2);
      
      // Effet de glow
      canvas.drawCircle(
        nodes[i],
        pulseSize * glowIntensity * 1.5,
        glowPaint,
      );
      
      // Nœud principal
      canvas.drawCircle(
        nodes[i],
        pulseSize,
        nodePaint,
      );
    }

    // Cercles externes rotatifs
    final outerPaint = Paint()
      ..color = const Color(0xFF00D9FF).withOpacity(0.4)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(animationValue * 2 * math.pi);
    
    // Arcs rotatifs multiples
    for (int ring = 0; ring < 2; ring++) {
      final ringRadius = radius + 20 + (ring * 15);
      for (int i = 0; i < 4; i++) {
        final startAngle = (i * math.pi / 2) + (ring * math.pi / 4);
        final sweepAngle = math.pi / 4;
        canvas.drawArc(
          Rect.fromCircle(center: Offset.zero, radius: ringRadius),
          startAngle,
          sweepAngle,
          false,
          outerPaint,
        );
      }
    }
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}