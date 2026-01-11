import 'verb_builder_question.dart';
import 'verb_builder.dart';

/// État du jeu Bâtisseur de Verbes
class VerbBuilderState {
  final List<VerbBuilderQuestion> questions; // Toutes les questions
  final int currentIndex; // Index de la question actuelle
  final int score; // Score actuel (bonnes réponses)
  final int errors; // Nombre d'erreurs
  final int timeRemaining; // Temps restant pour la question actuelle (secondes)
  final bool showFeedback; // Afficher le feedback après réponse
  final bool lastAnswerCorrect; // Dernière réponse était-elle correcte?
  final VerbPart? selectedRadical; // Radical sélectionné
  final VerbPart? selectedTerminaison; // Terminaison sélectionnée
  final bool isAnswered; // La question actuelle a-t-elle été répondue?
  final bool isTimeUp; // Le temps est-il écoulé?

  const VerbBuilderState({
    required this.questions,
    this.currentIndex = 0,
    this.score = 0,
    this.errors = 0,
    this.timeRemaining = 0,
    this.showFeedback = false,
    this.lastAnswerCorrect = false,
    this.selectedRadical,
    this.selectedTerminaison,
    this.isAnswered = false,
    this.isTimeUp = false,
  });

  /// Question actuelle
  VerbBuilderQuestion? get currentQuestion =>
      currentIndex < questions.length ? questions[currentIndex] : null;

  /// Indique si le jeu est terminé
  bool get isFinished => currentIndex >= questions.length;

  /// Pourcentage de bonnes réponses
  double get scorePercentage {
    final total = currentIndex > 0 ? currentIndex : 1;
    return (score / total) * 100;
  }

  /// Nombre total de questions
  int get totalQuestions => questions.length;

  /// Indicateur de progression (0.0 à 1.0)
  double get progress =>
      totalQuestions > 0 ? currentIndex / totalQuestions : 0.0;

  /// Vérifie si une combinaison est en cours d'assemblage
  bool get hasPartialAnswer => selectedRadical != null || selectedTerminaison != null;

  /// Vérifie si la combinaison est complète (radical + terminaison)
  bool get hasCompleteAnswer => selectedRadical != null && selectedTerminaison != null;

  /// Copie l'état avec des modifications
  VerbBuilderState copyWith({
    List<VerbBuilderQuestion>? questions,
    int? currentIndex,
    int? score,
    int? errors,
    int? timeRemaining,
    bool? showFeedback,
    bool? lastAnswerCorrect,
    VerbPart? selectedRadical,
    VerbPart? selectedTerminaison,
    bool? isAnswered,
    bool? isTimeUp,
    bool clearRadical = false,
    bool clearTerminaison = false,
  }) {
    return VerbBuilderState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      score: score ?? this.score,
      errors: errors ?? this.errors,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      showFeedback: showFeedback ?? this.showFeedback,
      lastAnswerCorrect: lastAnswerCorrect ?? this.lastAnswerCorrect,
      selectedRadical: clearRadical ? null : (selectedRadical ?? this.selectedRadical),
      selectedTerminaison: clearTerminaison ? null : (selectedTerminaison ?? this.selectedTerminaison),
      isAnswered: isAnswered ?? this.isAnswered,
      isTimeUp: isTimeUp ?? this.isTimeUp,
    );
  }

  @override
  String toString() =>
      'VerbBuilderState(Q: ${currentIndex + 1}/${totalQuestions}, Score: $score, Errors: $errors)';
}
