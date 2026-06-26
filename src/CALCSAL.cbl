      *================================================================*
      * PROGRAMME  : CALCSAL                                           *
      * DESCRIPTION: Calcul du salaire net a partir du brut            *
      *              Applique les cotisations sociales standard        *
      * AUTEUR     : Olfie - Analyste Developpeur Mainframe            *
      * VERSION    : 1.0                                               *
      * LANGAGE    : COBOL IBM Enterprise (z/OS)                       *
      *----------------------------------------------------------------*
      * ENTREE  : fichier sequentiel SALBRUT (DD SALBRUT)              *
      *           Format : PIC 9(6)V99   salaire brut mensuel          *
      * SORTIE  : fichier sequentiel SALNET (DD SALNET)                *
      *           Format : rapport lisible (SYSOUT ou fichier)         *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CBL0010.
       AUTHOR. OLFIE.

      *----------------------------------------------------------------*
      * ENVIRONMENT DIVISION                                           *
      * Declaration des fichiers logiques et physiques                 *
      *----------------------------------------------------------------*
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-ZOS.
       OBJECT-COMPUTER. IBM-ZOS.

       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *    Fichier d'entree : un enregistrement par salarie
           SELECT SALBRUT
               ASSIGN TO DD-SALBRUT
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-FS-SALBRUT.

      *    Fichier de sortie : rapport des salaires nets
           SELECT SALNET
               ASSIGN TO DD-SALNET
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-FS-SALNET.

      *----------------------------------------------------------------*
      * DATA DIVISION                                                  *
      *----------------------------------------------------------------*
       DATA DIVISION.

       FILE SECTION.
      *--- Structure d'un enregistrement d'entree ---------------------
       FD  SALBRUT
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 80 CHARACTERS.

       01  ENR-SALBRUT.
           05  SAL-MATRICULE        PIC X(08).
           05  SAL-NOM              PIC X(20).
           05  SAL-PRENOM           PIC X(15).
           05  SAL-BRUT             PIC 9(06)V99.
           05  FILLER               PIC X(29).

      *--- Structure d'un enregistrement de sortie --------------------
       FD  SALNET
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 132 CHARACTERS.

       01  ENR-SALNET               PIC X(132).

      *----------------------------------------------------------------*
       WORKING-STORAGE SECTION.

      *--- File Status : controle des acces fichiers ------------------
       01  WS-FS-SALBRUT            PIC XX  VALUE SPACES.
       01  WS-FS-SALNET             PIC XX  VALUE SPACES.

      *--- Indicateur de fin de fichier -------------------------------
       01  WS-FIN-FICHIER           PIC X   VALUE 'N'.
           88  FIN-FICHIER                  VALUE 'O'.

      *--- Taux de cotisations sociales (values 2024 approximatives) --
       01  WS-TAUX.
           05  TX-SECU              PIC V999 VALUE .070.
           05  TX-RETRAITE          PIC V999 VALUE .069.
           05  TX-CHOMAGE           PIC V999 VALUE .024.
           05  TX-PREVOYANCE        PIC V999 VALUE .015.

      *--- Zone de calcul ---------------------------------------------
       01  WS-CALCUL.
           05  WS-BRUT              PIC 9(07)V99 VALUE ZEROS.
           05  WS-COTIS-SECU        PIC 9(06)V99 VALUE ZEROS.
           05  WS-COTIS-RETRAITE    PIC 9(06)V99 VALUE ZEROS.
           05  WS-COTIS-CHOMAGE     PIC 9(06)V99 VALUE ZEROS.
           05  WS-COTIS-PREV        PIC 9(06)V99 VALUE ZEROS.
           05  WS-TOTAL-COTIS       PIC 9(06)V99 VALUE ZEROS.
           05  WS-NET               PIC 9(07)V99 VALUE ZEROS.

      *--- Compteurs --------------------------------------------------
       01  WS-COMPTEURS.
           05  WS-NB-LUS            PIC 9(06) VALUE ZEROS.
           05  WS-NB-ECRITS         PIC 9(06) VALUE ZEROS.
           05  WS-TOTAL-BRUT        PIC 9(09)V99 VALUE ZEROS.
           05  WS-TOTAL-NET         PIC 9(09)V99 VALUE ZEROS.

      *--- Ligne de rapport (132 colonnes) ----------------------------
       01  WS-LIGNE-DETAIL.
           05  LIG-MATRIC           PIC X(08).
           05  FILLER               PIC X(02) VALUE SPACES.
           05  LIG-NOM              PIC X(20).
           05  FILLER               PIC X(02) VALUE SPACES.
           05  LIG-PRENOM           PIC X(15).
           05  FILLER               PIC X(02) VALUE SPACES.
           05  LIG-BRUT             PIC ZZBZZ9,99.
           05  FILLER               PIC X(02) VALUE SPACES.
           05  LIG-COTIS            PIC ZZBZZ9,99.
           05  FILLER               PIC X(02) VALUE SPACES.
           05  LIG-NET              PIC ZZBZZ9,99.
           05  FILLER               PIC X(40) VALUE SPACES.

       01  WS-LIGNE-ENTETE.
           05  FILLER  PIC X(08)  VALUE 'MATRICUL'.
           05  FILLER  PIC X(02)  VALUE SPACES.
           05  FILLER  PIC X(20)  VALUE 'NOM                 '.
           05  FILLER  PIC X(02)  VALUE SPACES.
           05  FILLER  PIC X(15)  VALUE 'PRENOM         '.
           05  FILLER  PIC X(02)  VALUE SPACES.
           05  FILLER  PIC X(10)  VALUE 'BRUT      '.
           05  FILLER  PIC X(02)  VALUE SPACES.
           05  FILLER  PIC X(10)  VALUE 'COTIS     '.
           05  FILLER  PIC X(02)  VALUE SPACES.
           05  FILLER  PIC X(10)  VALUE 'NET       '.
           05  FILLER  PIC X(49)  VALUE SPACES.

       01  WS-LIGNE-SEP.
           05  FILLER  PIC X(90)  VALUE ALL '-'.
           05  FILLER  PIC X(42)  VALUE SPACES.

       01  WS-LIGNE-TOTAL.
           05  FILLER          PIC X(51)  VALUE
               'TOTAUX                                             '.
           05  LIG-TOT-BRUT    PIC Z(08)9,99.
           05  FILLER          PIC X(02)  VALUE SPACES.
           05  FILLER          PIC X(10)  VALUE SPACES.
           05  LIG-TOT-NET     PIC Z(08)9,99.
           05  FILLER          PIC X(38)  VALUE SPACES.

      *----------------------------------------------------------------*
      * PROCEDURE DIVISION                                             *
      *----------------------------------------------------------------*
       PROCEDURE DIVISION.

      *================================================================*
       0000-PRINCIPAL.
      *================================================================*
           PERFORM 1000-INITIALISATION
           PERFORM 2000-TRAITEMENT UNTIL FIN-FICHIER
           PERFORM 3000-FINALISATION
           STOP RUN.

      *================================================================*
       1000-INITIALISATION.
      *================================================================*
           OPEN INPUT  SALBRUT
           OPEN OUTPUT SALNET

      *    Controle d'ouverture des fichiers
           IF WS-FS-SALBRUT NOT = '00'
               DISPLAY 'ERREUR OUVERTURE SALBRUT - FS=' WS-FS-SALBRUT
               MOVE 12 TO RETURN-CODE
               STOP RUN
           END-IF
           IF WS-FS-SALNET NOT = '00'
               DISPLAY 'ERREUR OUVERTURE SALNET - FS=' WS-FS-SALNET
               MOVE 12 TO RETURN-CODE
               STOP RUN
           END-IF

      *    Ecriture de l'en-tete du rapport
           WRITE ENR-SALNET FROM WS-LIGNE-ENTETE
           WRITE ENR-SALNET FROM WS-LIGNE-SEP

      *    Lecture du premier enregistrement (amorçage)
           PERFORM 9000-LIRE-SALBRUT.

      *================================================================*
       2000-TRAITEMENT.
      *================================================================*
           ADD 1 TO WS-NB-LUS

      *    Recuperation du salaire brut
           MOVE SAL-BRUT TO WS-BRUT

      *    Calcul des cotisations salariales
           COMPUTE WS-COTIS-SECU     = WS-BRUT * TX-SECU
           COMPUTE WS-COTIS-RETRAITE = WS-BRUT * TX-RETRAITE
           COMPUTE WS-COTIS-CHOMAGE  = WS-BRUT * TX-CHOMAGE
           COMPUTE WS-COTIS-PREV     = WS-BRUT * TX-PREVOYANCE

      *    Total cotisations et calcul net
           COMPUTE WS-TOTAL-COTIS =
               WS-COTIS-SECU     +
               WS-COTIS-RETRAITE +
               WS-COTIS-CHOMAGE  +
               WS-COTIS-PREV

           COMPUTE WS-NET = WS-BRUT - WS-TOTAL-COTIS

      *    Alimentation des totaux
           ADD WS-BRUT TO WS-TOTAL-BRUT
           ADD WS-NET  TO WS-TOTAL-NET

      *    Construction et ecriture de la ligne de detail
           MOVE SAL-MATRICULE  TO LIG-MATRIC
           MOVE SAL-NOM        TO LIG-NOM
           MOVE SAL-PRENOM     TO LIG-PRENOM
           MOVE WS-BRUT        TO LIG-BRUT
           MOVE WS-TOTAL-COTIS TO LIG-COTIS
           MOVE WS-NET         TO LIG-NET

           WRITE ENR-SALNET FROM WS-LIGNE-DETAIL
           ADD 1 TO WS-NB-ECRITS

           PERFORM 9000-LIRE-SALBRUT.

      *================================================================*
       3000-FINALISATION.
      *================================================================*
      *    Ecriture du pied de rapport
           WRITE ENR-SALNET FROM WS-LIGNE-SEP

           MOVE WS-TOTAL-BRUT TO LIG-TOT-BRUT
           MOVE WS-TOTAL-NET  TO LIG-TOT-NET
           WRITE ENR-SALNET FROM WS-LIGNE-TOTAL

      *    Bilan en console (visible dans SDSF / spool)
           DISPLAY '*** CALCSAL - BILAN EXECUTION ***'
           DISPLAY 'ENREGISTREMENTS LUS    : ' WS-NB-LUS
           DISPLAY 'ENREGISTREMENTS ECRITS : ' WS-NB-ECRITS
           DISPLAY 'TOTAL BRUT             : ' WS-TOTAL-BRUT
           DISPLAY 'TOTAL NET              : ' WS-TOTAL-NET

           CLOSE SALBRUT
           CLOSE SALNET

           MOVE 0 TO RETURN-CODE.

      *================================================================*
       9000-LIRE-SALBRUT.
      *================================================================*
           READ SALBRUT
               AT END MOVE 'O' TO WS-FIN-FICHIER
           END-READ

           IF WS-FS-SALBRUT NOT = '00'
              AND WS-FS-SALBRUT NOT = '10'
               DISPLAY 'ERREUR LECTURE SALBRUT - FS=' WS-FS-SALBRUT
               MOVE 8 TO RETURN-CODE
               STOP RUN
           END-IF.
