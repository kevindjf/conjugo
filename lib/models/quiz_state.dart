import 'quiz_question.dart';

/// État du quiz en cours
class QuizState {
  final List<QuizQuestion> questions;
  final int index;
  final int score;
  final int timeRemaining;
  final bool showFeedback;
  final bool lastCorrect;

  const QuizState({
    required this.questions,
    this.index = 0,
    this.score = 0,
    this.timeRemaining = 0,
    this.showFeedback = false,
    this.lastCorrect = false,
  });

  QuizState copyWith({
    List<QuizQuestion>? questions,
    int? index,
    int? score,
    int? timeRemaining,
    bool? showFeedback,
    bool? lastCorrect,
  }) =>
      QuizState(
        questions: questions ?? this.questions,
        index: index ?? this.index,
        score: score ?? this.score,
        timeRemaining: timeRemaining ?? this.timeRemaining,
        showFeedback: showFeedback ?? this.showFeedback,
        lastCorrect: lastCorrect ?? this.lastCorrect,
      );
}



