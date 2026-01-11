/// Mode de jeu du Bâtisseur de Verbes
enum GameMode {
  simple, // 10 questions, pas de timer, seules les erreurs comptent
  moyen, // 20 questions, pas de timer, seules les erreurs comptent
  expert, // Timer activé, le temps compte comme une faute
}

extension GameModeExtension on GameMode {
  /// Nombre de questions pour ce mode
  int get questionCount {
    switch (this) {
      case GameMode.simple:
        return 10;
      case GameMode.moyen:
        return 20;
      case GameMode.expert:
        return 20; // Peut être ajusté selon les besoins
    }
  }

  /// Indique si le timer est activé pour ce mode
  bool get hasTimer {
    switch (this) {
      case GameMode.simple:
      case GameMode.moyen:
        return false;
      case GameMode.expert:
        return true;
    }
  }

  /// Temps limite par question en secondes (pour le mode expert)
  int get timePerQuestion {
    return 30; // 30 secondes par question en mode expert
  }

  /// Nom d'affichage du mode
  String get displayName {
    switch (this) {
      case GameMode.simple:
        return 'Simple';
      case GameMode.moyen:
        return 'Moyen';
      case GameMode.expert:
        return 'Expert';
    }
  }

  /// Description du mode
  String get description {
    switch (this) {
      case GameMode.simple:
        return '10 questions\nPas de timer\nSeules les erreurs comptent';
      case GameMode.moyen:
        return '20 questions\nPas de timer\nSeules les erreurs comptent';
      case GameMode.expert:
        return 'Timer activé\nLe temps compte comme faute';
    }
  }

  /// Émoji du mode
  String get emoji {
    switch (this) {
      case GameMode.simple:
        return '😊';
      case GameMode.moyen:
        return '🎯';
      case GameMode.expert:
        return '🔥';
    }
  }
}

/// Configuration du jeu Bâtisseur de Verbes
class VerbBuilderConfig {
  final GameMode mode;
  final Set<String> selectedVerbs; // Infinitifs des verbes sélectionnés
  final int distractorCount; // Nombre de briques pièges (par défaut: 2 radicaux + 2 terminaisons)

  const VerbBuilderConfig({
    required this.mode,
    required this.selectedVerbs,
    this.distractorCount = 2,
  });

  int get questionCount => mode.questionCount;
  bool get hasTimer => mode.hasTimer;
  int get timePerQuestion => mode.timePerQuestion;

  @override
  String toString() =>
      'VerbBuilderConfig(${mode.displayName}, ${selectedVerbs.length} verbs)';
}
