import '../models/verb.dart';

/// Modèle représentant une question de quiz
class QuizQuestion {
  final int id; // identifiant pour clés stables
  final Verb verb;
  final String subject; // ex: 'je'
  final String correct; // forme correcte
  final List<String> options; // QCM figé (ordre immuable)

  const QuizQuestion({
    required this.id,
    required this.verb,
    required this.subject,
    required this.correct,
    required this.options,
  });
}



