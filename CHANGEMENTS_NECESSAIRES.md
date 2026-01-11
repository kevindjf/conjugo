# Changements Nécessaires pour la Sélection Individuelle de Verbes

## ✅ Déjà Fait

1. ✅ JSON créé avec format correct et verbes fréquents (60+ verbes)
2. ✅ Service `VerbsRepository` créé pour charger le JSON
3. ✅ `QuizConfig` modifié pour utiliser `selectedVerbs` au lieu de `selectedGroups`

## ❌ À Faire

### 1. HomePage - Chargement des verbes
- Charger les verbes depuis JSON dans `initState`
- Stocker les verbes dans une variable d'état
- Grouper les verbes par groupe (1, 2, 3, exception)

### 2. HomePage - Nouvelle Interface de Sélection
- Remplacer la sélection par groupes par une sélection par verbes individuels
- Afficher les verbes groupés par catégorie avec des sections dépliables ou scrollables
- Permettre la sélection/désélection individuelle de chaque verbe
- Utiliser `Set<String>` pour stocker les infinitifs sélectionnés

### 3. HomePage - Méthode `_startQuiz`
- Utiliser `selectedVerbs` au lieu de `selectedGroups`
- Filtrer les verbes chargés selon les sélections

### 4. ResultPage
- Adapter pour utiliser `selectedVerbs` dans `previousConfig`

### 5. quizProvider
- Adapter le provider par défaut pour utiliser les verbes chargés

## Structure Recommandée pour HomePage

```dart
class _HomePageState extends State<HomePage> {
  List<Verb> allVerbs = [];
  Set<String> selectedVerbs = {}; // Infinitifs sélectionnés
  bool isLoading = true;
  
  // Groupes de verbes
  Map<String, List<Verb>> verbsByGroup = {
    'exception': [],
    '1': [],
    '2': [],
    '3': [],
  };
  
  // Métadonnées des groupes
  final groupMeta = {
    'exception': {'emoji': '🎪', 'color': Colors.orange, 'name': 'Exceptions'},
    '1': {'emoji': '🌈', 'color': Colors.pink, 'name': '1er groupe'},
    '2': {'emoji': '🌟', 'color': Colors.blue, 'name': '2ème groupe'},
    '3': {'emoji': '🏆', 'color': Colors.purple, 'name': '3ème groupe'},
  };
}
```

## Prochaines Étapes

Je vais maintenant implémenter ces changements dans le code.



