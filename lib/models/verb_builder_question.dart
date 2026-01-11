import 'verb_builder.dart';

/// Modèle représentant une question du Bâtisseur de Verbes
class VerbBuilderQuestion {
  final int id; // Identifiant unique de la question
  final VerbBuilder verb; // Le verbe de la question
  final String subject; // Le sujet : "je", "tu", "il/elle", etc.
  final ConjugationParts correctAnswer; // La bonne réponse
  final List<VerbPart> availableRadicals; // Radicaux disponibles (briques bleues)
  final List<VerbPart> availableTerminaisons; // Terminaisons disponibles (briques oranges)
  final String? contextPhrase; // Phrase contextuelle (optionnelle)

  const VerbBuilderQuestion({
    required this.id,
    required this.verb,
    required this.subject,
    required this.correctAnswer,
    required this.availableRadicals,
    required this.availableTerminaisons,
    this.contextPhrase,
  });

  /// Vérifie si la combinaison radical + terminaison est correcte
  bool isCorrectAnswer(String? radical, String? terminaison) {
    if (radical == null || terminaison == null) return false;
    return correctAnswer.isCorrectCombination(radical, terminaison);
  }

  /// Génère la phrase à afficher
  String getDisplayPhrase() {
    if (contextPhrase != null) {
      return contextPhrase!;
    }
    // Phrase générique par défaut
    return '$subject _____ (${verb.infinitif})';
  }

  /// Génère la consigne complète
  String getFullPrompt() {
    return 'Aide-moi à construire le verbe !\n${getDisplayPhrase()}';
  }

  @override
  String toString() =>
      'VerbBuilderQuestion(#$id: ${verb.infinitif} - $subject)';
}
