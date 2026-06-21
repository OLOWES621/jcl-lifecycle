//*================================================================*
//* JCL : CICLEVIE                                                *
//* OBJET : Cycle de vie complet en un seul JOB                  *
//*         Compilation + Link-Edit + Execution                   *
//*                                                               *
//* USAGE : pratique pour le developpement / tests rapides.       *
//*         En production, on separe les 3 JCL (COMPIL /         *
//*         LINKEDIT / EXEC) pour mieux controler chaque etape.   *
//*                                                               *
//* LOGIQUE COND :                                                *
//*   Chaque step ne s'execute que si le precedent a RC <= 4.     *
//*   COND=(4,LT,STEPx) = "sauter si RC du stepX > 4"           *
//*                                                               *
//* RETOUR ATTENDU : RC=0 sur tous les steps                      *
//*================================================================*
//CICLEVIE JOB (ACCT),'CYCLE VIE CALCSAL',
//             CLASS=A,
//             MSGCLASS=X,
//             MSGLEVEL=(1,1),
//             NOTIFY=&SYSUID
//*
//*================================================================*
//* STEP1 : COMPILATION COBOL                                     *
//*================================================================*
//STEP1    EXEC PGM=IGYCRCTL,
//             PARM='LIB,SOURCE,XREF,OFFSET,RENT'
//STEPLIB  DD  DSN=IGY.V6R4M0.SIGYCOMP,DISP=SHR
//SYSIN    DD  DSN=OLFIE.SOURCE.COBOL(CALCSAL),DISP=SHR
//SYSLIN   DD  DSN=&&OBJ,DISP=(NEW,PASS),
//             SPACE=(CYL,(1,1)),
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=3200)
//SYSPRINT DD  SYSOUT=*
//SYSUT1   DD  UNIT=SYSDA,SPACE=(CYL,(2,2))
//SYSUT2   DD  UNIT=SYSDA,SPACE=(CYL,(2,2))
//SYSUT3   DD  UNIT=SYSDA,SPACE=(CYL,(2,2))
//SYSUT4   DD  UNIT=SYSDA,SPACE=(CYL,(2,2))
//SYSUT5   DD  UNIT=SYSDA,SPACE=(CYL,(2,2))
//SYSUT6   DD  UNIT=SYSDA,SPACE=(CYL,(2,2))
//SYSUT7   DD  UNIT=SYSDA,SPACE=(CYL,(2,2))
//*
//*================================================================*
//* STEP2 : LINK-EDIT                                             *
//*         Ne s'execute que si STEP1 RC <= 4                     *
//*================================================================*
//STEP2    EXEC PGM=IEWL,
//             PARM='RENT,LIST,XREF,LET',
//             COND=(4,LT,STEP1)
//*
//*--- On recupere l'objet produit par STEP1 via le dataset temp --*
//SYSLIN   DD  DSN=&&OBJ,DISP=(OLD,DELETE)
//SYSLIB   DD  DSN=CEE.SCEELKED,DISP=SHR
//         DD  DSN=OLFIE.LOAD.SUBPGM,DISP=SHR
//SYSLMOD  DD  DSN=OLFIE.LOAD.PGMLIB(CALCSAL),
//             DISP=(NEW,CATLG,DELETE),
//             SPACE=(CYL,(2,1,1)),
//             DCB=(RECFM=U,BLKSIZE=32760)
//SYSPRINT DD  SYSOUT=*
//SYSUT1   DD  UNIT=SYSDA,SPACE=(CYL,(2,2))
//*
//*================================================================*
//* STEP3 : ALLOCATION FICHIER SORTIE                             *
//*         Ne s'execute que si STEP2 RC = 0                      *
//*================================================================*
//STEP3    EXEC PGM=IEFBR14,
//             COND=(4,LT,STEP2)
//SALNET   DD  DSN=OLFIE.DATA.SALNET,
//             DISP=(NEW,CATLG,DELETE),
//             SPACE=(CYL,(1,1)),
//             DCB=(RECFM=FB,LRECL=132,BLKSIZE=13200,DSORG=PS)
//*
//*================================================================*
//* STEP4 : EXECUTION DU PROGRAMME                               *
//*         Ne s'execute que si STEP3 RC = 0                      *
//*================================================================*
//STEP4    EXEC PGM=CALCSAL,
//             COND=(4,LT,STEP3)
//STEPLIB  DD  DSN=OLFIE.LOAD.PGMLIB,DISP=SHR
//SALBRUT  DD  DSN=OLFIE.DATA.SALBRUT,DISP=SHR
//SALNET   DD  DSN=OLFIE.DATA.SALNET,DISP=OLD
//SYSOUT   DD  SYSOUT=*
//SYSUDUMP DD  SYSOUT=*
//*
//*================================================================*
//* STEP5 : AFFICHAGE DU RAPPORT DANS LE SPOOL                   *
//*         Ne s'execute que si STEP4 RC = 0                      *
//*================================================================*
//STEP5    EXEC PGM=IEBGENER,
//             COND=(4,LT,STEP4)
//SYSUT1   DD  DSN=OLFIE.DATA.SALNET,DISP=SHR
//SYSUT2   DD  SYSOUT=*
//SYSIN    DD  DUMMY
//SYSPRINT DD  SYSOUT=*
//*
