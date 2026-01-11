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
    // Initialiser le jeu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(verbBuilderProvider.notifier).initGame(widget.config);
    });
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

    // Si terminé, afficher les résultats
    if (state.isFinished) {
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
    }

    final question = state.currentQuestion;

    if (question == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // En-tête avec score et progression
            _buildHeader(state),

            // Contenu principal
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Mascotte et consigne
                    _buildPrompt(question.getFullPrompt()),
                    const SizedBox(height: 20),

                    // Zone d'assemblage
                    _buildAssemblyZone(state),
                    const SizedBox(height: 30),

                    // Bac à briques
                    _buildBrickBin(question),
                    const SizedBox(height: 20),

                    // Bouton de validation
                    if (!state.isAnswered) _buildValidateButton(state),

                    // Feedback
                    if (state.showFeedback) _buildFeedback(state, question),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(state) {
    return Container(
      padding: const EdgeInsets.all(16.0),
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
          // Score
          Row(
            children: [
              Text(
                'Score: ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ...List.generate(3, (index) {
                return Icon(
                  index < (state.score / (state.totalQuestions / 3)).floor()
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                  size: 28,
                );
              }),
            ],
          ),

          // Progression
          Text(
            '${state.currentIndex + 1}/${state.totalQuestions}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Timer (si mode expert)
          if (widget.config.hasTimer)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: state.timeRemaining <= 5
                    ? Colors.red
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${state.timeRemaining}s',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          // Bouton aide (?)
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              _showHelp();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrompt(String prompt) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Mascotte robot
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '🤖',
                style: TextStyle(fontSize: 48),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Bulle de texte
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                prompt,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssemblyZone(state) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.shade300,
          width: 3,
        ),
      ),
      child: Column(
        children: [
          Text(
            'ZONE D\'ASSEMBLAGE',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 20),

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
    return Column(
      children: [
        // Section Radicaux
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                'RADICAUX',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
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
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Section Terminaisons
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                'TERMINAISONS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildValidateButton(state) {
    final canValidate = state.hasCompleteAnswer;

    return SizedBox(
      width: double.infinity,
      height: 56,
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
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'VALIDER',
          style: TextStyle(
            fontSize: 20,
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
      padding: const EdgeInsets.all(20.0),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.red,
          width: 3,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
                size: 48,
              ),
              const SizedBox(width: 12),
              Text(
                isTimeUp
                    ? 'Temps écoulé !'
                    : isCorrect
                        ? 'Bravo !'
                        : 'Pas tout à fait...',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green.shade800 : Colors.red.shade800,
                ),
              ),
            ],
          ),
          if (!isCorrect && !isTimeUp) ...[
            const SizedBox(height: 12),
            Text(
              'La bonne réponse : ${question.correctAnswer.complet}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.red.shade800,
              ),
            ),
            Text(
              '[${question.correctAnswer.radical}] + [${question.correctAnswer.terminaison}]',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.red.shade700,
              ),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(verbBuilderProvider.notifier).nextQuestion();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text('Question suivante'),
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
