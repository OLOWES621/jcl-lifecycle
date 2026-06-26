# Schéma - Cycle de vie d'un programme COBOL sur z/OS

## Vue d'ensemble

```
┌─────────────────────────────────────────────────────────────────┐
│                    CYCLE DE VIE COMPLET                         │
└─────────────────────────────────────────────────────────────────┘

  ┌──────────────┐
  │ SOURCE COBOL │  ← OLFIE.SOURCE.COBOL(CALCSAL)
  │ (.cbl / PDS) │    Édité via ISPF / VS Code + Zowe
  └──────┬───────┘
         │
         ▼  STEP1 — PGM=IGYWCL
  ┌──────────────┐
  │ COMPILATION  │  → Détecte les erreurs de syntaxe
  │              │  → Produit le listing (SYSPRINT)
  │  RC=0        │  → Génère le module LOAD
  └──────┬───────┘
         │
         ▼  STEP2 — PGM=CALCSAL
  ┌──────────────┐
  │  EXÉCUTION   │  ← Lit DATA (entrée)
  │              │  → Écrit FICNET (sortie)
  │    RC=0      │  → DISPLAY → SYSOUT (spool)
  └──────────────┘
```

## Où lire les résultats en SDSF

| Commande SDSF | Ce qu'on y trouve                          |
|---------------|--------------------------------------------|
| `ST`          | Liste des jobs soumis et leurs RC globaux  |
| `LOG`         | Journal JES (messages système)             |
| `?` sur le job | Détail step par step                      |
| `SYSPRINT`    | Listing compilateur (erreurs/XREF/offsets) |
| `SYSOUT`      | Messages DISPLAY du programme              |
| `SYSUDUMP`    | Dump mémoire en cas d'ABEND                |
