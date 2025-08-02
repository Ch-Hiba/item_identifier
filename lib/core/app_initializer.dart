import 'package:flutter/material.dart';
import 'package:item_identifier/screens/onboarding.dart';
import 'package:item_identifier/screens/splash_screen.dart';
import 'package:item_identifier/services/onboarding_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppInitializer extends StatefulWidget {
  const AppInitializer({Key? key}) : super(key: key);

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _showSplash = true;
  bool _hasSeenOnboarding = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Étape 1: Afficher le splash pendant au minimum 2.5 secondes
    final splashFuture = Future.delayed(const Duration(milliseconds: 2500));
    
    // Étape 2: Vérifier le statut de l'onboarding en parallèle
    final onboardingCheckFuture = _checkOnboardingStatus();
    
    // Attendre que les deux tâches soient terminées
    await Future.wait([splashFuture, onboardingCheckFuture]);
    
    // Étape 3: Masquer le splash et déterminer l'écran suivant
    if (mounted) {
      setState(() {
        _showSplash = false;
        _isInitialized = true;
      });
    }
  }

  Future<void> _checkOnboardingStatus() async {
  try {
    final hasSeenOnboarding = await OnboardingService.hasSeenOnboarding();
    
    if (mounted) {
      setState(() {
        _hasSeenOnboarding = hasSeenOnboarding;
      });
    }
  } catch (e) {
    print('Erreur lors de la vérification de l\'onboarding: $e');
    // En cas d'erreur, on considère que l'onboarding n'a pas été vu
    if (mounted) {
      setState(() {
        _hasSeenOnboarding = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    // Phase 1: Affichage du Splash Screen
    if (_showSplash) {
      return const AISplashScreen();
    }
    
    // Phase 2: Une fois initialisé, afficher l'écran approprié
    if (_isInitialized) {
      if (_hasSeenOnboarding) {
        // L'utilisateur a déjà vu l'onboarding, aller directement à l'accueil
        return const HomeScreen();
      } else {
        // Première installation, afficher l'onboarding
        return const AIOnboardingScreen();
      }
    }
    
    // Écran de fallback (ne devrait jamais être affiché)
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D9FF)),
        ),
      ),
    );
  }
}

// Mise à jour du HomeScreen pour inclure un bouton de reset de l'onboarding
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  Future<void> _resetOnboarding(BuildContext context) async {
  try {
    await OnboardingService.resetOnboarding();
    
    // Redémarrer l'application depuis l'initializer
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AppInitializer()),
        (route) => false,
      );
    }
  } catch (e) {
    print('Erreur lors de la réinitialisation de l\'onboarding: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Image Recognition',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        actions: [
          // Bouton pour tester l'onboarding à nouveau
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'reset_onboarding') {
                _resetOnboarding(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'reset_onboarding',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Color(0xFF00D9FF)),
                    SizedBox(width: 8),
                    Text('Revoir l\'onboarding'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
              Color(0xFF064E3B),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône principale avec animation
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF00D9FF).withOpacity(0.3),
                      const Color(0xFF00D9FF).withOpacity(0.1),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  size: 60,
                  color: Color(0xFF00D9FF),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Titre de bienvenue
              const Text(
                'Bienvenue !',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Sous-titre
              Text(
                'Prêt à analyser vos images avec l\'IA',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 18,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 60),
              
              // Bouton principal
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  onPressed: () {
                    // Ici, vous pouvez naviguer vers l'écran de capture d'image
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fonctionnalité à implémenter'),
                        backgroundColor: Color(0xFF00D9FF),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D9FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Analyser une image',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Boutons secondaires
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Historique à implémenter'),
                          backgroundColor: Color(0xFF064E3B),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.history,
                      color: Color(0xFF00D9FF),
                    ),
                    label: Text(
                      'Historique',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 40),
                  
                  TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Paramètres à implémenter'),
                          backgroundColor: Color(0xFF064E3B),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.settings,
                      color: Color(0xFF00D9FF),
                    ),
                    label: Text(
                      'Paramètres',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Indicateur de statut
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF00FF88),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Application initialisée',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
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
}