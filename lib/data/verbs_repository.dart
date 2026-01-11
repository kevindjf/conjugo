import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/verb.dart';

/// Service pour charger les verbes depuis le fichier JSON
class VerbsRepository {
  static List<Verb>? _cachedVerbs;

  /// Charge les verbes depuis le fichier JSON
  /// Utilise un cache pour éviter de recharger à chaque fois
  static Future<List<Verb>> loadVerbs() async {
    if (_cachedVerbs != null) return _cachedVerbs!;

    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/verbs.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      _cachedVerbs = jsonList
          .map((json) => Verb.fromJson(json as Map<String, dynamic>))
          .toList();
      return _cachedVerbs!;
    } catch (e) {
      // En cas d'erreur, retourner des verbes par défaut
      debugPrint('Erreur lors du chargement des verbes: $e');
      return _getDefaultVerbs();
    }
  }

  /// Retourne une liste de verbes par défaut en cas d'erreur
  static List<Verb> _getDefaultVerbs() {
    return const [
      Verb(
        infinitive: 'être',
        groupTag: 'exception',
        present: {
          'je': 'suis',
          'tu': 'es',
          'il/elle': 'est',
          'nous': 'sommes',
          'vous': 'êtes',
          'ils/elles': 'sont',
        },
      ),
      Verb(
        infinitive: 'avoir',
        groupTag: 'exception',
        present: {
          'je': 'ai',
          'tu': 'as',
          'il/elle': 'a',
          'nous': 'avons',
          'vous': 'avez',
          'ils/elles': 'ont',
        },
      ),
      Verb(
        infinitive: 'aller',
        groupTag: 'exception',
        present: {
          'je': 'vais',
          'tu': 'vas',
          'il/elle': 'va',
          'nous': 'allons',
          'vous': 'allez',
          'ils/elles': 'vont',
        },
      ),
      Verb(
        infinitive: 'faire',
        groupTag: 'exception',
        present: {
          'je': 'fais',
          'tu': 'fais',
          'il/elle': 'fait',
          'nous': 'faisons',
          'vous': 'faites',
          'ils/elles': 'font',
        },
      ),
      Verb(
        infinitive: 'parler',
        groupTag: '1',
        present: {
          'je': 'parle',
          'tu': 'parles',
          'il/elle': 'parle',
          'nous': 'parlons',
          'vous': 'parlez',
          'ils/elles': 'parlent',
        },
      ),
      Verb(
        infinitive: 'manger',
        groupTag: '1',
        present: {
          'je': 'mange',
          'tu': 'manges',
          'il/elle': 'mange',
          'nous': 'mangeons',
          'vous': 'mangez',
          'ils/elles': 'mangent',
        },
      ),
    ];
  }

  /// Réinitialise le cache (utile pour les tests)
  static void clearCache() {
    _cachedVerbs = null;
  }
}



