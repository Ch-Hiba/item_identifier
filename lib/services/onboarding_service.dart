import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _onboardingKey = 'has_seen_onboarding';

  /// Marque l'onboarding comme terminé
  static Future<bool> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_onboardingKey, true);
    } catch (e) {
      print('Erreur lors de la sauvegarde de l\'onboarding: $e');
      return false;
    }
  }

  /// Vérifie si l'utilisateur a déjà vu l'onboarding
  static Future<bool> hasSeenOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_onboardingKey) ?? false;
    } catch (e) {
      print('Erreur lors de la lecture de l\'onboarding: $e');
      return false;
    }
  }

  /// Remet à zéro l'état d'onboarding (utile pour le développement)
  static Future<bool> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_onboardingKey);
    } catch (e) {
      print('Erreur lors de la réinitialisation de l\'onboarding: $e');
      return false;
    }
  }
}