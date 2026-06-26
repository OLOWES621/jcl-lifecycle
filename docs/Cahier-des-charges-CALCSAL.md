- Auteur : [[Olfie OWAYE]]
- URL : https://github.com/olow-lab/jcl-lifecycle
- Date : 2026-06-26
---

Programme COBOL de **calcul du salaire net à partir du salaire brut**

## 1. Objectif

Ce cahier des charges décrit **le besoin et les règles métier** pour l'écriture un programme COBOL batch qui lit une liste de salariés avec leur salaire
brut mensuel, calcule le salaire net après cotisations sociales, et produit un
rapport lisible.

## 2. Entrée (fichier des salaires bruts)

Un fichier séquentiel, un enregistrement par salarié, longueur fixe.

| Donnée       | Description                                | Longueur      | Type                              |
| ------------ | ------------------------------------------ | ------------- | --------------------------------- |
| Matricule    | Identifiant unique du salarié              | 8 caractères  | Alphanumérique                    |
| Nom          | Nom de famille                             | 20 caractères | Alphanumérique                    |
| Prénom       | Prénom                                     | 15 caractères | Alphanumérique                    |
| Salaire brut | Salaire mensuel brut, en euros et centimes | 8 chiffres    | Numérique, 2 décimales implicites |

## 3. Règles de calcul (cotisations salariales)

Le salaire net se calcule en retranchant 4 cotisations du salaire brut :

| Cotisation | Taux | Base de calcul |
|---|---|---|
| Sécurité sociale | 7,0 % | Salaire brut |
| Retraite complémentaire | 6,9 % | Salaire brut |
| Assurance chômage | 2,4 % | Salaire brut |
| Prévoyance | 1,5 % | Salaire brut |

**Formule :**
```
Total cotisations = (Brut × 7,0%) + (Brut × 6,9%) + (Brut × 2,4%) + (Brut × 1,5%)
Salaire net = Salaire brut − Total cotisations
```


## 4. Sortie (rapport des salaires nets)

Un fichier séquentiel en sortie, contenant :
1. **Une ligne d'en-tête** avec les noms de colonnes
2. **Une ligne de séparation** (tirets ou équivalent)
3. **Une ligne de détail par salarié**, contenant : matricule, nom, prénom,
   salaire brut, total cotisations, salaire net
4. **Une ligne de séparation**
5. **Une ligne de totaux** : somme des salaires bruts, somme des salaires nets

Un fichier séquentiel, un enregistrement par salarié, longueur fixe.

| Donnée                  | Description                                   | Longueur           | Type                              |
| ----------------------- | --------------------------------------------- | ------------------ | --------------------------------- |
| **Entete**              | **ligne d'en-tête avec les noms de colonnes** | **132 caractères** | **Alphanumérique**                |
| **Ligne de séparation** | **tirets ou équivalent**                      | **132 caractères** | **Alphanumérique**                |
| Matricule               | Identifiant unique du salarié                 | 8 caractères       | Alphanumérique                    |
| Nom                     | Nom de famille                                | 20 caractères      | Alphanumérique                    |
| Prénom                  | Prénom                                        | 15 caractères      | Alphanumérique                    |
| Salaire brut            | Salaire mensuel brut, en euros et centimes    | 8 chiffres         | Numérique, 2 décimales implicites |
| Total cotisations       | Total cotisations salariales de l'employé     | 5 chiffres         | Numérique, 2 décimales implicites |
| Salaire net             | Salaire mensuel net, en euros et centimes     | 8 chiffres         | Numérique, 2 décimales implicites |

Longueur totale d'un enregistrement : 132 caractères minimum.

### Format d'affichage attendu

Les montants doivent être lisibles pour un humain : pas de zéros non
significatifs, séparateur des milliers si possible, virgule pour les centimes.

```
Exemple de ligne attendue :
MAT00001  DUPONT       JEAN         2 800,00      504,00    2 296,00
```


## 5. Comportement attendu du programme

- Le programme doit lire le fichier d'entrée **jusqu'à la fin** (gestion de fin
  de fichier obligatoire).
- Chaque enregistrement lu doit produire **une ligne de détail** dans le rapport.
- Les totaux (brut et net) doivent être **cumulés au fur et à mesure** de la
  lecture, puis affichés une seule fois à la fin.
- Le programme doit gérer le cas où le fichier d'entrée est **vide** (le rapport
  ne doit alors contenir que l'en-tête et des totaux à zéro, sans planter).

## 6. Traces et contrôle d'exécution

Le programme doit afficher en console (SYSOUT) un petit bilan d'exécution :

- Nombre d'enregistrements lus
- Nombre de lignes écrites dans le rapport
- Total du brut traité
- Total du net calculé

## 7. Gestion des anomalies

- Si le fichier d'entrée ne peut pas être ouvert correctement, le programme
  doit s'arrêter proprement avec un message d'erreur explicite et un code
  retour différent de zéro.
- Idem pour le fichier de sortie.