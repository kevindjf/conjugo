/// Modèle représentant une partie d'un verbe (radical ou terminaison)
class VerbPart {
  final String text;
  final bool isRadical; // true pour radical, false pour terminaison

  const VerbPart({
    required this.text,
    required this.isRadical,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerbPart &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          isRadical == other.isRadical;

  @override
  int get hashCode => text.hashCode ^ isRadical.hashCode;

  @override
  String toString() => 'VerbPart(${isRadical ? "R" : "T"}: $text)';
}

/// Modèle représentant une conjugaison avec son découpage
class ConjugationParts {
  final String subject; // "je", "tu", "il/elle", etc.
  final String complet; // Forme complète : "parle"
  final String radical; // Radical : "parl"
  final String terminaison; // Terminaison : "e"

  const ConjugationParts({
    required this.subject,
    required this.complet,
    required this.radical,
    required this.terminaison,
  });

  factory ConjugationParts.fromJson(String subject, Map<String, dynamic> json) {
    return ConjugationParts(
      subject: subject,
      complet: json['complet'] as String,
      radical: json['radical'] as String,
      terminaison: json['terminaison'] as String,
    );
  }

  /// Vérifie si la combinaison radical + terminaison est correcte
  bool isCorrectCombination(String radicalTest, String terminaisonTest) {
    return radical == radicalTest && terminaison == terminaisonTest;
  }

  @override
  String toString() =>
      'ConjugationParts($subject: $complet = [$radical] + [$terminaison])';
}

/// Modèle représentant un verbe pour le Bâtisseur de Verbes
class VerbBuilder {
  final String infinitif;
  final String groupe; // "1", "2", "3"
  final Map<String, ConjugationParts> present; // Conjugaisons au présent

  const VerbBuilder({
    required this.infinitif,
    required this.groupe,
    required this.present,
  });

  factory VerbBuilder.fromJson(Map<String, dynamic> json) {
    final presentMap = json['present'] as Map<String, dynamic>;

    final conjugations = <String, ConjugationParts>{};
    presentMap.forEach((subject, data) {
      conjugations[subject] =
          ConjugationParts.fromJson(subject, data as Map<String, dynamic>);
    });

    return VerbBuilder(
      infinitif: json['infinitif'] as String,
      groupe: json['groupe'] as String,
      present: conjugations,
    );
  }

  /// Récupère les radicaux uniques de ce verbe
  Set<String> get uniqueRadicals {
    return present.values.map((c) => c.radical).toSet();
  }

  /// Récupère les terminaisons uniques de ce verbe
  Set<String> get uniqueTerminaisons {
    return present.values.map((c) => c.terminaison).toSet();
  }

  /// Récupère l'émoji correspondant au groupe
  String get groupEmoji {
    switch (groupe) {
      case '1':
        return '🌈';
      case '2':
        return '🌟';
      case '3':
        return '🏆';
      default:
        return '📖';
    }
  }

  @override
  String toString() => 'VerbBuilder($infinitif, groupe $groupe)';
}
