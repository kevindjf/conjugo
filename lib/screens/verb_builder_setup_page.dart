import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    // Forcer le mode paysage
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _loadVerbs();
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
      backgroundColor: Color(0xFFC8E6C9), // Vert clair comme le bleu ciel
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.green),
            )
          : SafeArea(
              child: Column(
                children: [
                  // En-tête
                  _buildHeader(),

                  // Contenu principal en mode horizontal
                  Expanded(
                    child: Row(
                      children: [
                        // Colonne gauche : Mascotte + Info
                        Expanded(
                          flex: 2,
                          child: _buildLeftPanel(),
                        ),

                        // Colonne droite : Configuration
                        Expanded(
                          flex: 5,
                          child: _buildConfigPanel(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.green.shade700,
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
          // Bouton retour
          IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 24),
            onPressed: () => Navigator.pop(context),
          ),

          // Titre
          Text(
            'CONFIGURATION',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),

          // Verbes sélectionnés
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${_selectedVerbs.length} verbes',
              style: TextStyle(
                color: Colors.green.shade800,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPanel() {
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
          // Mascotte robot
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green.shade200, width: 3),
            ),
            child: Center(
              child: Text(
                '🤖',
                style: TextStyle(fontSize: 50),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Message
          Text(
            'Configure ton atelier !',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade900,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Choisis le mode de jeu et les verbes à pratiquer.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigPanel() {
    return Container(
      margin: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          // Section Mode de jeu
          Expanded(
            flex: 3,
            child: _buildModeSection(),
          ),

          const SizedBox(height: 4),

          // Section Sélection des verbes
          Expanded(
            flex: 4,
            child: _buildVerbsSection(),
          ),

          const SizedBox(height: 4),

          // Bouton démarrer
          _buildStartButton(),
        ],
      ),
    );
  }

  Widget _buildModeSection() {
    return Container(
      padding: const EdgeInsets.all(12.0),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.videogame_asset, color: Colors.green.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'MODE DE JEU',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              children: GameMode.values.map((mode) {
                final isSelected = _selectedMode == mode;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: InkWell(
                      onTap: () => setState(() => _selectedMode = mode),
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.green.shade100
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? Colors.green.shade700
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              mode.emoji,
                              style: TextStyle(fontSize: 24),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              mode.displayName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.green.shade900
                                    : Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              mode.description.split('\n').first,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerbsSection() {
    final groupe1Count = _allVerbs.where((v) => v.groupe == '1').length;
    final groupe2Count = _allVerbs.where((v) => v.groupe == '2').length;
    final groupe3Count = _allVerbs.where((v) => v.groupe == '3').length;

    final allSelected = _allVerbs.isNotEmpty &&
        _selectedVerbs.length == _allVerbs.length &&
        _allVerbs.every((v) => _selectedVerbs.contains(v.infinitif));

    return Container(
      padding: const EdgeInsets.all(12.0),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_stories, color: Colors.green.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'SÉLECTION DES VERBES',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Boutons de sélection rapide
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildQuickSelectButton(
                label: 'Tous (${_allVerbs.length})',
                icon: Icons.select_all,
                color: Colors.green,
                onPressed: () {
                  setState(() {
                    _selectedVerbs = _allVerbs.map((v) => v.infinitif).toSet();
                  });
                },
              ),
              _buildQuickSelectButton(
                label: 'Groupe 1 ($groupe1Count)',
                icon: Icons.looks_one,
                color: Colors.blue,
                onPressed: () {
                  setState(() {
                    _selectedVerbs = _allVerbs
                        .where((v) => v.groupe == '1')
                        .map((v) => v.infinitif)
                        .toSet();
                  });
                },
              ),
              _buildQuickSelectButton(
                label: 'Groupe 2 ($groupe2Count)',
                icon: Icons.looks_two,
                color: Colors.orange,
                onPressed: () {
                  setState(() {
                    _selectedVerbs = _allVerbs
                        .where((v) => v.groupe == '2')
                        .map((v) => v.infinitif)
                        .toSet();
                  });
                },
              ),
              _buildQuickSelectButton(
                label: 'Groupe 3 ($groupe3Count)',
                icon: Icons.looks_3,
                color: Colors.purple,
                onPressed: () {
                  setState(() {
                    _selectedVerbs = _allVerbs
                        .where((v) => v.groupe == '3')
                        .map((v) => v.infinitif)
                        .toSet();
                  });
                },
              ),
              _buildQuickSelectButton(
                label: 'Effacer',
                icon: Icons.clear,
                color: Colors.red,
                onPressed: () {
                  setState(() => _selectedVerbs.clear());
                },
              ),
            ],
          ),

          const SizedBox(height: 8),
          Divider(height: 1, color: Colors.grey.shade300),
          const SizedBox(height: 8),

          // Liste des verbes ou message "Tous"
          Expanded(
            child: allSelected
                ? Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.green.shade700, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'Tous les verbes sont sélectionnés (${_allVerbs.length})',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _buildVerbsGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSelectButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 28,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 14),
        label: Text(
          label,
          style: TextStyle(fontSize: 10),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.shade100,
          foregroundColor: color.shade900,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildVerbsGrid() {
    final groupe1 = _allVerbs.where((v) => v.groupe == '1').toList();
    final groupe2 = _allVerbs.where((v) => v.groupe == '2').toList();
    final groupe3 = _allVerbs.where((v) => v.groupe == '3').toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (groupe1.isNotEmpty) _buildGroupSection('Groupe 1', groupe1, Colors.blue),
          if (groupe2.isNotEmpty) _buildGroupSection('Groupe 2', groupe2, Colors.orange),
          if (groupe3.isNotEmpty) _buildGroupSection('Groupe 3', groupe3, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildGroupSection(String title, List<VerbBuilder> verbs, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color.shade700,
            ),
          ),
        ),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: verbs.map((verb) {
            final isSelected = _selectedVerbs.contains(verb.infinitif);
            return InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedVerbs.remove(verb.infinitif);
                  } else {
                    _selectedVerbs.add(verb.infinitif);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? color.shade100 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? color.shade400 : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Text(
                  verb.infinitif,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? color.shade900 : Colors.grey.shade700,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildStartButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _startGame,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow, size: 28),
              const SizedBox(width: 8),
              Text(
                'DÉMARRER (${_selectedVerbs.length} verbes)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
