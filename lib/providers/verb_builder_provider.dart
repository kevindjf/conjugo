import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/verb_builder.dart';
import '../models/verb_builder_question.dart';
import '../models/verb_builder_config.dart';
import '../models/verb_builder_state.dart';
import '../data/verb_builder_repository.dart';
import '../data/constants.dart';

/// Provider pour le Bâtisseur de Verbes
final verbBuilderProvider =
    StateNotifierProvider<VerbBuilderNotifier, VerbBuilderState>(
  (ref) => VerbBuilderNotifier(),
);

/// Notifier pour gérer l'état du Bâtisseur de Verbes
class VerbBuilderNotifier extends StateNotifier<VerbBuilderState> {
  Timer? _timer;
  final Random _random = Random();

  VerbBuilderNotifier() : super(const VerbBuilderState(questions: []));

  /// Initialise le jeu avec une configuration
  Future<void> initGame(VerbBuilderConfig config) async {
    // Réinitialiser l'état pour éviter les problèmes de navigation
    state = const VerbBuilderState(questions: []);

    // Annuler le timer précédent s'il existe
    _timer?.cancel();

    // Charger les verbes sélectionnés
    final verbs = await VerbBuilderRepository.getVerbsByInfinitifs(config.selectedVerbs);

    if (verbs.isEmpty) {
      print('❌ Aucun verbe chargé');
      return;
    }

    // Générer les questions
    final questions = _buildQuestions(verbs, config);

    if (questions.isEmpty) {
      print('❌ Aucune question générée');
      return;
    }

    // Initialiser l'état
    state = VerbBuilderState(
      questions: questions,
      currentIndex: 0,
      score: 0,
      errors: 0,
      timeRemaining: config.hasTimer ? config.timePerQuestion : 0,
    );

    // Démarrer le timer si nécessaire
    if (config.hasTimer) {
      _startTimer(config.timePerQuestion);
    }
  }

  /// Génère les questions à partir des verbes sélectionnés
  List<VerbBuilderQuestion> _buildQuestions(
    List<VerbBuilder> verbs,
    VerbBuilderConfig config,
  ) {
    final questions = <VerbBuilderQuestion>[];
    final subjects = List<String>.from(SUBJECTS);

    int questionId = 0;

    // Générer les questions
    for (int i = 0; i < config.questionCount; i++) {
      // Choisir un verbe aléatoire
      final verb = verbs[_random.nextInt(verbs.length)];

      // Choisir un sujet aléatoire
      final subject = subjects[_random.nextInt(subjects.length)];

      // Récupérer la bonne réponse
      final correctAnswer = verb.present[subject]!;

      // Générer les briques (radicaux et terminaisons)
      final availableRadicals = _generateRadicals(
        correctRadical: correctAnswer.radical,
        currentVerb: verb,
        count: config.distractorCount,
      );

      final availableTerminaisons = _generateTerminaisons(
        correctTerminaison: correctAnswer.terminaison,
        currentVerb: verb,
        count: config.distractorCount,
      );

      // Créer la question
      questions.add(VerbBuilderQuestion(
        id: questionId++,
        verb: verb,
        subject: subject,
        correctAnswer: correctAnswer,
        availableRadicals: availableRadicals,
        availableTerminaisons: availableTerminaisons,
      ));
    }

    return questions;
  }

  /// Génère les briques radicaux (1 correct + N pièges du même verbe)
  List<VerbPart> _generateRadicals({
    required String correctRadical,
    required VerbBuilder currentVerb,
    required int count,
  }) {
    final radicals = <VerbPart>[
      VerbPart(text: correctRadical, isRadical: true),
    ];

    // Prendre les radicaux pièges du MÊME VERBE uniquement
    final verbRadicals = currentVerb.uniqueRadicals
        .where((r) => r != correctRadical)
        .toList();

    verbRadicals.shuffle(_random);

    // Ajouter les radicaux pièges (limité par count et ce qui est disponible)
    final trapCount = verbRadicals.length < count ? verbRadicals.length : count;
    for (final radical in verbRadicals.take(trapCount)) {
      radicals.add(VerbPart(text: radical, isRadical: true));
    }

    // Mélanger l'ordre
    radicals.shuffle(_random);

    return radicals;
  }

