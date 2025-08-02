import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:item_identifier/core/app_initializer.dart';

class AIPaywallScreen extends StatefulWidget {
  const AIPaywallScreen({Key? key}) : super(key: key);

  @override
  State<AIPaywallScreen> createState() => _AIPaywallScreenState();
}

class _AIPaywallScreenState extends State<AIPaywallScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _contentController;
  late AnimationController _pulseController;
  late AnimationController _particleController;
  late AnimationController _featuresController;

  late Animation<double> _backgroundAnimation;
  late Animation<double> _titleAnimation;
  late Animation<double> _subtitleAnimation;
  late Animation<double> _featuresAnimation;
  late Animation<double> _buttonAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _featuresController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );

    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _subtitleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );

    _featuresAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _featuresController,
        curve: Curves.elasticOut,
      ),
    );

    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.7, 1.0, curve: Curves.elasticOut),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    _backgroundController.forward();
    _particleController.repeat();
    _pulseController.repeat(reverse: true);
    
    await Future.delayed(const Duration(milliseconds: 300));
    _contentController.forward();
    
    await Future.delayed(const Duration(milliseconds: 800));
    _featuresController.forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _contentController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    _featuresController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _backgroundController,
          _contentController,
          _pulseController,
          _particleController,
          _featuresController,
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
                ...List.generate(15, (index) => _buildParticle(index)),
                
                // Contenu principal
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        
                        // Titre de l'app
                        Opacity(
                          opacity: _titleAnimation.value,
                          child: Transform.translate(
                            offset: Offset(0, 30 * (1 - _titleAnimation.value)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  child: CustomPaint(
                                    painter: MiniAILogoPainter(
                                      animationValue: _particleAnimation.value,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'AI Identifier',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 80),
                        
                        // Message principal
                        Opacity(
                          opacity: _subtitleAnimation.value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - _subtitleAnimation.value)),
                            child: Column(
                              children: [
                                Text(
                                  'Débloquez toute la',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 28,
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                ShaderMask(
                                  shaderCallback: (bounds) => const LinearGradient(
                                    colors: [Color(0xFF06B6D4), Color(0xFF0E7490)],
                                  ).createShader(bounds),
                                  child: Text(
                                    'puissance de l\'IA',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 60),
                        
                        // Liste des fonctionnalités
                        Expanded(
                          child: Transform.scale(
                            scale: _featuresAnimation.value,
                            child: Opacity(
                              opacity: _featuresAnimation.value,
                              child: Column(
                                children: [
                                  _buildFeature(
                                    icon: Icons.all_inclusive,
                                    title: 'Résultats illimités',
                                    subtitle: 'Analysez autant d\'images que vous voulez',
                                    delay: 0,
                                  ),
                                  _buildFeature(
                                    icon: Icons.history,
                                    title: 'Accès à l\'historique',
                                    subtitle: 'Retrouvez toutes vos recherches passées',
                                    delay: 0.1,
                                  ),
                                  _buildFeature(
                                    icon: Icons.psychology,
                                    title: 'Analyse avancée',
                                    subtitle: 'OCR, traduction et détection précise',
                                    delay: 0.2,
                                  ),
                                  _buildFeature(
                                    icon: Icons.flash_on,
                                    title: 'Reconnaissance instantanée',
                                    subtitle: 'Résultats ultra-rapides et précis',
                                    delay: 0.3,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        // Boutons
                        Transform.scale(
                          scale: _buttonAnimation.value,
                          child: Opacity(
                            opacity: _buttonAnimation.value,
                            child: Column(
                              children: [
                                // Bouton principal
                                Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                    width: double.infinity,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF06B6D4), Color(0xFF0E7490)],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF06B6D4).withOpacity(0.4),
                                          blurRadius: 15,
                                          spreadRadius: 2,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => const HomeScreen()),
  );
},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: const Text(
                                        'Démarrer l\'essai gratuit',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 12),
                                
                                Text(
                                  'Sans engagement • Annulable à tout moment',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Bouton secondaire
                                TextButton(onPressed: () {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => const HomeScreen()),
  );
},
                                  child: Text(
                                    'Continuer avec la version gratuite',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 30),
                              ],
                            ),
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

  Widget _buildFeature({
    required IconData icon,
    required String title,
    required String subtitle,
    required double delay,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF06B6D4).withOpacity(0.15),
              border: Border.all(
                color: const Color(0xFF06B6D4).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF06B6D4),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticle(int index) {
    final random = math.Random(index);
    final x = random.nextDouble();
    final y = random.nextDouble();
    final size = random.nextDouble() * 2 + 1;
    final speed = random.nextDouble() * 0.3 + 0.1;
    
    return Positioned(
      left: MediaQuery.of(context).size.width * x,
      top: MediaQuery.of(context).size.height * y,
      child: Opacity(
        opacity: 0.2 * _backgroundAnimation.value,
        child: Transform.translate(
          offset: Offset(
            math.sin(_particleAnimation.value * 2 * math.pi * speed) * 15,
            math.cos(_particleAnimation.value * 2 * math.pi * speed) * 10,
          ),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF06B6D4),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF06B6D4).withOpacity(0.3),
                  blurRadius: 3,
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

class MiniAILogoPainter extends CustomPainter {
  final double animationValue;

  MiniAILogoPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 4;

    final paint = Paint()
      ..color = const Color(0xFF06B6D4)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = const Color(0xFF06B6D4).withOpacity(0.6)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Nœuds rotatifs
    for (int i = 0; i < 6; i++) {
      final angle = (i * 2 * math.pi / 6) + (animationValue * math.pi);
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;
      
      canvas.drawCircle(Offset(x, y), 2, paint);
      canvas.drawLine(center, Offset(x, y), strokePaint);
    }

    // Nœud central
    canvas.drawCircle(center, 3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}