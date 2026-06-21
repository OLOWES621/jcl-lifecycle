//*================================================================*
//* JCL : COMPIL                                                  *
//* OBJET : Compilation du programme COBOL CALCSAL               *
//*         Etape 1 du cycle de vie d'un programme mainframe      *
//*                                                               *
//* ETAPES :                                                      *
//*   STEP1 - Compilation COBOL (IGYCRCTL)                       *
//*                                                               *
//* RETOUR ATTENDU : RC=0 (OK) ou RC=4 (warnings acceptables)    *
//*================================================================*
//COMPIL   JOB (ACCT),'COMPILATION CALCSAL',
//             CLASS=A,
//             MSGCLASS=X,
//             MSGLEVEL=(1,1),
//             NOTIFY=&SYSUID
//*
//*----------------------------------------------------------------*
//* STEP1 : Compilation COBOL                                      *
//*         PGM=IGYCRCTL = compilateur IBM Enterprise COBOL        *
//*----------------------------------------------------------------*
//STEP1    EXEC PGM=IGYCRCTL,
//             PARM='LIB,SOURCE,XREF,OFFSET,RENT'
//*
//*--- Bibliotheques du compilateur COBOL -------------------------*
//STEPLIB  DD  DSN=IGY.V6R4M0.SIGYCOMP,DISP=SHR
//*
//*--- Source COBOL a compiler ------------------------------------*
//SYSIN    DD  DSN=OLFIE.SOURCE.COBOL(CALCSAL),DISP=SHR
//*
//*--- Objet compile (deck) : produit un module objet --------------*
//SYSLIN   DD  DSN=OLFIE.OBJ.LOAD(CALCSAL),
//             DISP=(NEW,CATLG,DELETE),
//             SPACE=(CYL,(1,1)),
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=3200)
//*
//*--- Listing de compilation (erreurs, warnings, XREF) -----------*
//SYSPRINT DD  SYSOUT=*
//*
//*--- Fichiers de travail internes au compilateur -----------------*
//SYSUT1   DD  UNIT=SYSDA,SPACE=(CYL,(2,2))
//SYSUT2   DD  UNIT=SYSDA,SPACE=(CYL,(2,2))
//SYSUT3   DD  UNIT=SYSDA,SPACE=(CYL,(2,2))
//SYSUT4   DD  UNIT=SYSDA,SPACE=(CYL,(2,2))
//SYSUT5   DD  UNIT=SYSDA,SPACE=(CYL,(2,2))
//SYSUT6   DD  UNIT=SYSDA,SPACE=(CYL,(2,2))
//SYSUT7   DD  UNIT=SYSDA,SPACE=(CYL,(2,2))
//*
