import 'package:audioplayers/audioplayers.dart';

/// Gestionnaire audio pour les sons du jeu
class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final Map<String, AudioPlayer> _players = {};
  bool _soundEnabled = true;

  /// Active ou désactive les sons
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  /// Joue un son
  Future<void> play(AudioType type) async {
    if (!_soundEnabled) return;

    try {
      final player = _getPlayer(type);
      await player.stop(); // Arrêter si déjà en cours
      await player.play(AssetSource(_getAssetPath(type)));
    } catch (e) {
      // Gérer gracieusement l'absence de fichiers audio
      print('⚠️ Erreur audio (${type.name}): $e');
    }
  }

  /// Récupère ou crée un player pour un type de son
  AudioPlayer _getPlayer(AudioType type) {
    if (!_players.containsKey(type.name)) {
      _players[type.name] = AudioPlayer();
    }
    return _players[type.name]!;
  }

  /// Récupère le chemin du fichier audio
  String _getAssetPath(AudioType type) {
    switch (type) {
      case AudioType.pick:
        return 'sounds/pick.mp3';
      case AudioType.snap:
        return 'sounds/snap.mp3';
      case AudioType.correct:
        return 'sounds/correct.mp3';
      case AudioType.incorrect:
        return 'sounds/incorrect.mp3';
      case AudioType.timeUp:
        return 'sounds/time_up.mp3';
    }
  }

  /// Libère les ressources
  Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
  }
}

/// Types de sons disponibles
enum AudioType {
  pick, // Son quand on prend une brique
  snap, // Son quand on attache une brique
  correct, // Son pour bonne réponse
  incorrect, // Son pour mauvaise réponse
  timeUp, // Son quand le temps est écoulé
}
