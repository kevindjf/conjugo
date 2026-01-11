#!/usr/bin/env python3
"""
Script pour générer le fichier verbs_builder.json avec radicaux et terminaisons
à partir du fichier verbs.json existant.
"""

import json
import os
from typing import Dict, List, Tuple


def find_common_prefix(words: List[str]) -> str:
    """Trouve le préfixe commun le plus long dans une liste de mots."""
    if not words:
        return ""

    prefix = words[0]
    for word in words[1:]:
        while not word.startswith(prefix) and prefix:
            prefix = prefix[:-1]
    return prefix


def smart_split(conjugation: str, infinitif: str, groupe: str, subject: str) -> Tuple[str, str]:
    """
    Découpe intelligemment une conjugaison en radical + terminaison.

    Returns:
        Tuple[radical, terminaison]
    """
    if not conjugation:
        return "", ""

    # Groupe 1 : Verbes en -er
    if groupe == "1":
        # Retirer le "er" de l'infinitif pour avoir le radical de base
        base_radical = infinitif[:-2] if infinitif.endswith("er") else infinitif

        # Terminaisons standard du 1er groupe au présent
        terminaisons_standards = {
            "je": "e",
            "tu": "es",
            "il/elle": "e",
            "nous": "ons",
            "vous": "ez",
            "ils/elles": "ent"
        }

        # Cas spéciaux : verbes en -ger (mangeons), -cer (commençons)
        if subject == "nous":
            if infinitif.endswith("ger") and conjugation.endswith("geons"):
                return conjugation[:-4], "eons"  # mang + eons
            elif infinitif.endswith("cer") and conjugation.endswith("çons"):
                return conjugation[:-4], "ons"   # commenç + ons

        # Essayer la terminaison standard
        expected_terminaison = terminaisons_standards.get(subject, "")
        if conjugation.endswith(expected_terminaison):
            radical = conjugation[:-len(expected_terminaison)] if expected_terminaison else conjugation
            return radical, expected_terminaison

        # Fallback : découpage à partir du radical de base
        if conjugation.startswith(base_radical):
            return base_radical, conjugation[len(base_radical):]

    # Groupe 2 : Verbes en -ir avec -iss-
    elif groupe == "2":
        # Terminaisons du 2e groupe
        terminaisons_courtes = {"je": "s", "tu": "s", "il/elle": "t"}
        terminaisons_longues = {"nous": "ons", "vous": "ez", "ils/elles": "ent"}

        if subject in terminaisons_courtes:
            # je finis, tu finis, il finit -> fini + s/s/t
            terminaison = terminaisons_courtes[subject]
            if conjugation.endswith(terminaison):
                return conjugation[:-len(terminaison)], terminaison

        elif subject in terminaisons_longues:
            # nous finissons -> finiss + ons
            terminaison = terminaisons_longues[subject]
            if conjugation.endswith(terminaison):
                radical = conjugation[:-len(terminaison)]
                return radical, terminaison

    # Groupe 3 : Analyse générique
    elif groupe == "3":
        # Terminaisons possibles du 3e groupe
        terminaisons_possibles = {
            "je": ["s", "x", "e", ""],
            "tu": ["s", "x", "es"],
            "il/elle": ["t", "d", "e", ""],
            "nous": ["ons"],
            "vous": ["ez", "tes"],
            "ils/elles": ["ent", "ont"]
        }

        for terminaison in terminaisons_possibles.get(subject, [""]):
            if terminaison == "":
                # Cas sans terminaison (ex: il prend)
                return conjugation, ""
            elif conjugation.endswith(terminaison):
                radical = conjugation[:-len(terminaison)]
                # Vérifier que le radical n'est pas vide
                if radical:
                    return radical, terminaison

    # Fallback : découpage à 2/3 de la longueur
    if len(conjugation) >= 3:
        split_point = max(1, len(conjugation) - 2)
        return conjugation[:split_point], conjugation[split_point:]

    return conjugation, ""


def generate_verb_builder_data(input_file: str, output_file: str):
    """Génère le fichier JSON avec radicaux et terminaisons."""

    # Charger le fichier JSON existant
    with open(input_file, 'r', encoding='utf-8') as f:
        verbs = json.load(f)

    # Filtrer les exceptions
    exceptions = {"être", "avoir", "aller", "faire"}
    verbs_filtered = [v for v in verbs if v["infinitif"] not in exceptions]

    print(f"📚 Total de verbes: {len(verbs)}")
    print(f"❌ Exceptions exclues: {len(verbs) - len(verbs_filtered)}")
    print(f"✅ Verbes à traiter: {len(verbs_filtered)}")

    # Créer le nouveau format
    verbs_builder = []

    for verb in verbs_filtered:
        infinitif = verb["infinitif"]
        groupe = verb["groupe"]
        present = verb["present"]

        # Créer le nouveau format avec radicaux/terminaisons
        new_verb = {
            "infinitif": infinitif,
            "groupe": groupe,
            "present": {}
        }

        for subject, conjugation in present.items():
            radical, terminaison = smart_split(conjugation, infinitif, groupe, subject)

            new_verb["present"][subject] = {
                "complet": conjugation,
                "radical": radical,
                "terminaison": terminaison
            }

        verbs_builder.append(new_verb)

        # Afficher les premiers exemples
        if len(verbs_builder) <= 3:
            print(f"\n📝 {infinitif} (groupe {groupe}):")
            for subj in ["je", "nous"]:
                data = new_verb["present"][subj]
                print(f"   {subj}: {data['complet']} = [{data['radical']}] + [{data['terminaison']}]")

    # Sauvegarder le nouveau fichier
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(verbs_builder, f, ensure_ascii=False, indent=2)

    print(f"\n✅ Fichier généré: {output_file}")
    print(f"   {len(verbs_builder)} verbes avec radicaux/terminaisons")


if __name__ == "__main__":
    # Chemins des fichiers
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    assets_dir = os.path.join(project_root, "assets", "data")

    input_file = os.path.join(assets_dir, "verbs.json")
    output_file = os.path.join(assets_dir, "verbs_builder.json")

    # Générer le fichier
    generate_verb_builder_data(input_file, output_file)
