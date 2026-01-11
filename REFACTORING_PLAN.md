# Plan de Refactoring - Structure Modulaire

## ✅ Fichiers Créés

1. ✅ `lib/models/verb.dart` - Modèle Verb
2. ✅ `lib/models/quiz_config.dart` - Configuration du quiz
3. ✅ `lib/models/quiz_question.dart` - Question de quiz
4. ✅ `lib/models/quiz_state.dart` - État du quiz
5. ✅ `lib/data/constants.dart` - Constantes
6. ✅ `lib/data/verbs_repository.dart` - Service de chargement JSON
7. ✅ `lib/providers/quiz_provider.dart` - Provider Riverpod

## 📋 Fichiers À Créer

### Screens
1. `lib/screens/quiz_page.dart` - Page du quiz (extraire du main.dart)
2. `lib/screens/result_page.dart` - Page des résultats (extraire du main.dart)
3. `lib/screens/home_page.dart` - **NOUVELLE** HomePage avec sélection individuelle de verbes

### Main
4. `lib/main.dart` - Point d'entrée uniquement (refactorisé)

## 📝 Notes

- HomePage doit être complètement réécrite pour:
  - Charger les verbes depuis JSON
  - Afficher les verbes groupés (Exception, 1er, 2ème, 3ème groupe)
  - Permettre sélection individuelle
  - Utiliser `selectedVerbs` au lieu de `selectedGroups`



