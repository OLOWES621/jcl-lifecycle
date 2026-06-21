# Schéma — Cycle de vie d'un programme COBOL sur z/OS

## Vue d'ensemble

```
┌─────────────────────────────────────────────────────────────────┐
│                    CYCLE DE VIE COMPLET                         │
└─────────────────────────────────────────────────────────────────┘

  ┌──────────────┐
  │  SOURCE COBOL │  ← OLFIE.SOURCE.COBOL(CALCSAL)
  │  (.cbl / PDS) │    Édité via ISPF / VS Code + Zowe
  └──────┬───────┘
         │
         ▼  STEP1 — PGM=IGYCRCTL
  ┌──────────────┐
  │ COMPILATION  │  → Détecte les erreurs de syntaxe
  │              │  → Produit le listing (SYSPRINT)
  │  RC=0 ou 4  │  → Génère le module OBJET
  └──────┬───────┘
         │
         ▼  STEP2 — PGM=IEWL
  ┌──────────────┐
  │  LINK-EDIT   │  → Résout les références externes
  │              │  → Lie les sous-programmes
  │    RC=0      │  → Produit le LOAD MODULE
  └──────┬───────┘
         │
         ▼  STEP3 — PGM=IEFBR14
  ┌──────────────┐
  │  ALLOCATION  │  → Prépare les fichiers de sortie
  │  FICHIERS    │  → Via les DD statements
  │    RC=0      │
  └──────┬───────┘
         │
         ▼  STEP4 — PGM=CALCSAL
  ┌──────────────┐
  │  EXÉCUTION   │  ← Lit SALBRUT (entrée)
  │              │  → Écrit SALNET (sortie)
  │    RC=0      │  → DISPLAY → SYSOUT (spool)
  └──────┬───────┘
         │
         ▼  STEP5 — PGM=IEBGENER
  ┌──────────────┐
  │   RAPPORT    │  → Copie SALNET vers SYSOUT
  │   SPOOL      │  → Lisible directement en SDSF
  └──────────────┘
```

---

## La logique COND

La directive `COND` contrôle l'enchaînement des steps.
Elle empêche l'exécution d'un step si le précédent est en erreur.

```jcl
COND=(4,LT,STEP1)
```

Se lit : **"Sauter ce step si le RC de STEP1 est supérieur à 4"**

| Condition       | Signification                              |
|-----------------|--------------------------------------------|
| `(4,LT,STEPx)` | Sauter si RC > 4 (erreur bloquante)        |
| `(0,NE,STEPx)` | Sauter si RC ≠ 0 (strict)                 |
| `(0,EQ,STEPx)` | Sauter si RC = 0 (step de reprise erreur)  |

> **Bonne pratique :** toujours chaîner les COND pour éviter qu'un step
> s'exécute sur un état incohérent laissé par un step précédent en erreur.

---

## Les datasets temporaires (`&&`)

Dans `CICLEVIE.jcl`, on utilise un dataset temporaire `&&OBJ`
pour transmettre le module objet de STEP1 à STEP2 sans le persister :

```jcl
// STEP1 : produit &&OBJ
//SYSLIN   DD  DSN=&&OBJ,DISP=(NEW,PASS),...

// STEP2 : consomme &&OBJ et le supprime
//SYSLIN   DD  DSN=&&OBJ,DISP=(OLD,DELETE)
```

`DISP=(NEW,PASS)` → alloue et passe au step suivant
`DISP=(OLD,DELETE)` → utilise puis supprime à la fin du step

---

## Où lire les résultats en SDSF

| Commande SDSF | Ce qu'on y trouve                          |
|---------------|--------------------------------------------|
| `ST`          | Liste des jobs soumis et leurs RC globaux   |
| `LOG`         | Journal JES — messages système              |
| `?` sur le job | Détail step par step                      |
| `SYSPRINT`    | Listing compilateur (erreurs/XREF/offsets)  |
| `SYSOUT`      | Messages DISPLAY du programme               |
| `SYSUDUMP`    | Dump mémoire en cas d'ABEND                 |
