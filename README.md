# jcl-lifecycle — Cycle de vie d'un programme COBOL sur z/OS

> **Projet pédagogique** — Illustre les 3 étapes fondamentales du cycle de vie
> d'un programme COBOL sur mainframe z/OS : compilation, link-edit, exécution.

---

## Contexte

Quand on commence sur mainframe, on apprend à écrire du COBOL.
Mais comprendre **comment un programme devient exécutable** — et comment le lancer
correctement — c'est une autre étape, souvent mal documentée en français.

Ce projet répond à une question simple :

> _"J'ai écrit mon programme COBOL. Et maintenant ?"_

---

## Ce que contient ce dépôt

```
jcl-lifecycle/
│
├── src/
│   └── CALCSAL.cbl          # Programme COBOL — calcul de salaire net
│
├── jcl/
│   ├── COMPIL.jcl           # Étape 1 : compilation COBOL (IGYCRCTL)
│   ├── LINKEDIT.jcl         # Étape 2 : link-edit (IEWL)
│   ├── EXEC.jcl             # Étape 3 : exécution du programme
│   └── CICLEVIE.jcl         # JCL tout-en-un (dev / tests rapides)
│
├── output/
│   ├── SALBRUT.exemple.txt  # Exemple de fichier d'entrée
│   └── SALNET.exemple.txt   # Exemple de rapport de sortie attendu
│
└── docs/
    └── schema-cycle-vie.md  # Schéma du cycle de vie commenté
```

---

## Le programme — CALCSAL

**CALCSAL** lit un fichier de salaires bruts et produit un rapport de salaires nets
après application des cotisations salariales.

| Paramètre     | Valeur                            |
|---------------|-----------------------------------|
| Langage       | IBM Enterprise COBOL for z/OS     |
| Entrée        | Fichier séquentiel FB, LRECL=80   |
| Sortie        | Rapport FB, LRECL=132             |
| Taux appliqués | Sécu 7% · Retraite 6,9% · Chômage 2,4% · Prévoyance 1,5% |

### Structure du fichier d'entrée (LRECL=80)

```
Pos 01-08  : Matricule     PIC X(08)
Pos 09-28  : Nom           PIC X(20)
Pos 29-43  : Prénom        PIC X(15)
Pos 44-51  : Salaire brut  PIC 9(06)V99  (ex: 00280000 = 2800,00 €)
Pos 52-80  : Filler
```

---

## Les 3 étapes du cycle de vie

### Étape 1 — Compilation (`COMPIL.jcl`)

Le compilateur **IGYCRCTL** transforme le source COBOL en **module objet**.
C'est ici qu'on détecte les erreurs de syntaxe et les warnings.

```jcl
//STEP1    EXEC PGM=IGYCRCTL,
//             PARM='LIB,SOURCE,XREF,OFFSET,RENT'
//SYSIN    DD  DSN=OLFIE.SOURCE.COBOL(CALCSAL),DISP=SHR
//SYSLIN   DD  DSN=OLFIE.OBJ.LOAD(CALCSAL),DISP=(NEW,CATLG,DELETE),...
//SYSPRINT DD  SYSOUT=*
```

> **Codes retour attendus :** RC=0 (OK) · RC=4 (warnings) · RC=8+ (erreurs bloquantes)

---

### Étape 2 — Link-Edit (`LINKEDIT.jcl`)

Le **linkage editor (IEWL)** transforme le module objet en **module de chargement**
exécutable. C'est à cette étape qu'on résout les références externes
(sous-programmes, bibliothèques runtime Language Environment).

```jcl
//STEP1    EXEC PGM=IEWL,PARM='RENT,LIST,XREF,LET'
//SYSLIN   DD  DSN=OLFIE.OBJ.LOAD(CALCSAL),DISP=SHR
//SYSLIB   DD  DSN=CEE.SCEELKED,DISP=SHR
//SYSLMOD  DD  DSN=OLFIE.LOAD.PGMLIB(CALCSAL),DISP=(NEW,CATLG,DELETE),...
```

> **Code retour attendu :** RC=0 obligatoire.

---

### Étape 3 — Exécution (`EXEC.jcl`)

Le programme est lancé en **batch**. Le JCL définit les fichiers d'entrée/sortie
et pointe vers la load library qui contient le module produit au step 2.

```jcl
//STEP2    EXEC PGM=CALCSAL,COND=(4,LT,STEP1)
//STEPLIB  DD  DSN=OLFIE.LOAD.PGMLIB,DISP=SHR
//SALBRUT  DD  DSN=OLFIE.DATA.SALBRUT,DISP=SHR
//SALNET   DD  DSN=OLFIE.DATA.SALNET,DISP=OLD
```

---

## Les utilitaires utilisés

| Utilitaire | Rôle dans ce projet |
|------------|---------------------|
| `IGYCRCTL` | Compilateur IBM Enterprise COBOL |
| `IEWL`     | Linkage editor — produit le load module |
| `IEFBR14`  | Allocation du fichier de sortie avant exécution |
| `IEBGENER` | Copie le rapport SALNET vers SYSOUT (visible en SDSF) |

---

## Comment lire les résultats — SDSF

Après soumission (`SUB` en ISPF), consulter le spool via **SDSF** :

- `ST` → liste des jobs soumis
- Sélectionner le job → `?` pour détailler les steps
- Vérifier les **codes retour** de chaque step
- `SYSPRINT` du STEP1 → listing de compilation (erreurs/warnings)
- `SYSPRINT` du STEP2 → map du link-edit
- `SYSOUT` du STEP4 → messages DISPLAY du programme
- `SYSUT2` du STEP5 → rapport final lisible

### Codes retour de référence

| RC   | Signification |
|------|---------------|
| 0    | OK — pas d'anomalie |
| 4    | Warning — à analyser mais non bloquant |
| 8    | Erreur — step en anomalie |
| 12   | Erreur grave — arrêt recommandé |
| 16   | Erreur critique |

---

## Tester sans environnement z/OS

Si vous n'avez pas accès à un mainframe :

- **IBM Z Xplore** — environnement z/OS gratuit fourni par IBM pour l'apprentissage
  → [https://ibmzxplore.influitive.com](https://ibmzxplore.influitive.com)
- **Hercules** — émulateur mainframe open source
  → [https://www.hercules-390.eu](https://www.hercules-390.eu)
- **VS Code + Zowe Explorer** — édition de membres COBOL/JCL depuis VS Code

---

## À adapter avant utilisation

Les datasets `OLFIE.*` sont des exemples à remplacer par vos propres noms :

| Placeholder              | À remplacer par                   |
|--------------------------|-----------------------------------|
| `OLFIE.SOURCE.COBOL`     | Votre PDS source COBOL            |
| `OLFIE.OBJ.LOAD`         | Votre PDS de modules objets       |
| `OLFIE.LOAD.PGMLIB`      | Votre load library                |
| `OLFIE.DATA.SALBRUT`     | Votre dataset d'entrée            |
| `OLFIE.DATA.SALNET`      | Votre dataset de sortie           |
| `IGY.V6R4M0.SIGYCOMP`   | Votre version du compilateur COBOL|
| `(ACCT)`                 | Votre code comptable JOB          |

---

## Auteur

**Olfie** — Analyste Développeur Mainframe Freelance
8 ans d'expérience · COBOL · JCL · DB2 · z/OS · CICS

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Olfie-0077B5?logo=linkedin)](https://linkedin.com/in/TON-PROFIL)

---

*Ce projet fait partie d'une série de dépôts pédagogiques sur le développement mainframe en français.*
*→ Voir la série complète sur mon profil GitHub.*
