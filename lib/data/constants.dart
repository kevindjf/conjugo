/// Constantes utilisées dans l'application
class AppConstants {
  // Sujets de conjugaison
  static const subjects = ['je', 'tu', 'il/elle', 'nous', 'vous', 'ils/elles'];

  // Options de temps de réponse (en secondes)
  static const timeLimits = [10, 15, 20, 30, 35];

  // Options de nombre de questions
  static const questionCounts = [10, 15, 20, 30, 35];

  // Valeurs par défaut
  static const defaultTimeLimit = 15;
  static const defaultQuestionCount = 15;

  // Métadonnées des groupes de verbes
  static const groupMetadata = {
    'exception': {
      'emoji': '🎪',
      'color': 0xFFFF9800, // Orange
      'name': 'Exceptions',
      'description': 'Les verbes magiques (être, avoir, aller, faire)',
    },
    '1': {
      'emoji': '🌈',
      'color': 0xFFE91E63, // Pink
      'name': '1er groupe',
      'description': 'Les verbes faciles !',
    },
    '2': {
      'emoji': '🌟',
      'color': 0xFF2196F3, // Blue
      'name': '2ème groupe',
      'description': 'Un peu plus difficile',
    },
    '3': {
      'emoji': '🏆',
      'color': 0xFF9C27B0, // Purple
      'name': '3ème groupe',
      'description': 'Pour les champions !',
    },
  };
}



