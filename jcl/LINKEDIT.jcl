//*================================================================*
//* JCL : LINKEDIT                                                *
//* OBJET : Edition des liens (Link-Edit) du module CALCSAL       *
//*         Etape 2 du cycle de vie d'un programme mainframe      *
//*                                                               *
//* ROLE DU LINK-EDIT :                                           *
//*   Transforme le module objet (.obj) en module de chargement   *
//*   executable (.load). C'est ici qu'on resout les references   *
//*   externes (sous-programmes, copybooks compiles, etc.)        *
//*                                                               *
//* ETAPES :                                                      *
//*   STEP1 - Link-Edit (IEWL)                                   *
//*                                                               *
//* RETOUR ATTENDU : RC=0                                         *
//*================================================================*
//LINKEDIT JOB (ACCT),'LINK-EDIT CALCSAL',
//             CLASS=A,
//             MSGCLASS=X,
//             MSGLEVEL=(1,1),
//             NOTIFY=&SYSUID
//*
//*----------------------------------------------------------------*
//* STEP1 : Link-Edit                                              *
//*         PGM=IEWL = linkage editor IBM                          *
//*         RENT = programme reentrant (bonne pratique)           *
//*         LIST = affiche la map des modules inclus               *
//*----------------------------------------------------------------*
//STEP1    EXEC PGM=IEWL,
//             PARM='RENT,LIST,XREF,LET'
//*
//*--- Bibliotheque contenant le module objet (sortie COMPIL) -----*
//SYSLIN   DD  DSN=OLFIE.OBJ.LOAD(CALCSAL),DISP=SHR
//*
//*--- Bibliotheques de recherche des sous-programmes -------------*
//SYSLIB   DD  DSN=CEE.SCEELKED,DISP=SHR
//         DD  DSN=OLFIE.LOAD.SUBPGM,DISP=SHR
//*
//*--- Module de chargement produit (load module executable) ------*
//SYSLMOD  DD  DSN=OLFIE.LOAD.PGMLIB(CALCSAL),
//             DISP=(NEW,CATLG,DELETE),
//             SPACE=(CYL,(2,1,1)),
//             DCB=(RECFM=U,BLKSIZE=32760)
//*
//*--- Listing du link-edit (map memoire, modules resolus) --------*
//SYSPRINT DD  SYSOUT=*
//*
//*--- Fichier de travail interne ---------------------------------*
//SYSUT1   DD  UNIT=SYSDA,SPACE=(CYL,(2,2))
//*
