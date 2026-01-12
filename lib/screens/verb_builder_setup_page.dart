import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/verb_builder_repository.dart';
import '../models/verb_builder.dart';
import '../models/verb_builder_config.dart';
import 'verb_builder_page.dart';

/// Page de configuration du Bâtisseur de Verbes
class VerbBuilderSetupPage extends ConsumerStatefulWidget {
  const VerbBuilderSetupPage({super.key});

  @override
  ConsumerState<VerbBuilderSetupPage> createState() =>
      _VerbBuilderSetupPageState();
}

class _VerbBuilderSetupPageState extends ConsumerState<VerbBuilderSetupPage> {
  List<VerbBuilder> _allVerbs = [];
  Set<String> _selectedVerbs = {};
  GameMode _selectedMode = GameMode.simple;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVerbs();
  }

  Future<void> _loadVerbs() async {
    setState(() => _isLoading = true);

    try {
      final verbs = await VerbBuilderRepository.loadVerbs();
      setState(() {
        _allVerbs = verbs;
        // Sélectionner tous les verbes par défaut
        _selectedVerbs = verbs.map((v) => v.infinitif).toSet();
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erreur: $e');
      setState(() => _isLoading = false);
    }
  }

  void _startGame() {
    if (_selectedVerbs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sélectionne au moins un verbe !'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final config = VerbBuilderConfig(
      mode: _selectedMode,
      selectedVerbs: _selectedVerbs,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerbBuilderPage(config: config),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bâtisseur de Verbes'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sélection du mode
                  _buildModeSelection(),
                  const SizedBox(height: 30),

                  // Boutons de sélection rapide
                  _buildQuickSelection(),
                  const SizedBox(height: 20),

                  // Liste des verbes
                  _buildVerbsList(),
                  const SizedBox(height: 20),

                  // Bouton démarrer
                  _buildStartButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildModeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mode de jeu',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...GameMode.values.map((mode) {
          return RadioListTile<GameMode>(
            value: mode,
            groupValue: _selectedMode,
            onChanged: (value) {
              setState(() => _selectedMode = value!);
            },
            title: Text('${mode.emoji} ${mode.displayName}'),
            subtitle: Text(mode.description),
            activeColor: Colors.orange,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildQuickSelection() {
    final groupe1Count = _allVerbs.where((v) => v.groupe == '1').length;
    final groupe2Count = _allVerbs.where((v) => v.groupe == '2').length;
    final groupe3Count = _allVerbs.where((v) => v.groupe == '3').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sélection rapide',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedVerbs = _allVerbs.map((v) => v.infinitif).toSet();
                });
              },
              child: Text('Tous'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedVerbs = _allVerbs
                      .where((v) => v.groupe == '1')
                      .map((v) => v.infinitif)
                      .toSet();
                });
              },
              child: Text('🌈 Groupe 1 ($groupe1Count)'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedVerbs = _allVerbs
                      .where((v) => v.groupe == '2')
                      .map((v) => v.infinitif)
                      .toSet();
                });
              },
              child: Text('🌟 Groupe 2 ($groupe2Count)'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedVerbs = _allVerbs
                      .where((v) => v.groupe == '3')
                      .map((v) => v.infinitif)
                      .toSet();
                });
              },
              child: Text('🏆 Groupe 3 ($groupe3Count)'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _selectedVerbs.clear());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade100,
              ),
              child: const Text('Effacer'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVerbsList() {
    // Si tous les verbes sont sélectionnés, afficher un message simplifié
    final allSelected = _allVerbs.isNotEmpty &&
        _selectedVerbs.length == _allVerbs.length &&
        _allVerbs.every((v) => _selectedVerbs.contains(v.infinitif));

    if (allSelected) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verbes sélectionnés: Tous (${_allVerbs.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tous les verbes sont sélectionnés',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Sinon, afficher la liste complète par groupe
    final groupe1 = _allVerbs.where((v) => v.groupe == '1').toList();
    final groupe2 = _allVerbs.where((v) => v.groupe == '2').toList();
    final groupe3 = _allVerbs.where((v) => v.groupe == '3').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verbes sélectionnés: ${_selectedVerbs.length}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildGroupSection('🌈 Groupe 1', groupe1),
        _buildGroupSection('🌟 Groupe 2', groupe2),
        _buildGroupSection('🏆 Groupe 3', groupe3),
      ],
    );
  }

  Widget _buildGroupSection(String title, List<VerbBuilder> verbs) {
    if (verbs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: verbs.map((verb) {
            final isSelected = _selectedVerbs.contains(verb.infinitif);
            return FilterChip(
              label: Text(verb.infinitif),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedVerbs.add(verb.infinitif);
                  } else {
                    _selectedVerbs.remove(verb.infinitif);
                  }
                });
              },
              selectedColor: Colors.orange.shade200,
            );
          }).toList(),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _startGame,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Démarrer (${_selectedVerbs.length} verbes)',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
