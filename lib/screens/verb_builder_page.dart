import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/verb_builder_config.dart';
import '../providers/verb_builder_provider.dart';
import '../widgets/draggable_brick.dart';
import '../widgets/brick_drop_zone.dart';
import '../services/audio_manager.dart';
import 'verb_builder_result_page.dart';

/// Page principale du jeu Bâtisseur de Verbes
class VerbBuilderPage extends ConsumerStatefulWidget {
  final VerbBuilderConfig config;

  const VerbBuilderPage({
    super.key,
    required this.config,
  });

  @override
  ConsumerState<VerbBuilderPage> createState() => _VerbBuilderPageState();
}

class _VerbBuilderPageState extends ConsumerState<VerbBuilderPage> {
  bool _lastShowFeedback = false;

  @override
  void initState() {
    super.initState();
    // Forcer le mode paysage
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Initialiser le jeu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(verbBuilderProvider.notifier).initGame(widget.config);
    });
  }

  @override
  void dispose() {
    // Restaurer toutes les orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(verbBuilderProvider);

    // Jouer le son de feedback quand il est affiché
    if (state.showFeedback && !_lastShowFeedback) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (state.isTimeUp) {
          AudioManager().play(AudioType.timeUp);
        } else if (state.lastAnswerCorrect) {
          AudioManager().play(AudioType.correct);
        } else {
          AudioManager().play(AudioType.incorrect);
        }
      });
    }
    _lastShowFeedback = state.showFeedback;

    final question = state.currentQuestion;

    // Si le jeu n'est pas encore initialisé, afficher un loader
    if (question == null && state.questions.isEmpty) {
      return Scaffold(
        backgroundColor: Color(0xFFB3E5FC),
        body: Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      );
    }

    // Si terminé (et qu'il y avait des questions), afficher les résultats
    if (state.isFinished && state.totalQuestions > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerbBuilderResultPage(
              score: state.score,
              errors: state.errors,
              totalQuestions: state.totalQuestions,
            ),
          ),
        );
      });

      // Afficher un loader pendant la navigation
      return Scaffold(
        backgroundColor: Color(0xFFB3E5FC),
        body: Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      );
    }

    // Si question est null mais qu'on n'est pas fini, afficher un loader
    if (question == null) {
      return Scaffold(
        backgroundColor: Color(0xFFB3E5FC),
        body: Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFB3E5FC), // Bleu ciel comme l'image
      body: SafeArea(
        child: Column(
          children: [
            // En-tête avec score et progression (plus compact)
            _buildHeader(state),

            // Contenu principal en mode horizontal
            Expanded(
              child: Row(
                children: [
                  // Colonne gauche : Mascotte + Consigne (plus étroite)
                  Expanded(
                    flex: 2,
                    child: _buildLeftPanel(question.getFullPrompt()),
                  ),

                  // Colonne centrale : Zone d'assemblage + Bac à briques
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        // Zone d'assemblage (plus compacte)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          child: _buildAssemblyZone(state),
                        ),

                        // Bac à briques (prend plus de place)
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: _buildBrickBin(question),
                          ),
                        ),

                        // Bouton de validation ou Feedback (plus compact)
                        if (state.showFeedback)
                          _buildFeedback(state, question)
                        else if (!state.isAnswered)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: _buildValidateButton(state),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade600,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Score avec étoiles
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Text(
                  'Score: ',
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ...List.generate(3, (index) {
                  return Icon(
                    index < (state.score / (state.totalQuestions / 3)).floor()
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ],
            ),
          ),

          // Titre
          Text(
            'L\'ATELIER DES VERBES',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),

          // Bouton aide
          IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            icon: Icon(Icons.help_outline, color: Colors.white, size: 24),
            onPressed: () {
              _showHelp();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPanel(String prompt) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Mascotte robot (plus petite)
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '🤖',
                style: TextStyle(fontSize: 42),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Bulle de texte (plus compacte)
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue.shade200,
                width: 1.5,
              ),
            ),
            child: Text(
              prompt,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssemblyZone(state) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.shade300,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            'ZONE D\'ASSEMBLAGE',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Zone Radical
              BrickDropZone(
                label: 'Radical',
                isRadical: true,
                currentPart: state.selectedRadical,
                onAccept: (part) {
                  ref.read(verbBuilderProvider.notifier).selectRadical(part);
                  HapticFeedback.mediumImpact();
                  AudioManager().play(AudioType.snap);
                },
                onRemove: () {
                  ref.read(verbBuilderProvider.notifier).clearRadical();
                },
              ),

              // Symbole "+"
              Text(
                '+',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade400,
                ),
              ),

              // Zone Terminaison
              BrickDropZone(
                label: 'Terminaison',
                isRadical: false,
                currentPart: state.selectedTerminaison,
                onAccept: (part) {
                  ref.read(verbBuilderProvider.notifier).selectTerminaison(part);
                  HapticFeedback.mediumImpact();
                  AudioManager().play(AudioType.snap);
                },
                onRemove: () {
                  ref.read(verbBuilderProvider.notifier).clearTerminaison();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBrickBin(question) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Center(
            child: Text(
              'BAC À BRIQUES',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Briques côte à côte
          Expanded(
            child: Row(
              children: [
                // Section Radicaux (gauche)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'RADICAUX',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              alignment: WrapAlignment.center,
                              children: question.availableRadicals.map<Widget>((part) {
                                return DraggableBrick(
                                  part: part,
                                  onDragStarted: () {
                                    HapticFeedback.lightImpact();
                                    AudioManager().play(AudioType.pick);
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Section Terminaisons (droite)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade600,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'TERMINAISONS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              alignment: WrapAlignment.center,
                              children: question.availableTerminaisons.map<Widget>((part) {
                                return DraggableBrick(
                                  part: part,
                                  onDragStarted: () {
                                    HapticFeedback.lightImpact();
                                    AudioManager().play(AudioType.pick);
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidateButton(state) {
    final canValidate = state.hasCompleteAnswer;

    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        onPressed: canValidate
            ? () {
                ref.read(verbBuilderProvider.notifier).validateAnswer();
                HapticFeedback.heavyImpact();
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canValidate ? Colors.green : Colors.grey,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'VALIDER',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFeedback(state, question) {
    final isCorrect = state.lastAnswerCorrect;
    final isTimeUp = state.isTimeUp;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icône et message
          Expanded(
            child: Row(
              children: [
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isTimeUp
                            ? 'Temps écoulé !'
                            : isCorrect
                                ? 'Bravo !'
                                : 'Pas tout à fait...',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isCorrect ? Colors.green.shade800 : Colors.red.shade800,
                        ),
                      ),
                      if (!isCorrect && !isTimeUp) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Réponse: ${question.correctAnswer.complet}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bouton suivant
          ElevatedButton(
            onPressed: () {
              ref.read(verbBuilderProvider.notifier).nextQuestion();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              'Suivant',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Comment jouer ?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Glisse un radical (bleu) dans la zone "Radical"'),
            SizedBox(height: 8),
            Text('2. Glisse une terminaison (orange) dans la zone "Terminaison"'),
            SizedBox(height: 8),
            Text('3. Appuie sur "VALIDER" pour vérifier ta réponse'),
            SizedBox(height: 8),
            Text('4. Continue jusqu\'à la fin des questions !'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Compris !'),
          ),
        ],
      ),
    );
  }
}