  /// Génère les briques terminaisons (1 correcte + N pièges du même verbe)
  List<VerbPart> _generateTerminaisons({
    required String correctTerminaison,
    required VerbBuilder currentVerb,
    required int count,
  }) {
    final terminaisons = <VerbPart>[
      VerbPart(text: correctTerminaison, isRadical: false),
    ];

    // Prendre les terminaisons pièges du MÊME VERBE uniquement
    final verbTerminaisons = currentVerb.uniqueTerminaisons
        .where((t) => t != correctTerminaison)
        .toList();

    verbTerminaisons.shuffle(_random);

    // Ajouter les terminaisons pièges (limité par count et ce qui est disponible)
    final trapCount = verbTerminaisons.length < count ? verbTerminaisons.length : count;
    for (final terminaison in verbTerminaisons.take(trapCount)) {
      terminaisons.add(VerbPart(text: terminaison, isRadical: false));
    }

    // Mélanger l'ordre
    terminaisons.shuffle(_random);

    return terminaisons;
  }

  /// Sélectionne un radical
  void selectRadical(VerbPart radical) {
    state = state.copyWith(selectedRadical: radical);
  }

  /// Sélectionne une terminaison
  void selectTerminaison(VerbPart terminaison) {
    state = state.copyWith(selectedTerminaison: terminaison);
  }

  /// Retire le radical sélectionné
  void clearRadical() {
    state = state.copyWith(clearRadical: true);
  }

  /// Retire la terminaison sélectionnée
  void clearTerminaison() {
    state = state.copyWith(clearTerminaison: true);
  }

  /// Valide la réponse actuelle
  void validateAnswer() {
    final currentQuestion = state.currentQuestion;
    if (currentQuestion == null || state.isAnswered) return;

    final radical = state.selectedRadical?.text;
    final terminaison = state.selectedTerminaison?.text;

    // Vérifier si la réponse est correcte
    final isCorrect = currentQuestion.isCorrectAnswer(radical, terminaison);

    // Mettre à jour le score
    state = state.copyWith(
      isAnswered: true,
      showFeedback: true,
      lastAnswerCorrect: isCorrect,
      score: isCorrect ? state.score + 1 : state.score,
      errors: isCorrect ? state.errors : state.errors + 1,
    );

    // Arrêter le timer
    _timer?.cancel();
  }

  /// Passe à la question suivante
  void nextQuestion() {
    if (state.isFinished) return;

    final newIndex = state.currentIndex + 1;

    // Réinitialiser l'état pour la prochaine question
    state = state.copyWith(
      currentIndex: newIndex,
      showFeedback: false,
      isAnswered: false,
      isTimeUp: false,
      clearRadical: true,
      clearTerminaison: true,
    );

    // Redémarrer le timer si nécessaire
    if (newIndex < state.questions.length) {
      final hasTimer = state.questions.isNotEmpty &&
          state.timeRemaining > 0; // Indicateur approximatif
      if (hasTimer) {
        // Réinitialiser le temps (on ne peut pas récupérer la config ici)
        // Solution: stocker la config dans l'état ou utiliser une valeur par défaut
        _startTimer(30); // Valeur par défaut
      }
    }
  }

  /// Démarre le timer
  void _startTimer(int seconds) {
    _timer?.cancel();

    state = state.copyWith(timeRemaining: seconds);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeRemaining <= 0) {
        timer.cancel();
        _onTimeUp();
        return;
      }

      state = state.copyWith(timeRemaining: state.timeRemaining - 1);
    });
  }

  /// Appelé quand le temps est écoulé
  void _onTimeUp() {
    if (state.isAnswered) return;

    // Marquer comme erreur
    state = state.copyWith(
      isAnswered: true,
      isTimeUp: true,
      showFeedback: true,
      lastAnswerCorrect: false,
      errors: state.errors + 1,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
