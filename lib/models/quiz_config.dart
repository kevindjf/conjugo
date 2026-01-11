/// Configuration du quiz avec les verbes sélectionnés et les paramètres
class QuizConfig {
  final Set<String> selectedVerbs; // Infinitifs des verbes sélectionnés
  final int timeLimit;
  final int numberQuestions;

  const QuizConfig({
    required this.selectedVerbs,
    required this.timeLimit,
    required this.numberQuestions,
  });
}



