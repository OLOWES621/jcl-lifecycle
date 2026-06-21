//*================================================================*
//* JCL : EXEC                                                    *
//* OBJET : Execution du programme CALCSAL                        *
//*         Etape 3 du cycle de vie d'un programme mainframe      *
//*                                                               *
//* PRE-REQUIS :                                                  *
//*   - COMPIL.jcl execute avec RC <= 4                           *
//*   - LINKEDIT.jcl execute avec RC = 0                          *
//*   - Dataset OLFIE.DATA.SALBRUT alimente (voir output/)        *
//*                                                               *
//* ETAPES :                                                      *
//*   STEP1 - Allocation du fichier de sortie (IEFBR14)          *
//*   STEP2 - Execution CALCSAL                                   *
//*   STEP3 - Affichage du resultat (IEBGENER vers SYSOUT)       *
//*                                                               *
//* RETOUR ATTENDU : RC=0 sur tous les steps                      *
//*================================================================*
//EXEC     JOB (ACCT),'EXECUTION CALCSAL',
//             CLASS=A,
//             MSGCLASS=X,
//             MSGLEVEL=(1,1),
//             NOTIFY=&SYSUID
//*
//*----------------------------------------------------------------*
//* STEP1 : Preparation — allocation du fichier de sortie         *
//*         IEFBR14 = utilitaire "vide" : ne fait rien,           *
//*         mais ses DD provoquent l'allocation du dataset.        *
//*         Si le fichier existe deja, DISP=OLD l'ecrase.         *
//*----------------------------------------------------------------*
//STEP1    EXEC PGM=IEFBR14
//SALNET   DD  DSN=OLFIE.DATA.SALNET,
//             DISP=(NEW,CATLG,DELETE),
//             SPACE=(CYL,(1,1)),
//             DCB=(RECFM=FB,LRECL=132,BLKSIZE=13200,DSORG=PS)
//*
//*----------------------------------------------------------------*
//* STEP2 : Execution du programme CALCSAL                         *
//*         Le programme lit SALBRUT, calcule les nets,            *
//*         et ecrit le rapport dans SALNET.                        *
//*----------------------------------------------------------------*
//STEP2    EXEC PGM=CALCSAL,
//             COND=(4,LT,STEP1)
//*
//*--- Bibliotheque contenant le load module ----------------------*
//STEPLIB  DD  DSN=OLFIE.LOAD.PGMLIB,DISP=SHR
//*
//*--- Fichier d'entree : salaires bruts (FB, LRECL=80) ----------*
//SALBRUT  DD  DSN=OLFIE.DATA.SALBRUT,DISP=SHR
//*
//*--- Fichier de sortie : rapport salaires nets (FB, LRECL=132) -*
//SALNET   DD  DSN=OLFIE.DATA.SALNET,DISP=OLD
//*
//*--- Messages en console (visibles dans SDSF sous SYSOUT) ------*
//SYSOUT   DD  SYSOUT=*
//*
//*--- Message d'abend si le programme s'arrete anormalement -----*
//SYSUDUMP DD  SYSOUT=*
//*
//*----------------------------------------------------------------*
//* STEP3 : Affichage du rapport de sortie dans le spool          *
//*         IEBGENER copie SALNET vers SYSOUT                     *
//*         Permet de lire le resultat directement en SDSF        *
//*----------------------------------------------------------------*
//STEP3    EXEC PGM=IEBGENER,
//             COND=(4,LT,STEP2)
//SYSUT1   DD  DSN=OLFIE.DATA.SALNET,DISP=SHR
//SYSUT2   DD  SYSOUT=*
//SYSIN    DD  DUMMY
//SYSPRINT DD  SYSOUT=*
//*
