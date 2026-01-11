import 'package:flutter/material.dart';
import '../models/quiz_config.dart';
import 'home_page.dart';

/// Page affichant les résultats du quiz
class ResultPage extends StatelessWidget {
  final int score;
  final int total;
  final QuizConfig config;

  const ResultPage({
    super.key,
    required this.score,
    required this.total,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final errors = total - score;
    final percentage = ((score / total) * 100).round();

    // Messages motivants selon le score
    String getMessage() {
      if (percentage >= 90) return "Excellent ! 🌟";
      if (percentage >= 80) return "Très bien ! 👏";
      if (percentage >= 70) return "Bien joué ! 👍";
      if (percentage >= 60) return "Pas mal ! 😊";
      return "Continue tes efforts ! 💪";
    }

    Color getScoreColor() {
      if (percentage >= 80) return Colors.green;
      if (percentage >= 60) return Colors.orange;
      return Colors.red;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat 🎉'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        getMessage(),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),

                      // Score circulaire
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: getScoreColor().withOpacity(0.1),
                          border: Border.all(color: getScoreColor(), width: 4),
                        ),
                        child: Center(
                          child: Text(
                            '$percentage%',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: getScoreColor(),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Détails du score
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green, size: 32),
                              const SizedBox(height: 4),
                              Text(
                                '$score',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const Text('Bonnes', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                          Column(
                            children: [
                              const Icon(Icons.cancel, color: Colors.red, size: 32),
                              const SizedBox(height: 4),
                              Text(
                                '$errors',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const Text('Erreurs', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Boutons d'action
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text(
                      'Rejouer avec les mêmes paramètres 🔄',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => HomePage(previousConfig: config)),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.settings),
                    label: const Text(
                      'Nouveau quiz avec d\'autres paramètres ⚙️',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const HomePage()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}



