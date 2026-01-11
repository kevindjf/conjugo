import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/verb.dart';
import '../models/quiz_config.dart';
import '../data/constants.dart';
import '../data/verbs_repository.dart';
import '../providers/quiz_provider.dart';
import 'quiz_page.dart';

/// Page d'accueil avec sélection individuelle de verbes
class HomePage extends StatefulWidget {
  final QuizConfig? previousConfig;

  const HomePage({super.key, this.previousConfig});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<Verb> allVerbs = [];
  Set<String> selectedVerbs = {}; // Infinitifs des verbes sélectionnés
  Map<String, List<Verb>> verbsByGroup = {};
  bool isLoading = true;
  int timeLimit = AppConstants.defaultTimeLimit;
  int numberQuestion = AppConstants.defaultQuestionCount;
  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;

  // Ordre d'affichage des groupes
  static const groupOrder = ['exception', '1', '2', '3'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.repeat(reverse: true);
    _loadVerbs();
  }

  Future<void> _loadVerbs() async {
    try {
      final verbs = await VerbsRepository.loadVerbs();
      setState(() {
        allVerbs = verbs;
        // Grouper les verbes
        verbsByGroup = {};
        for (final verb in verbs) {
          verbsByGroup.putIfAbsent(verb.groupTag, () => []).add(verb);
        }
        
        // Initialiser les sélections
        if (widget.previousConfig != null) {
          selectedVerbs = widget.previousConfig!.selectedVerbs;
          timeLimit = widget.previousConfig!.timeLimit;
          numberQuestion = widget.previousConfig!.numberQuestions;
        } else {
          // Par défaut, sélectionner quelques verbes du 1er groupe
          final firstGroupVerbs = verbsByGroup['1'] ?? [];
          if (firstGroupVerbs.isNotEmpty) {
            selectedVerbs = firstGroupVerbs
                .take(3)
                .map((v) => v.infinitive)
                .toSet();
          }
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleVerb(String infinitive) {
    setState(() {
      if (selectedVerbs.contains(infinitive)) {
        selectedVerbs.remove(infinitive);
      } else {
        selectedVerbs.add(infinitive);
      }
    });
  }

  void _toggleGroup(String groupTag) {
    final groupVerbs = verbsByGroup[groupTag] ?? [];
    final groupInfinitive = groupVerbs.map((v) => v.infinitive).toSet();
    final allSelected = groupInfinitive.every((v) => selectedVerbs.contains(v));

    setState(() {
      if (allSelected) {
        // Tout désélectionner
        selectedVerbs.removeAll(groupInfinitive);
      } else {
        // Tout sélectionner
        selectedVerbs.addAll(groupInfinitive);
      }
    });
  }

  void _startQuiz() {
    if (selectedVerbs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionne au moins un verbe !')),
      );
      return;
    }

    final selectedVerbsList = allVerbs
        .where((v) => selectedVerbs.contains(v.infinitive))
        .toList();

    if (selectedVerbsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun verbe sélectionné valide !')),
      );
      return;
    }

    final config = QuizConfig(
      selectedVerbs: selectedVerbs,
      timeLimit: timeLimit,
      numberQuestions: numberQuestion,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ProviderScope(
          overrides: [
            quizProvider.overrideWith(
              (ref) => QuizNotifier(selectedVerbsList, timeLimit, numberQuestion),
            ),
          ],
          child: QuizPage(config: config),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFE0B2),
                Color(0xFFFFF8E1),
                Color(0xFFE8F5E8),
              ],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFE0B2),
              Color(0xFFFFF8E1),
              Color(0xFFE8F5E8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Titre animé
                AnimatedBuilder(
                  animation: _bounceAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _bounceAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              '🎪 CONJUGO 🎪',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                foreground: Paint()
                                  ..shader = const LinearGradient(
                                    colors: [Colors.orange, Colors.pink, Colors.purple],
                                  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                              ),
                            ),
                            const Text(
                              'L\'aventure des verbes !',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // Sélection des verbes par groupe
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🎯', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 8),
                          const Text(
                            'Choisis tes verbes !',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...groupOrder.map((groupTag) {
                        final groupVerbs = verbsByGroup[groupTag] ?? [];
                        if (groupVerbs.isEmpty) return const SizedBox.shrink();

                        final meta = AppConstants.groupMetadata[groupTag]!;
                        final groupColor = Color(meta['color'] as int);
                        final groupName = meta['name'] as String;
                        final emoji = meta['emoji'] as String;

                        final groupInfinitive =
                            groupVerbs.map((v) => v.infinitive).toSet();
                        final allSelected =
                            groupInfinitive.every((v) => selectedVerbs.contains(v));
                        final someSelected = groupInfinitive
                            .any((v) => selectedVerbs.contains(v));

                        return Column(
                          children: [
                            // En-tête du groupe
                            GestureDetector(
                              onTap: () => _toggleGroup(groupTag),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: allSelected
                                      ? groupColor.withOpacity(0.2)
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: allSelected ? groupColor : Colors.grey[300]!,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(emoji, style: const TextStyle(fontSize: 24)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            groupName,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: allSelected ? groupColor : Colors.grey[800],
                                            ),
                                          ),
                                          Text(
                                            meta['description'] as String,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      allSelected
                                          ? Icons.check_box
                                          : someSelected
                                              ? Icons.indeterminate_check_box
                                              : Icons.check_box_outline_blank,
                                      color: allSelected ? groupColor : Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Liste des verbes du groupe
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: groupVerbs.map((verb) {
                                final isSelected =
                                    selectedVerbs.contains(verb.infinitive);
                                return GestureDetector(
                                  onTap: () => _toggleVerb(verb.infinitive),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected ? groupColor : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? groupColor
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Text(
                                      verb.infinitive,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.grey[700],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Paramètres
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('⚙️', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 8),
                          const Text(
                            'Règle ton défi !',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Temps de réponse
                      _buildParameterCard(
                        icon: '⏰',
                        title: 'Temps de réponse',
                        value: '$timeLimit secondes',
                        color: Colors.blue,
                        child: Wrap(
                          spacing: 8,
                          children: AppConstants.timeLimits.map((time) {
                            final isSelected = timeLimit == time;
                            return GestureDetector(
                              onTap: () => setState(() => timeLimit = time),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.blue : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${time}s',
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.grey[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Nombre de questions
                      _buildParameterCard(
                        icon: '🎯',
                        title: 'Nombre de questions',
                        value: '$numberQuestion questions',
                        color: Colors.green,
                        child: Wrap(
                          spacing: 8,
                          children: AppConstants.questionCounts.map((num) {
                            final isSelected = numberQuestion == num;
                            return GestureDetector(
                              onTap: () => setState(() => numberQuestion = num),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.green : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$num',
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.grey[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Bouton de démarrage
                GestureDetector(
                  onTap: _startQuiz,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.rocket_launch, color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          widget.previousConfig != null
                              ? 'C\'est parti pour un nouveau tour ! 🚀'
                              : 'Commencer l\'aventure ! 🚀',
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

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParameterCard({
    required String icon,
    required String title,
    required String value,
    required Color color,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

