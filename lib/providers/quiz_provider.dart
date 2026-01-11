import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/verb.dart';
import '../models/quiz_question.dart';
import '../models/quiz_state.dart';
import '../data/constants.dart';

/// StateNotifier qui gère l'état du quiz
class QuizNotifier extends StateNotifier<QuizState> {
  final List<Verb> pool;
  final int timeLimit;
  final int numberQuestion;
  Timer? _timer;

  QuizNotifier(this.pool, this.timeLimit, this.numberQuestion)
      : super(const QuizState(questions: [])) {
    final qs = _buildQuestions(pool, numberQuestion);
    state = state.copyWith(
      questions: qs,
      index: 0,
      score: 0,
      timeRemaining: timeLimit,
      showFeedback: false,
      lastCorrect: false,
    );
    _startTimer();
  }

  /// Construit les questions du quiz
  static List<QuizQuestion> _buildQuestions(List<Verb> pool, int count) {
    final rng = Random();
    final questions = <QuizQuestion>[];
    for (var i = 0; i < count; i++) {
      final verb = pool[rng.nextInt(pool.length)];
      final subject = AppConstants.subjects[rng.nextInt(AppConstants.subjects.length)];
      final correct = verb.present[subject]!;

      // Distracteurs : autres formes du même verbe + formes d'un autre verbe pour le même sujet
      final opts = <String>{correct};
      // même verbe, autres sujets
      for (final s in AppConstants.subjects) {
        if (opts.length >= 3) break;
        final form = verb.present[s]!;
        opts.add(form);
      }
      // autres verbes, même sujet
      for (final v in pool) {
        if (opts.length >= 3) break;
        opts.add(v.present[subject]!);
      }

      final options = opts.toList()..shuffle(rng);
      questions.add(QuizQuestion(
        id: i,
        verb: verb,
        subject: subject,
        correct: correct,
        options: List.unmodifiable(options), // 🔒 on gèle l'ordre, pas de reshuffle après
      ));
    }
    return questions;
  }

  /// Démarre le timer pour la question en cours
  void _startTimer() {
    _timer?.cancel();
    state = state.copyWith(timeRemaining: timeLimit);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.timeRemaining <= 1) {
        answer(null); // temps écoulé → considéré faux
      } else {
        state = state.copyWith(timeRemaining: state.timeRemaining - 1);
      }
    });
  }

  /// Enregistre la réponse de l'utilisateur
  void answer(String? choice) {
    _timer?.cancel();
    final q = state.questions[state.index];
    final ok = (choice != null && choice == q.correct);
    state = state.copyWith(
      score: state.score + (ok ? 1 : 0),
      showFeedback: true,
      lastCorrect: ok,
    );
  }

  /// Passe à la question suivante
  void next() {
    final last = state.index >= state.questions.length - 1;
    if (last) {
      // fin du quiz → plus de timer
      _timer?.cancel();
      return;
    }
    state = state.copyWith(
      index: state.index + 1,
      showFeedback: false,
      lastCorrect: false,
    );
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Provider pour le quiz
/// Note: Ce provider sera généralement overridé avec des verbes spécifiques
final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  // Valeurs par défaut - ce provider sera toujours overridé lors du lancement du quiz
  // On retourne un notifier avec une liste vide qui sera remplacée
  return QuizNotifier([], AppConstants.defaultTimeLimit, AppConstants.defaultQuestionCount);
});

