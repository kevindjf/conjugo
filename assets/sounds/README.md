# Sons du Bâtisseur de Verbes

Ce dossier contient les fichiers audio utilisés dans le jeu.

## Fichiers requis

Pour un fonctionnement complet, ajoutez les fichiers audio suivants :

### Sons de jeu
- `pick.mp3` - Son joué quand on prend une brique (drag start)
- `snap.mp3` - Son joué quand on attache une brique (drop)
- `correct.mp3` - Son joué pour une bonne réponse
- `incorrect.mp3` - Son joué pour une mauvaise réponse
- `time_up.mp3` - Son joué quand le temps est écoulé (mode expert)

## Génération des sons

Vous pouvez :

### Option 1 : Sons gratuits en ligne
Téléchargez des sons gratuits depuis :
- [Freesound.org](https://freesound.org)
- [Zapsplat.com](https://www.zapsplat.com)
- [Mixkit.co](https://mixkit.co/free-sound-effects/)

### Option 2 : Générateur de sons
Utilisez un générateur de sons 8-bit :
- [BFXR](https://www.bfxr.net) - Générateur de sons rétro
- [ChipTone](https://sfbgames.itch.io/chiptone) - Éditeur de sons chiptune

### Option 3 : Synthèse vocale (TTS)
Pour les sons "correct" et "incorrect", vous pouvez utiliser :
- Google Cloud Text-to-Speech
- Amazon Polly
- [TTSFree.com](https://ttsfree.com)

## Recommandations

- **Format** : MP3 ou WAV
- **Durée** :
  - `pick.mp3` : 0.1-0.3s (court)
  - `snap.mp3` : 0.2-0.5s (court)
  - `correct.mp3` : 0.5-1.5s (joyeux)
  - `incorrect.mp3` : 0.5-1.5s (neutre/encourageant)
  - `time_up.mp3` : 0.5-1s (alarme douce)
- **Volume** : Normalisé à -3dB
- **Qualité** : 44.1kHz, 16-bit (suffisant pour un jeu)

## Sons de test

En l'absence de fichiers audio, l'application fonctionnera sans son (le gestionnaire audio gère les erreurs gracieusement).

Pour tester rapidement, vous pouvez créer des fichiers silencieux :
```bash
# Nécessite ffmpeg
ffmpeg -f lavfi -i anullsrc=r=44100:cl=mono -t 0.5 -q:a 9 -acodec libmp3lame pick.mp3
ffmpeg -f lavfi -i anullsrc=r=44100:cl=mono -t 0.5 -q:a 9 -acodec libmp3lame snap.mp3
ffmpeg -f lavfi -i anullsrc=r=44100:cl=mono -t 1.0 -q:a 9 -acodec libmp3lame correct.mp3
ffmpeg -f lavfi -i anullsrc=r=44100:cl=mono -t 1.0 -q:a 9 -acodec libmp3lame incorrect.mp3
ffmpeg -f lavfi -i anullsrc=r=44100:cl=mono -t 0.8 -q:a 9 -acodec libmp3lame time_up.mp3
```
