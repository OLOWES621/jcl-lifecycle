# jcl-lifecycle : Cycle de vie d'un programme COBOL sur z/OS

> **Projet pédagogique** : Illustre les 3 étapes fondamentales du cycle de vie
> d'un programme COBOL sur mainframe z/OS : compilation (module objet + link-edit), exécution.

---

## Contexte

Quand on commence sur mainframe, on apprend à écrire du COBOL.
Mais comprendre **comment un programme devient exécutable** et comment le lancer
correctement est une autre étape car il faut se frotter au JCL.

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
│   └── CALCSALJ.jcl         # JCL tout-en-un (compilation et exécution du programme)
│
├── io/
│   ├── DATA.txt  # Exemple de fichier d'entrée
│   └── FICNET.txt   # Rapport de sortie attendu 
│
└── docs/
    └── schema-cycle-vie.md  # Schéma du cycle de vie commenté
```

---

## Le programme CALCSAL

**CALCSAL** lit un fichier de salaires bruts et produit un rapport de salaires nets
après application des cotisations salariales.

| Paramètre     | Valeur                            |
|---------------|-----------------------------------|
| Langage       | COBOL                             |
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

### Étape 1 — Compilation (`CALCSALJ.jcl`)

IBM propose une procédure appelée **IGYWCL** qui permet de réaliser l'ensemble du processus de compilation en un seul JCL. C'est-à-dire la création du module objet puis le link-edit en un seul JCL.

```jcl
//COBRUN  EXEC IGYWCL
//COBOL.SYSIN  DD DSN=&SYSUID..CBL(CALCSAL),DISP=SHR
//LKED.SYSLMOD DD DSN=&SYSUID..LOAD(CALCSAL),DISP=SHR
```

> **Code retour attendu obligatoire :** RC=0 (OK)

---

### Étape 2 — Exécution (`CALCSALJ.jcl`)

Le programme est lancé en **batch**. Le JCL définit les fichiers d'entrée/sortie
et pointe vers la load library qui contient le module produit au step 1.

```jcl
//RUN     EXEC PGM=CALCSAL
//STEPLIB   DD DSN=&SYSUID..LOAD,DISP=SHR
//SYSOUT    DD SYSOUT=*,OUTLIM=15000
//CEEDUMP   DD DUMMY
//SYSUDUMP  DD DUMMY
//SALBRUT  DD DSN=&SYSUID..DATA,
//             DISP=SHR,
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=6160)
//SALNET    DD DSN=&SYSUID..FICNET,
//             DISP=(NEW,CATLG,DELETE),
//             SPACE=(TRK,(1,1),RLSE),
//             DCB=(RECFM=FB,LRECL=132,BLKSIZE=10164)
```

---

## Les utilitaires utilisés

| Utilitaire | Rôle dans ce projet |
|------------|---------------------|
| `IGYWCL  ` | Compilateur et Linkage editor COBOL. Produit le load module |
| `IDCAMS`   | Suppression du fichier de sortie FICNET |

---

## Comment lire les résultats (SDSF)

Après soumission (`SUB` en ISPF), consulter le spool via **SDSF** :

- `ST` → liste des jobs soumis
- Sélectionner le job → `?` pour détailler les steps
- Vérifier les **codes retour** de chaque step
- `SYSPRINT` du STEP1 → listing de compilation (erreurs/warnings)
- `SYSOUT` du STEP2 → messages DISPLAY du programme

### Codes retour de référence

| RC   | Signification |
|------|---------------|
| 0    | OK > pas d'anomalie |
| 4    | Warning > à analyser mais non bloquant |
| 8    | Erreur > step en anomalie |
| 12   | Erreur grave > arrêt recommandé |
| 16   | Erreur critique |

---

## Auteur

**Olfie OWAYE** — Analyste Développeur Mainframe Freelance
8 ans d'expérience · COBOL · JCL · DB2 · z/OS · CICS

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Olfie-0077B5?logo=linkedin)](https://www.linkedin.com/in/owayec/)

---

*Ce projet fait partie d'une série de dépôts pédagogiques sur le développement mainframe en français.*
*→ Voir la série complète sur mon profil GitHub.*
