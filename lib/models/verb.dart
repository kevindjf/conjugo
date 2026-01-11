/// Modèle représentant un verbe français avec ses conjugaisons
class Verb {
  final String infinitive;
  final String groupTag; // '1', '2', '3', 'exception'
  final Map<String, String> present; // clés: je, tu, il/elle, nous, vous, ils/elles

  const Verb({
    required this.infinitive,
    required this.groupTag,
    required this.present,
  });

  factory Verb.fromJson(Map<String, dynamic> json) {
    return Verb(
      infinitive: json['infinitif'] as String,
      groupTag: json['groupe'].toString(),
      present: Map<String, String>.from(json['present'] as Map),
    );
  }
}



