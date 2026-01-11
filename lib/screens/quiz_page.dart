import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz_config.dart';
import '../providers/quiz_provider.dart';
import 'result_page.dart';

/// Page du quiz avec les questions
class QuizPage extends ConsumerWidget {
  final QuizConfig config;

  const QuizPage({super.key, required this.config});

  Color _getTimerColor(int timeRemaining) {
    if (timeRemaining > 10) return Colors.green;
    if (timeRemaining > 5) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quizProvider);
    final notifier = ref.read(quizProvider.notifier);

    final finished = state.index >= state.questions.length - 1 && state.showFeedback;
    final q = state.questions[state.index];
    final progress = (state.index + 1) / state.questions.length;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE3F2FD),
              Color(0xFFFFF3E0),
              Color(0xFFF3E5F5),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // En-tête avec progression et timer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '🎯 Question ${state.index + 1}/${state.questions.length}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A148C),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _getTimerColor(state.timeRemaining),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: _getTimerColor(state.timeRemaining).withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  state.timeRemaining <= 5 ? Icons.timer : Icons.access_time,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${state.timeRemaining}s',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Barre de progression colorée
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.grey[200],
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Question principale avec design attractif
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.blue[50]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.blue[200]!, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text('🎪', style: TextStyle(fontSize: 40)),
                      const SizedBox(height: 12),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(fontSize: 24, color: Colors.black),
                          children: [
                            const TextSpan(
                              text: 'Conjugue le verbe ',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            TextSpan(
                              text: q.verb.infinitive,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE91E63),
                              ),
                            ),
                            const TextSpan(
                              text: ' avec ',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            TextSpan(
                              text: q.subject,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF673AB7),
                              ),
                            ),
                            const TextSpan(
                              text: ' au présent',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),

                      if (state.showFeedback) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: state.lastCorrect ? Colors.green[100] : Colors.red[100],
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: state.lastCorrect ? Colors.green : Colors.red,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                state.lastCorrect ? '🌟' : '😅',
                                style: const TextStyle(fontSize: 28),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  state.lastCorrect
                                      ? 'Fantastique ! Tu es un champion !'
                                      : 'Presque ! C\'était « ${q.correct} »',
                                  style: TextStyle(
                                    color: state.lastCorrect ? Colors.green[800] : Colors.red[800],
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Options de réponse avec design ludique (3 boutons)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: q.options.asMap().entries.map((e) {
                      final idx = e.key;
                      final opt = e.value;
                      final isCorrect = opt == q.correct;
                      final colors = [
                        [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)], // Rouge-orange
                        [const Color(0xFF4ECDC4), const Color(0xFF44A08D)], // Bleu-vert
                        [const Color(0xFFFFE66D), const Color(0xFFFF9A8B)], // Jaune-rose
                      ];
                      final colorPair = colors[idx % colors.length];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: KeyedSubtree(
                          key: ValueKey('q${q.id}-opt$idx-${opt.hashCode}'),
                          child: GestureDetector(
                            onTap: state.showFeedback ? null : () => notifier.answer(opt),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                gradient: state.showFeedback
                                    ? LinearGradient(
                                        colors: isCorrect
                                            ? [Colors.green, Colors.green[400]!]
                                            : [Colors.grey[400]!, Colors.grey[500]!],
                                      )
                                    : LinearGradient(colors: colorPair),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: (state.showFeedback
                                            ? (isCorrect ? Colors.green : Colors.grey)
                                            : colorPair[0])
                                        .withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (state.showFeedback && isCorrect)
                                      const Text('✨ ', style: TextStyle(fontSize: 24)),
                                    Text(
                                      opt,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // Bouton suivant avec design spectaculaire
                if (state.showFeedback)
                  GestureDetector(
                    onTap: () {
                      if (finished) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => ResultPage(
                              score: state.score,
                              total: state.questions.length,
                              config: config,
                            ),
                          ),
                        );
                      } else {
                        notifier.next();
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: finished
                            ? const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFF8C00)])
                            : const LinearGradient(
                                colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)]),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: (finished ? Colors.orange : Colors.green).withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            finished ? '🏆' : '🚀',
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            finished ? 'Découvrir mon score !' : 'Question suivante !',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



