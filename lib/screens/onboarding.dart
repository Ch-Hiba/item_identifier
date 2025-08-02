import 'package:flutter/material.dart';
import 'package:item_identifier/core/app_initializer.dart';
import 'package:item_identifier/screens/paywall_screen.dart';
import 'package:item_identifier/services/onboarding_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

class AIOnboardingScreen extends StatefulWidget {
  const AIOnboardingScreen({Key? key}) : super(key: key);

  @override
  State<AIOnboardingScreen> createState() => _AIOnboardingScreenState();
}

class _AIOnboardingScreenState extends State<AIOnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  
  int _currentPage = 0;
  final int _totalPages = 3;
  bool _isCompletingOnboarding = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
    _particleController.repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _currentPage++;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _animationController.reset();
      _animationController.forward();
    } else {
      // Dernière page - terminer l'onboarding
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _animationController.reset();
      _animationController.forward();
    }
  }

  
Future<void> _completeOnboarding() async {
  if (_isCompletingOnboarding) return;
  
  setState(() {
    _isCompletingOnboarding = true;
  });

  try {
    // Sauvegarder que l'onboarding est terminé
    await OnboardingService.completeOnboarding();
    
    // Naviguer vers l'écran principal
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AIPaywallScreen()),
      );
    }
  } catch (e) {
    print('Erreur lors de la sauvegarde de l\'onboarding: $e');
    // En cas d'erreur, on navigue quand même
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A), // Bleu nuit
              Color(0xFF1E293B),
              Color(0xFF064E3B), // Vert foncé
              Color(0xFF065F46),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Particules de fond
            ...List.generate(15, (index) => _buildBackgroundParticle(index)),
            
            // Contenu principal
            PageView(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
                _animationController.reset();
                _animationController.forward();
              },
              children: [
                _buildPage1(),
                _buildPage2(),
                _buildPage3(),
              ],
            ),
            
            // Indicateurs de page
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_totalPages, (index) =>
                  _buildPageIndicator(index == _currentPage)),
              ),
            ),
            
            // Boutons de navigation
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0 && !_isCompletingOnboarding)
                    _buildNavButton('Précédent', false, _previousPage)
                  else
                    const SizedBox(width: 100),
                  
                  _buildNavButton(
                    _isCompletingOnboarding 
                        ? 'Chargement...'
                        : (_currentPage == _totalPages - 1 ? 'Commencer' : 'Suivant'),
                    true,
                    _isCompletingOnboarding ? () {} : _nextPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage1() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animation de l'icône principale
              Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Container(
                    width: 200,
                    height: 200,
                    child: CustomPaint(
                      painter: CameraScanPainter(
                        animationValue: _particleController.value,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 60),
              
              Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Column(
                    children: [
                      Text(
                        'Recherche IA par Image',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      Text(
                        'Prenez une photo ou sélectionnez une image\npour une analyse intelligente instantanée.\nL\'IA reconnaît objets, plantes, animaux et plus.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                          height: 1.5,
                          fontFamily: 'Poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPage2() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Container(
                    width: 200,
                    height: 200,
                    child: CustomPaint(
                      painter: AnalysisPainter(
                        animationValue: _particleController.value,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 60),
              
              Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Column(
                    children: [
                      Text(
                        'Analyse Enrichie Intelligente',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      Text(
                        'Obtenez des informations détaillées :\nidentification précise, OCR avec traduction,\nréponses à vos questions et suggestions.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                          height: 1.5,
                          fontFamily: 'Poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPage3() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Container(
                    width: 200,
                    height: 200,
                    child: CustomPaint(
                      painter: HistoryPainter(
                        animationValue: _particleController.value,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 60),
              
              Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Column(
                    children: [
                      Text(
                        'Historique & Recherche Produits',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      Text(
                        'Retrouvez toutes vos recherches,\naccédez aux liens d\'achat des objets\nidentifiés et explorez votre historique.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                          height: 1.5,
                          fontFamily: 'Poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isActive 
          ? const Color(0xFF00D9FF)
          : Colors.white.withOpacity(0.3),
        boxShadow: isActive ? [
          BoxShadow(
            color: const Color(0xFF00D9FF).withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ] : null,
      ),
    );
  }

  Widget _buildNavButton(String text, bool isPrimary, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: isPrimary ? const LinearGradient(
            colors: [Color(0xFF00D9FF), Color(0xFF0099CC)],
          ) : null,
          border: isPrimary ? null : Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: isPrimary ? [
            BoxShadow(
              color: const Color(0xFF00D9FF).withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isCompletingOnboarding && isPrimary) ...[
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w400,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundParticle(int index) {
    final random = math.Random(index);
    final x = random.nextDouble();
    final y = random.nextDouble();
    final size = random.nextDouble() * 2 + 1;
    final speed = random.nextDouble() * 0.3 + 0.1;
    
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return Positioned(
          left: MediaQuery.of(context).size.width * x,
          top: MediaQuery.of(context).size.height * y,
          child: Opacity(
            opacity: 0.4,
            child: Transform.translate(
              offset: Offset(
                math.sin(_particleController.value * 2 * math.pi * speed) * 30,
                math.cos(_particleController.value * 2 * math.pi * speed) * 20,
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
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Classes des painters (inchangées)
class CameraScanPainter extends CustomPainter {
  final double animationValue;

  CameraScanPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    // Caméra principale
    final cameraPaint = Paint()
      ..color = const Color(0xFF00D9FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final cameraFillPaint = Paint()
      ..color = const Color(0xFF00D9FF).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Corps de la caméra
    final cameraRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 80, height: 60),
      const Radius.circular(12),
    );
    
    canvas.drawRRect(cameraRect, cameraFillPaint);
    canvas.drawRRect(cameraRect, cameraPaint);

    // Objectif
    canvas.drawCircle(center, 20, cameraFillPaint);
    canvas.drawCircle(center, 20, cameraPaint);
    canvas.drawCircle(center, 12, cameraPaint);

    // Lignes de scan animées
    final scanPaint = Paint()
      ..color = const Color(0xFF00FF88)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 4; i++) {
      final angle = (i * math.pi / 2) + (animationValue * math.pi * 2);
      final startRadius = 35 + (math.sin(animationValue * math.pi * 2) * 10);
      final endRadius = startRadius + 40;
      
      final startX = center.dx + math.cos(angle) * startRadius;
      final startY = center.dy + math.sin(angle) * startRadius;
      final endX = center.dx + math.cos(angle) * endRadius;
      final endY = center.dy + math.sin(angle) * endRadius;
      
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), scanPaint);
    }

    // Coins de cadrage
    final cornerPaint = Paint()
      ..color = const Color(0xFF00D9FF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final cornerSize = 20.0;
    final frameSize = radius + 30;
    
    // Coin supérieur gauche
    canvas.drawLine(
      Offset(center.dx - frameSize, center.dy - frameSize),
      Offset(center.dx - frameSize + cornerSize, center.dy - frameSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(center.dx - frameSize, center.dy - frameSize),
      Offset(center.dx - frameSize, center.dy - frameSize + cornerSize),
      cornerPaint,
    );

    // Coin supérieur droit
    canvas.drawLine(
      Offset(center.dx + frameSize, center.dy - frameSize),
      Offset(center.dx + frameSize - cornerSize, center.dy - frameSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(center.dx + frameSize, center.dy - frameSize),
      Offset(center.dx + frameSize, center.dy - frameSize + cornerSize),
      cornerPaint,
    );

    // Coin inférieur gauche
    canvas.drawLine(
      Offset(center.dx - frameSize, center.dy + frameSize),
      Offset(center.dx - frameSize + cornerSize, center.dy + frameSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(center.dx - frameSize, center.dy + frameSize),
      Offset(center.dx - frameSize, center.dy + frameSize - cornerSize),
      cornerPaint,
    );

    // Coin inférieur droit
    canvas.drawLine(
      Offset(center.dx + frameSize, center.dy + frameSize),
      Offset(center.dx + frameSize - cornerSize, center.dy + frameSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(center.dx + frameSize, center.dy + frameSize),
      Offset(center.dx + frameSize, center.dy + frameSize - cornerSize),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AnalysisPainter extends CustomPainter {
  final double animationValue;

  AnalysisPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Réseau neuronal
    final nodePaint = Paint()
      ..color = const Color(0xFF00D9FF)
      ..style = PaintingStyle.fill;

    final connectionPaint = Paint()
      ..color = const Color(0xFF00D9FF).withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Nœuds du réseau
    final nodes = <Offset>[];
    
    // Couche d'entrée
    for (int i = 0; i < 3; i++) {
      nodes.add(Offset(center.dx - 60, center.dy - 40 + (i * 40)));
    }
    
    // Couche cachée
    for (int i = 0; i < 4; i++) {
      nodes.add(Offset(center.dx, center.dy - 60 + (i * 40)));
    }
    
    // Couche de sortie
    for (int i = 0; i < 2; i++) {
      nodes.add(Offset(center.dx + 60, center.dy - 20 + (i * 40)));
    }

    // Dessiner les connexions animées
    for (int i = 0; i < 3; i++) {
      for (int j = 3; j < 7; j++) {
        final opacity = (math.sin(animationValue * 2 * math.pi + i + j) + 1) / 2;
        connectionPaint.color = const Color(0xFF00D9FF).withOpacity(opacity * 0.8);
        canvas.drawLine(nodes[i], nodes[j], connectionPaint);
      }
    }
    
    for (int i = 3; i < 7; i++) {
      for (int j = 7; j < 9; j++) {
        final opacity = (math.sin(animationValue * 2 * math.pi + i + j + 1) + 1) / 2;
        connectionPaint.color = const Color(0xFF00D9FF).withOpacity(opacity * 0.8);
        canvas.drawLine(nodes[i], nodes[j], connectionPaint);
      }
    }

    // Dessiner les nœuds
    for (int i = 0; i < nodes.length; i++) {
      final nodeSize = 6.0 + (math.sin(animationValue * 2 * math.pi + i) * 2);
      canvas.drawCircle(nodes[i], nodeSize, nodePaint);
    }

    // Cercles d'analyse animés
    final analysisPaint = Paint()
      ..color = const Color(0xFF00FF88).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 3; i++) {
      final animatedRadius = 30 + (i * 15) + (math.sin(animationValue * 2 * math.pi + i) * 10);
      canvas.drawCircle(center, animatedRadius, analysisPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class HistoryPainter extends CustomPainter {
  final double animationValue;

  HistoryPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Conteneur principal
    final containerPaint = Paint()
      ..color = const Color(0xFF00D9FF).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFF00D9FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Écran/tablette
    final screenRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 120, height: 160),
      const Radius.circular(12),
    );
    
    canvas.drawRRect(screenRect, containerPaint);
    canvas.drawRRect(screenRect, borderPaint);

    // Lignes d'historique animées
    final linePaint = Paint()
      ..color = const Color(0xFF00D9FF).withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 5; i++) {
      final y = center.dy - 60 + (i * 25);
      final animatedWidth = 60 + (math.sin(animationValue * 2 * math.pi + i) * 20);
      
      canvas.drawLine(
        Offset(center.dx - 45, y),
        Offset(center.dx - 45 + animatedWidth, y),
        linePaint,
      );
      
      // Petits cercles à côté des lignes
      canvas.drawCircle(
        Offset(center.dx - 55, y),
        3,
        Paint()..color = const Color(0xFF00FF88),
      );
    }

    // Particules de données flottantes
    final dataPaint = Paint()
      ..color = const Color(0xFF00FF88)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi / 3) + (animationValue * math.pi);
      final distance = 80 + (math.sin(animationValue * 2 * math.pi + i) * 15);
      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance;
      
      canvas.drawCircle(Offset(x, y), 4, dataPaint);
    }

    // Icône de recherche animée
    final searchPaint = Paint()
      ..color = const Color(0xFF00D9FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final searchCenter = Offset(center.dx + 80, center.dy - 80);
    final searchRadius = 15 + (math.sin(animationValue * math.pi * 2) * 3);
    
    canvas.drawCircle(searchCenter, searchRadius, searchPaint);
    
    final handleStart = Offset(
      searchCenter.dx + math.cos(math.pi / 4) * searchRadius,
      searchCenter.dy + math.sin(math.pi / 4) * searchRadius,
    );
    final handleEnd = Offset(handleStart.dx + 10, handleStart.dy + 10);
    
    canvas.drawLine(handleStart, handleEnd, searchPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}