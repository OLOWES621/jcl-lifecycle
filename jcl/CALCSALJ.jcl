//*================================================================*
//* JCL : CALCSALJ                                                 *
//* OBJET : Cycle de vie complet en un seul JOB                    *
//*         Compilation + Link-Edit + Execution                    *
//*                                                                *
//* LOGIQUE COND :                                                 *
//*   Le step RUN ne s'execute que si le step de compilation a un  *
//*   RUC = 0.                                                     *
//*                                                                *
//* RETOUR ATTENDU : RC=0 sur tous les steps                       *
//*================================================================*
//CALCSALJ JOB 1,NOTIFY=&SYSUID,MSGLEVEL=(2,1),RESTART=*
//***************************************************/
//COBRUN  EXEC IGYWCL
//COBOL.SYSIN  DD DSN=&SYSUID..CBL(CALCSAL),DISP=SHR
//LKED.SYSLMOD DD DSN=&SYSUID..LOAD(CALCSAL),DISP=SHR
//***************************************************/
//DEL     EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *
           DELETE Z88400.FICNET PURGE
/*
//***************************************************/
// IF RC = 0 THEN
//***************************************************/
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
//***************************************************/
// ELSE
// ENDIF
