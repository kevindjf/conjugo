import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/verb_builder.dart';

/// Repository pour charger les verbes du Bâtisseur de Verbes
class VerbBuilderRepository {
  static List<VerbBuilder>? _cachedVerbs;

  /// Charge les verbes depuis le fichier JSON
  static Future<List<VerbBuilder>> loadVerbs() async {
    // Retourner le cache si disponible
    if (_cachedVerbs != null) {
      return _cachedVerbs!;
    }

    try {
      // Charger le fichier JSON
      final jsonString = await rootBundle.loadString('assets/data/verbs_builder.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      // Parser les verbes
      _cachedVerbs = jsonList
          .map((json) => VerbBuilder.fromJson(json as Map<String, dynamic>))
          .toList();

      return _cachedVerbs!;
    } catch (e) {
      print('❌ Erreur lors du chargement des verbes: $e');
      // Retourner une liste vide en cas d'erreur
      return [];
    }
  }

  /// Filtre les verbes par groupe
  static Future<List<VerbBuilder>> loadVerbsByGroup(String groupe) async {
    final allVerbs = await loadVerbs();
    return allVerbs.where((verb) => verb.groupe == groupe).toList();
  }

  /// Récupère les verbes par leurs infinitifs
  static Future<List<VerbBuilder>> getVerbsByInfinitifs(Set<String> infinitifs) async {
    final allVerbs = await loadVerbs();
    return allVerbs
        .where((verb) => infinitifs.contains(verb.infinitif))
        .toList();
  }

  /// Récupère un verbe aléatoire
  static Future<VerbBuilder?> getRandomVerb() async {
    final allVerbs = await loadVerbs();
    if (allVerbs.isEmpty) return null;

    allVerbs.shuffle();
    return allVerbs.first;
  }

  /// Récupère N verbes aléatoires
  static Future<List<VerbBuilder>> getRandomVerbs(int count) async {
    final allVerbs = await loadVerbs();
    if (allVerbs.isEmpty) return [];

    final shuffled = List<VerbBuilder>.from(allVerbs)..shuffle();
    return shuffled.take(count).toList();
  }

  /// Vide le cache (utile pour les tests)
  static void clearCache() {
    _cachedVerbs = null;
  }
}
