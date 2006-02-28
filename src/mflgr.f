C     ******************************************************************
C     MAIN CODE FOR U.S. GEOLOGICAL SURVEY MODULAR MODEL -- MODFLOW-2005
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
C1------USE package modules.
      USE GLOBAL
      USE GWFBASMODULE
      USE GWFHUFMODULE, ONLY:IOHUFHDS,IOHUFFLWS
      USE PCGMODULE
      USE SIPMODULE
      USE DE4MODULE
      USE GMGMODULE
      USE LGRMODULE
      INCLUDE 'openspec.inc'
C
C-------ASSIGN VERSION NUMBER AND DATE
      CHARACTER*40 VERSION
      PARAMETER (VERSION='1.00 01/15/2006')
C
      CHARACTER*80 HEADNG(2)
      CHARACTER*200 FNAME
      INTEGER IBDT(8)
C
      CHARACTER*4 CUNIT(NIUNIT)
      DATA CUNIT/'BCF6', 'WEL ', 'DRN ', 'RIV ', 'EVT ', '    ', 'GHB ',  !  7
     &           'RCH ', 'SIP ', 'DE4 ', '    ', 'OC  ', 'PCG ', 'lmg ',  ! 14
     &           'gwt ', 'FHB ', '    ', 'STR ', 'IBS ', 'CHD ', 'HFB6',  ! 21
     &           'lak ', 'LPF ', 'DIS ', '    ', 'PVAL', '    ', '    ',  ! 28
     &           '    ', '    ', 'ZONE', 'MULT', '    ', '    ', '    ',  ! 35
     &           '    ', 'HUF2', '    ', '    ', '    ', '    ', 'GMG ',  ! 42
     &           '    ', 'sfr ', '    ', 'gage', 'LVDA', 'BFH ', 'lmt6',  ! 49
     &           'MNW1', '    ', '    ', 'KDEP', 'sub ', 'uzf ', '    ',  ! 56
     &           44*'    '/
C     ------------------------------------------------------------------
C
C2------WRITE BANNER TO SCREEN AND DEFINE CONSTANTS.
      WRITE (*,1) VERSION
    1 FORMAT (/,34X,'MODFLOW-2005',/,
     &4X,'U.S. GEOLOGICAL SURVEY MODULAR FINITE-DIFFERENCE',
     &' GROUND-WATER FLOW MODEL',/,29X,'Version ',A/)
      INUNIT = 99
      ILUNIT = 98
      NGRIDS = 1 
      ILGR = 0
C
C3------GET THE NAME OF THE NAME FILE
      CALL GETNAMFIL(ILGR,NGRIDS,FNAME,ILUNIT)
      DO IGRID = 1, NGRIDS
        MAXUNIT= INUNIT
C
C4------Get current date and time, assign to IBDT, and write to screen
        IF(IGRID .EQ. 1)THEN
          CALL DATE_AND_TIME(VALUES=IBDT)
          WRITE(*,2) (IBDT(I),I=1,3),(IBDT(I),I=5,7)
    2     FORMAT(1X,'Run start date and time (yyyy/mm/dd hh:mm:ss): ',
     &    I4,'/',I2.2,'/',I2.2,1X,I2,':',I2.2,':',I2.2,/)
        ENDIF
C5A------IF USING LGR, READ NAMES FROM LGR NAME FILE
        IF(ILGR .NE. 0) CALL GETNAMFILLGR(ILUNIT,FNAME,IGRID)
C5B------OPEN NAME FILE.
        OPEN (UNIT=INUNIT,FILE=FNAME,STATUS='OLD',ACTION=ACTION(1))
        NC=INDEX(FNAME,' ')
        WRITE(*,490)' Using NAME file: ',FNAME(1:NC)
  490   FORMAT(A,A)
C
C6------ALLOCATE AND READ (AR) PROCEDURE
        CALL GWF2BAS7AR(INUNIT,CUNIT,VERSION,24,31,32,MAXUNIT,IGRID,12,
     1                  HEADNG,26)
        IF(ILGR .NE.0) CALL GWF2LGR1AR(ILUNIT,FNAME,IGRID)
        IF(IUNIT(1).GT.0) CALL GWF2BCF7AR(IUNIT(1),IGRID)
        IF(IUNIT(23).GT.0) CALL GWF2LPF7AR(IUNIT(23),IGRID)
        IF(IUNIT(37).GT.0) CALL GWF2HUF7AR(IUNIT(37),IUNIT(47),
     1                                     IUNIT(53),IGRID)
        IF(IUNIT(2).GT.0) CALL GWF2WEL7AR(IUNIT(2),IGRID)
        IF(IUNIT(3).GT.0) CALL GWF2DRN7AR(IUNIT(3),IGRID)
        IF(IUNIT(4).GT.0) CALL GWF2RIV7AR(IUNIT(4),IGRID)
        IF(IUNIT(5).GT.0) CALL GWF2EVT7AR(IUNIT(5),IGRID)
        IF(IUNIT(7).GT.0) CALL GWF2GHB7AR(IUNIT(7),IGRID)
        IF(IUNIT(8).GT.0) CALL GWF2RCH7AR(IUNIT(8),IGRID)
        IF(IUNIT(16).GT.0) CALL GWF2FHB7AR(IUNIT(16),IGRID)
        IF(IUNIT(18).GT.0) CALL GWF2STR7AR(IUNIT(18),IGRID)
        IF(IUNIT(19).GT.0) CALL GWF2IBS7AR(IUNIT(19),IUNIT(54),IGRID)
        IF(IUNIT(20).GT.0) CALL GWF2CHD7AR(IUNIT(20),IGRID)
        IF(IUNIT(21).GT.0) CALL GWF2HFB7AR(IUNIT(21),IGRID)
        IF(IUNIT(48).GT.0) CALL GWF2BFH1AR(IUNIT(48),ILGR,IGRID)
        IF(IUNIT(9).GT.0) CALL SIP7AR(IUNIT(9),MXITER,IGRID)
        IF(IUNIT(10).GT.0) CALL DE47AR(IUNIT(10),MXITER,IGRID)
        IF(IUNIT(13).GT.0) CALL PCG7AR(IUNIT(13),MXITER,IGRID)
        IF(IUNIT(42).GT.0) CALL GMG7AR(IUNIT(42),MXITER,IGRID)
        IF(IUNIT(50).GT.0) CALL GWF2MNW7AR(IUNIT(50),IUNIT(9),
     1                                     IUNIT(10),0,IUNIT(13),
     2                                     0,IUNIT(42),FNAME,IGRID)
C END LOOP FOR ALLOCATING AND READING DATA FOR EACH GRID
      ENDDO
      CLOSE(ILUNIT)
C
C7------SIMULATE EACH STRESS PERIOD.
      DO 100 KPER = 1, NPER
        KKPER = KPER
        DO IGRID = 1, NGRIDS
          CALL GWF2BAS7ST(KKPER,IGRID)
          IF(IUNIT(19).GT.0) CALL GWF2IBS7ST(KKPER,IGRID)
C
C7B-----READ AND PREPARE INFORMATION FOR STRESS PERIOD.
C----------READ USING PACKAGE READ AND PREPARE MODULES.
          IF(ILGR .NE. 0) CALL GWF2LGR1RP(KKPER,IGRID)
          IF(IUNIT(2).GT.0) CALL GWF2WEL7RP(IUNIT(2),IGRID)
          IF(IUNIT(3).GT.0) CALL GWF2DRN7RP(IUNIT(3),IGRID)
          IF(IUNIT(4).GT.0) CALL GWF2RIV7RP(IUNIT(4),IGRID)
          IF(IUNIT(5).GT.0) CALL GWF2EVT7RP(IUNIT(5),IGRID)
          IF(IUNIT(7).GT.0) CALL GWF2GHB7RP(IUNIT(7),IGRID)
          IF(IUNIT(8).GT.0) CALL GWF2RCH7RP(IUNIT(8),IGRID)
          IF(IUNIT(18).GT.0) CALL GWF2STR7RP(IUNIT(18),IGRID)
          IF(IUNIT(20).GT.0) CALL GWF2CHD7RP(IUNIT(20),IGRID)
          IF(IUNIT(50).GT.0) CALL GWF2MNW7RP(IUNIT(50),IUNIT(1),
     1                                       IUNIT(23),IUNIT(37),KKPER,
     2                                       IGRID)
          IF(IUNIT(48).GT.0) CALL GWF2BFH1RP(IUNIT(48),KKPER,IUNIT(1),
     1                                       IUNIT(23),IUNIT(37),IGRID)
        ENDDO
C
C7C-----SIMULATE EACH TIME STEP.
        DO 90 KSTP = 1, NSTP(KPER)
          KKSTP = KSTP
          DO IGRID = 1, NGRIDS
C
C7C1----CALCULATE TIME STEP LENGTH. SET HOLD=HNEW.
            CALL GWF2BAS7AD(KKPER,KKSTP,IGRID)
            IF(IUNIT(20).GT.0) CALL GWF2CHD7AD(KKPER,IGRID)
            IF(IUNIT(1).GT.0) CALL GWF2BCF7AD(KKPER,IGRID)
            IF(IUNIT(23).GT.0) CALL GWF2LPF7AD(KKPER,IGRID)
            IF(IUNIT(37).GT.0) CALL GWF2HUF7AD(KKPER,IGRID)
            IF(IUNIT(16).GT.0) CALL GWF2FHB7AD(IGRID)
            IF(IUNIT(50).GT.0) CALL GWF2MNW7AD(IUNIT(1),IUNIT(23),
     1                                         IUNIT(37),IGRID)
            IF(IUNIT(48).GT.0) CALL GWF2BFH1AD(IUNIT(48),IGRID)
C
C---------INDICATE IN PRINTOUT THAT SOLUTION IS FOR HEADS
            CALL UMESPR('SOLVING FOR HEAD',' ',IOUT)
          ENDDO
          WRITE(*,25)KPER,KSTP
   25     FORMAT(' Solving:  Stress period: ',i5,4x,
     &       'Time step: ',i5,4x,'Ground-Water Flow Eqn.')
C
C---------BEGIN LOOP FOR ITERATING BETWEEN GRIDS (LGR ITERATIONS)
          LGRCNVG = 0            
          LGRITER = 0            
          ISHELL = 1
          DO WHILE (LGRCNVG .EQ. 0)
            LGRITER = LGRITER + 1

C7C2----ITERATIVELY FORMULATE AND SOLVE THE FLOW EQUATIONS.FOR EACH GRID
            DO IGRID = 1, NGRIDS
              CALL SGWF2BAS7PNT(IGRID)
C-------------CHECK IF LGR IS ACTIVE
              IF(ILGR .NE. 0)THEN
                CALL SGWF2LGR1PNT(IGRID)
C---------------CHECK IF PARENT OR CHILD GRID 
                IF(ISCHILD .EQ. -1)THEN
                  ISHELL = 1
                ELSE
C-----------------PUT PARENT HEAD TO CHILD GRID SHARED NODES AND RELAX
                  CALL GWF2LGR1BH(KKPER,KKSTP,LGRITER,
     1                            GLOBALDAT(1)%HNEW,  
     2                            GLOBALDAT(1)%NCOL,
     3                            GLOBALDAT(1)%NROW,
     4                            GLOBALDAT(1)%NLAY) 
                  ISHELL = 3
                ENDIF          
C---------------ADJUST STORAGE IF LGR IS ACTIVE AND TR SIMULATION
                IF(ITRSS .NE. 0)THEN 
                  IF(ISCHILD .EQ. -1)THEN
                    DO II =2,NGRIDS
                      CALL GWF2LGR1FMPBS(KKPER,KKSTP,LGRITER,IUNIT(1),
     1                                   IUNIT(23),IUNIT(37),
     2                                   -LGRDAT(II)%IBFLG,IGRID)
                    ENDDO
                  ELSE
                    CALL GWF2LGR1FMCBS(KKPER,KKSTP,LGRITER,IUNIT(1),
     1                                 IUNIT(23),IUNIT(37),IGRID)
                  ENDIF
                ENDIF
              ENDIF
C-------------BEGIN CAGE-SHELL INTERPOLATION LOOP
              DO IBSOLV =1, ISHELL             
                IF(ILGR.NE.0 .AND. IGRID.GT.1) CALL GWF2LGR1FMIB(IBSOLV,
     1                                                          IBSKIP2)
                IF(IGRID.GT.1 .AND. IBSKIP2.EQ.1) CYCLE
C
C7C2----ITERATIVELY FORMULATE AND SOLVE THE FLOW EQUATIONS.
                DO 30 KITER = 1, MXITER
                  KKITER = KITER
C
C7C2A---FORMULATE THE FINITE DIFFERENCE EQUATIONS.
                  CALL GWF2BAS7FM(IGRID)
                  IF(IUNIT(1).GT.0) CALL GWF2BCF7FM(KKITER,KKSTP,
     1                                     KKPER,IGRID)
                  IF(IUNIT(23).GT.0) CALL GWF2LPF7FM(KKITER,
     1                                   KKSTP,KKPER,IGRID)
                  IF(IUNIT(37).GT.0) CALL GWF2HUF7FM(KKITER,
     1                                   KKSTP,KKPER,IUNIT(47),IGRID)
C-----------------ADJUST CONDUCTANCES IF LGR IS ACTIVE
                  IF(ILGR .NE. 0)THEN
                    IF(IGRID .EQ. 1)THEN  
                      DO II =2,NGRIDS
                        CALL GWF2LGR1FMPBC(KKPER,KKSTP,KKITER,LGRITER,
     1                     IUNIT(1),LGRDAT(II)%NPCBEG,LGRDAT(II)%NPRBEG,
     2                     LGRDAT(II)%NPLBEG,LGRDAT(II)%NPCEND,
     3                     LGRDAT(II)%NPREND,LGRDAT(II)%NPLEND,
     4                     LGRDAT(II)%IBOTFLG,-LGRDAT(II)%IBFLG,
     5                     LGRDAT(II)%PFLUX)
                      ENDDO
                    ELSEIF(ISCHILD .GE. 0)THEN    
                      CALL GWF2LGR1FMCBC(KKPER,KKSTP,KKITER,LGRITER,
     1                                   IUNIT(1))
                    ENDIF
                  ENDIF
C
                  IF(IUNIT(21).GT.0) CALL GWF2HFB7FM(IGRID)
                  IF(IUNIT(2).GT.0) CALL GWF2WEL7FM(IGRID)
                  IF(IUNIT(3).GT.0) CALL GWF2DRN7FM(IGRID)
                  IF(IUNIT(4).GT.0) CALL GWF2RIV7FM(IGRID)
                  IF(IUNIT(5).GT.0) CALL GWF2EVT7FM(IGRID)
                  IF(IUNIT(7).GT.0) CALL GWF2GHB7FM(IGRID)
                  IF(IUNIT(8).GT.0) CALL GWF2RCH7FM(IGRID)
                  IF(IUNIT(16).GT.0) CALL GWF2FHB7FM(IGRID)
                  IF(IUNIT(18).GT.0) CALL GWF2STR7FM(IGRID)
                  IF(IUNIT(19).GT.0) CALL GWF2IBS7FM(KKPER,IGRID)
                  IF(IUNIT(50).GT.0) CALL GWF2MNW7FM(KKITER,IUNIT(1),
     1                                     IUNIT(23),IUNIT(37),IGRID)
                  IF(IUNIT(48).GT.0) CALL GWF2BFH1FM(KKPER,KKSTP,KKITER,
     1                                              IUNIT(1),IGRID) 
C
C7C2B---MAKE ONE CUT AT AN APPROXIMATE SOLUTION.
                  IF (IUNIT(9).GT.0) THEN
                    CALL SIP7PNT(IGRID)
                    CALL SIP7AP(HNEW,IBOUND,CR,CC,CV,HCOF,RHS,EL,FL,GL,
     1                V,W,HDCG,LRCH,NPARM,KKITER,HCLOSE,ACCL,ICNVG,
     2                KKSTP,KKPER,IPCALC,IPRSIP,MXITER,NSTP(KKPER),
     3                NCOL,NROW,NLAY,NODES,IOUT,0,IERR)
                  END IF
                  IF (IUNIT(10).GT.0) THEN
                    CALL DE47PNT(IGRID)
                    CALL DE47AP(HNEW,IBOUND,AU,AL,IUPPNT,IEQPNT,D4B,
     1                MXUP,MXLOW,MXEQ,MXBW,CR,CC,CV,HCOF,RHS,ACCLDE4,
     2                KITER,ITMX,MXITER,NITERDE4,HCLOSEDE4,IPRD4,ICNVG,
     3                NCOL,NROW,NLAY,IOUT,LRCHDE4,HDCGDE4,IFREQ,KKSTP,
     4                KKPER,DELT,NSTP(KKPER),ID4DIR,ID4DIM,MUTD4,IERR)
                  END IF
                  IF (IUNIT(13).GT.0) THEN
                    CALL PCG7PNT(IGRID)
                    CALL PCG7AP(HNEW,IBOUND,CR,CC,CV,HCOF,RHS,VPCG,SS,
     1                P,CD,HCHG,LHCH,RCHG,LRCHPCG,KKITER,NITER,
     2                HCLOSEPCG,RCLOSEPCG,ICNVG,KKSTP,KKPER,IPRPCG,
     3                MXITER,ITER1,NPCOND,NBPOL,NSTP(KKPER),NCOL,NROW,
     4                NLAY,NODES,RELAXPCG,IOUT,MUTPCG,IT1,DAMPPCG,BUFF,
     5                HCSV,IERR,HPCG)
                  END IF
                  IF (IUNIT(42).GT.0) THEN
                    CALL GMG7PNT(IGRID)
                    CALL GMG7AP(HNEW,RHS,CR,CC,CV,HCOF,HNOFLO,IBOUND,
     1                          IITER,MXITER,RCLOSEGMG,HCLOSEGMG,
     2                          KKITER,KKSTP,KKPER,ICNVG,SITER,TSITER,
     3                          DAMPGMG,IADAMPGMG,IOUTGMG,IOUT,GMGID)
                  ENDIF
C
C7C2C---IF CONVERGENCE CRITERION HAS BEEN MET STOP ITERATING.
                  IF (ICNVG.EQ.1) GOTO 33
  30            CONTINUE
                KITER = MXITER
C
   33           CONTINUE
C-------------END CAGE-SHELL INTERPOLATION LOOOP
              ENDDO
C-------------PREPARE THE NEXT GRID FOR LGR ITERATION
              IF(ILGR.NE.0)THEN 
                IF(ISCHILD .EQ. -1)THEN
                  DO II =2,NGRIDS
                    CALL GWF2LGR1INITP(IGRID,KKPER,KKSTP,LGRITER,
     1                      LGRDAT(II)%NPCBEG,LGRDAT(II)%NPRBEG,
     2                      LGRDAT(II)%NPLBEG,LGRDAT(II)%NPCEND,
     3                      LGRDAT(II)%NPREND,LGRDAT(II)%NPLEND,
     4                      LGRDAT(II)%IBOTFLG,-LGRDAT(II)%IBFLG,
     5                      LGRDAT(II)%ISHFLG,LGRDAT(II)%MXLGRITER)
                  ENDDO
                ELSEIF(IGRID.NE.1)THEN
C-----------------CALCULATE FLUX ENTERING THE CHILD INTERFACE AND RELAX
                  CALL GWF2LGR1FMBF(LGRITER,KKPER,KKSTP,IUNIT(1),
     1                              IUNIT(23),IUNIT(37)) 
                ENDIF
              ENDIF
C-----------END GRID LOOP
            ENDDO 
C-----------CHECK CONVEGENCE OF LGR IF LGR IS ACTIVE
            IF(ILGR .EQ. 0)THEN
              LGRCNVG = 1
            ELSE
              CALL GWF2LGR1CNVG(IGRID,NGRIDS,LGRCNVG,LGRITER,KKPER,
     1                          KKSTP)
            ENDIF
C---------END LGR ITERATION LOOP
          ENDDO       
C
C7C3----DETERMINE WHICH OUTPUT IS NEEDED.FOR EACH GRID
          DO IGRID = 1, NGRIDS
            CALL GWF2BAS7OC(KKSTP,KKPER,ICNVG,IUNIT(12),IGRID)
C
C7C4----CALCULATE BUDGET TERMS. SAVE CELL-BY-CELL FLOW TERMS.
            MSUM = 1
            IF (IUNIT(1).GT.0) THEN
              CALL GWF2BCF7BDS(KKSTP,KKPER,IGRID)
              CALL GWF2BCF7BDCH(KKSTP,KKPER,IGRID)
              IBDRET=0
              IC1=1
              IC2=NCOL
              IR1=1
              IR2=NROW
              IL1=1
              IL2=NLAY
              DO 37 IDIR = 1, 3
                CALL GWF2BCF7BDADJ(KKSTP,KKPER,IDIR,IBDRET,
     1                            IC1,IC2,IR1,IR2,IL1,IL2,IGRID)
   37         CONTINUE
            ENDIF
            IF(IUNIT(23).GT.0) THEN
              CALL GWF2LPF7BDS(KKSTP,KKPER,IGRID)
              CALL GWF2LPF7BDCH(KKSTP,KKPER,IGRID)
              IBDRET=0
              IC1=1
              IC2=NCOL
              IR1=1
              IR2=NROW
              IL1=1
              IL2=NLAY
              DO 157 IDIR=1,3
                CALL GWF2LPF7BDADJ(KKSTP,KKPER,IDIR,IBDRET,
     &                          IC1,IC2,IR1,IR2,IL1,IL2,IGRID)
157           CONTINUE
            ENDIF
            IF(IUNIT(37).GT.0) THEN
              CALL GWF2HUF7BDS(KKSTP,KKPER,IGRID)
              CALL GWF2HUF7BDCH(KKSTP,KKPER,IUNIT(47),IGRID)
              IBDRET=0
              IC1=1
              IC2=NCOL
              IR1=1
              IR2=NROW
              IL1=1
              IL2=NLAY
              DO 159 IDIR=1,3
                CALL GWF2HUF7BDADJ(KKSTP,KKPER,IDIR,IBDRET,
     &                          IC1,IC2,IR1,IR2,IL1,IL2,IUNIT(47),IGRID)
159           CONTINUE
            ENDIF
            IF(IUNIT(2).GT.0) CALL GWF2WEL7BD(KKSTP,KKPER,IGRID)
            IF(IUNIT(3).GT.0) CALL GWF2DRN7BD(KKSTP,KKPER,IGRID)
            IF(IUNIT(4).GT.0) CALL GWF2RIV7BD(KKSTP,KKPER,IGRID)
            IF(IUNIT(5).GT.0) CALL GWF2EVT7BD(KKSTP,KKPER,IGRID)
            IF(IUNIT(7).GT.0) CALL GWF2GHB7BD(KKSTP,KKPER,IGRID)
            IF(IUNIT(8).GT.0) CALL GWF2RCH7BD(KKSTP,KKPER,IGRID)
            IF(IUNIT(16).GT.0) CALL GWF2FHB7BD(KKSTP,KKPER,IGRID)
            IF(IUNIT(18).GT.0) CALL GWF2STR7BD(KKSTP,KKPER,IGRID)
            IF(IUNIT(19).GT.0) CALL GWF2IBS7BD(KKSTP,KKPER,IGRID)
            IF(IUNIT(50).GT.0) CALL GWF2MNW7BD(NSTP(KPER),KKSTP,KKPER,
     1                                         IGRID)
            IF(IUNIT(48).GT.0) CALL GWF2BFH1BD(KKSTP,KKPER,IUNIT(1),
     1                                        IUNIT(23),IUNIT(37),IGRID)
            IF(ILGR .NE.0)THEN 
              CALL SGWF2LGR1PNT(IGRID)
              DO II=2,NGRIDS
                IF(ISCHILD .LE. 0) CALL GWF2LGR1PBD(KKSTP,KKPER,II,
     1                 NGRIDS,LGRDAT(II)%NPCBEG,
     2                 LGRDAT(II)%NPRBEG,LGRDAT(II)%NPLBEG,
     3                 LGRDAT(II)%NPCEND,LGRDAT(II)%NPREND,
     4                 LGRDAT(II)%NPLEND,LGRDAT(II)%IBOTFLG,
     5                 -LGRDAT(II)%IBFLG,LGRDAT(II)%PFLUX)
              ENDDO
            ENDIF
C
C7C5---PRINT AND/OR SAVE DATA.
            CALL GWF2BAS7OT(KKSTP,KKPER,ICNVG,1,IGRID)
            IF(IUNIT(19).GT.0) CALL GWF2IBS7OT(KKSTP,KKPER,IUNIT(19),
     1                                         IGRID)
C------PRINT AND/OR SAVE HEADS INTERPOLATED TO HYDROGEOLOGIC UNITS
            IF(IUNIT(37).GT.0)THEN
              IF(IOHUFHDS .NE.0 .OR.IOHUFFLWS .NE.0)
     1           CALL GWF2HUF7OT(KKSTP,KKPER,ICNVG,1,IGRID)
            ENDIF
C
C------PRINT FLUXES FROM CHILD SPECIFIED HEAD BOUNDARY CONDITIONS 
            IF(ILGR.NE.0)THEN 
              CALL SGWF2LGR1PNT(IGRID)
              IF(ISCHILD .GE. 0) CALL GWF2LGR1CBD(KKSTP,KKPER,IGRID, 
     1                                            GLOBALDAT(1)%NCOL,
     2                                            GLOBALDAT(1)%NROW,
     3                                            GLOBALDAT(1)%NLAY, 
     4                                            GLOBALDAT(1)%IBOUND) 
            ENDIF
C
C------CHECK FOR CHANGES IN HEAD AND FLUX BOUNDARY CONDITIONS 
            IF(IUNIT(48).GT.0) CALL GWF2BFH1OT(KKSTP,KKPER,IGRID)

C7C6---JUMP TO END OF PROGRAM IF CONVERGENCE WAS NOT ACHIEVED.
            IF(ICNVG.EQ.0 .AND.ILGR .EQ. 0) GO TO 110
C---------END GRID OT GRID LOOP
          ENDDO
C
C-----END OF TIME STEP (KSTP) AND STRESS PERIOD (KPER) LOOPS
   90   CONTINUE
  100 CONTINUE
C
      DO IGRID = 1, NGRIDS
        CALL SGWF2BAS7PNT(IGRID)
        IF(IUNIT(50) .NE. 0) CALL GWF2MNW7OT(IGRID)
      ENDDO
C
C8------END OF SIMULATION
  110 CALL GLO1BAS6ET(IOUT,IBDT,1)
C
      DO IGRID = 1, NGRIDS
C9------CLOSE FILES AND DEALLOCATE MEMORY.  GWF2BAS7DA MUST BE CALLED
C9------LAST BECAUSE IT DEALLOCATES IUNIT.
        CALL SGWF2BAS7PNT(IGRID)
        IF(ILGR.NE.0) CALL GWF2LGR1DA(IGRID)
        IF(IUNIT(1).GT.0) CALL GWF2BCF7DA(IGRID)
        IF(IUNIT(2).GT.0) CALL GWF2WEL7DA(IGRID)
        IF(IUNIT(3).GT.0) CALL GWF2DRN7DA(IGRID)
        IF(IUNIT(4).GT.0) CALL GWF2RIV7DA(IGRID)
        IF(IUNIT(5).GT.0) CALL GWF2EVT7DA(IGRID)
        IF(IUNIT(7).GT.0) CALL GWF2GHB7DA(IGRID)
        IF(IUNIT(8).GT.0) CALL GWF2RCH7DA(IGRID)
        IF(IUNIT(9).GT.0) CALL SIP7DA(IGRID)
        IF(IUNIT(10).GT.0) CALL DE47DA(IGRID)
        IF(IUNIT(13).GT.0) CALL PCG7DA(IGRID)
        IF(IUNIT(16).GT.0) CALL GWF2FHB7DA(IGRID)
        IF(IUNIT(18).GT.0) CALL GWF2STR7DA(IGRID)
        IF(IUNIT(19).GT.0) CALL GWF2IBS7DA(IGRID)
        IF(IUNIT(20).GT.0) CALL GWF2CHD7DA(IGRID)
        IF(IUNIT(21).GT.0) CALL GWF2HFB7DA(IGRID)
        IF(IUNIT(23).GT.0) CALL GWF2LPF7DA(IGRID)
        IF(IUNIT(37).GT.0) CALL GWF2HUF7DA(IGRID)
        IF(IUNIT(42).GT.0) CALL GMG7DA(IGRID)
        IF(IUNIT(48).GT.0) CALL GWF2BFH1DA(IGRID)
        IF(IUNIT(50).GT.0) CALL GWF2MNW7DA(IGRID)
        CALL GWF2BAS7DA(IGRID)
      ENDDO
C
C10-----END OF PROGRAM.
      IF(ICNVG.EQ.0) THEN
        WRITE(*,*) ' Failure to converge'
      ELSE
        WRITE(*,*) ' Normal termination of simulation'
      END IF
      CALL USTOP(' ')
C
      END
      SUBROUTINE GETNAMFIL(ILGR,NGRIDS,FNAME,ILUNIT)
C     ******************************************************************
C     GET THE NAME OF THE NAME FILE
C     ******************************************************************
C        SPECIFICATIONS:
C
C     ------------------------------------------------------------------
      CHARACTER*(*) FNAME
      CHARACTER*200 COMLIN,LINE
      LOGICAL EXISTS
      INCLUDE 'openspec.inc'
C     ------------------------------------------------------------------
C
C Get name file from command line or user interaction.
        FNAME=' '
        COMLIN=' '
C *** Subroutines GETARG and GETCL are extensions to Fortran 90/95 that
C *** allow a program to retrieve command-line arguments.  To enable
C *** Modflow-2000 to read the name of a Name file from the command
C *** line, either GETARG or GETCL must be called, but not both.  As
C *** distributed, the call to GETARG is uncommented.  For compilers
C *** that support GETCL but not GETARG, comment out the call to GETARG
C *** and uncomment the call to GETCL.  The calls to both GETARG and
C *** GETCL may be commented out for compilers that do not support
C *** either extension.
        CALL GETARG(1,COMLIN)
C        CALL GETCL(COMLIN)
        ICOL = 1
        IF(COMLIN.NE.' ') THEN
          FNAME=COMLIN
        ELSE
   15   WRITE (*,*) ' Enter the name of the NAME FILE or LGR CONTROL ',
     &              'FILE:'
          READ (*,'(A)') FNAME
          CALL URWORD(FNAME,ICOL,ISTART,ISTOP,0,N,R,0,0)
          FNAME=FNAME(ISTART:ISTOP)
          IF (FNAME.EQ.' ') GOTO 15
        ENDIF
        INQUIRE (FILE=FNAME,EXIST=EXISTS)
        IF(.NOT.EXISTS) THEN
          NC=INDEX(FNAME,' ')
          FNAME(NC:NC+3)='.nam'
          INQUIRE (FILE=FNAME,EXIST=EXISTS)
          IF(.NOT.EXISTS) THEN
            WRITE (*,480) FNAME(1:NC-1),FNAME(1:NC+3)
  480       FORMAT(1X,'Can''t find name file ',A,' or ',A)
            CALL USTOP(' ')
          ENDIF
        ENDIF
C1A-----CHECK FOR LGR KEYWORD.  IF AN LGR SIMULATION, THEN READ THE 
C1A-----NUMBER OF GRIDS AND LEAVE FILE OPEN FOR PARSING.
C1A-----IF NOT LGR, THEN CLOSE FILE AND CONTINUE AS NORMAL.
      OPEN(UNIT=ILUNIT,FILE=FNAME,STATUS='OLD',ACTION=ACTION(1))
      CALL URDCOM(ILUNIT,0,LINE)
      ICOL=1
      CALL URWORD(LINE,ICOL,ISTART,ISTOP,1,N,R,0,ILUNIT)
      IF(LINE(ISTART:ISTOP) .EQ. 'LGR') THEN
        ILGR = 1
        WRITE(*,*) ' RUNNING MODFLOW WITH LGR '
        CALL URDCOM(ILUNIT,0,LINE)
        ICOL=1
        CALL URWORD(LINE,ICOL,ISTART,ISTOP,2,NGRIDS,R,0,ILUNIT)
        WRITE(*,*) 'NGRIDS = ', NGRIDS 
      ELSE
        CLOSE(ILUNIT)
      ENDIF
C
      RETURN
      END
      SUBROUTINE GLO1BAS6ET(IOUT,IBDT,IPRTIM)
C     ******************************************************************
C     Get end time and calculate elapsed time
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      INTEGER IBDT(8), IEDT(8), IDPM(12)
      DATA IDPM/31,28,31,30,31,30,31,31,30,31,30,31/ ! Days per month
      DATA NSPD/86400/  ! Seconds per day
C     ------------------------------------------------------------------
C
C     Get current date and time, assign to IEDT, and write.
      CALL DATE_AND_TIME(VALUES=IEDT)
      WRITE(*,1000) (IEDT(I),I=1,3),(IEDT(I),I=5,7)
 1000 FORMAT(1X,'Run end date and time (yyyy/mm/dd hh:mm:ss): ',
     &I4,'/',I2.2,'/',I2.2,1X,I2,':',I2.2,':',I2.2)
      IF(IPRTIM.GT.0) THEN
        WRITE(IOUT,'(1X)')
        WRITE(IOUT,1000) (IEDT(I),I=1,3),(IEDT(I),I=5,7)
      END IF
C
C     Calculate elapsed time in days and seconds
      NDAYS=0
      LEAP=0
      IF (MOD(IEDT(1),4).EQ.0) LEAP = 1
      IBD = IBDT(3)            ! BEGIN DAY
      IED = IEDT(3)            ! END DAY
C     FIND DAYS
      IF (IBDT(2).NE.IEDT(2)) THEN
C       MONTHS DIFFER
        MB = IBDT(2)             ! BEGIN MONTH
        ME = IEDT(2)             ! END MONTH
        NM = ME-MB+1             ! NUMBER OF MONTHS TO LOOK AT
        IF (MB.GT.ME) NM = NM+12
        MC=MB-1
        DO 10 M=1,NM
          MC=MC+1                ! MC IS CURRENT MONTH
          IF (MC.EQ.13) MC = 1
          IF (MC.EQ.MB) THEN
            NDAYS = NDAYS+IDPM(MC)-IBD
            IF (MC.EQ.2) NDAYS = NDAYS + LEAP
          ELSEIF (MC.EQ.ME) THEN
            NDAYS = NDAYS+IED
          ELSE
            NDAYS = NDAYS+IDPM(MC)
            IF (MC.EQ.2) NDAYS = NDAYS + LEAP
          ENDIF
   10   CONTINUE
      ELSEIF (IBD.LT.IED) THEN
C       START AND END IN SAME MONTH, ONLY ACCOUNT FOR DAYS
        NDAYS = IED-IBD
      ENDIF
      ELSEC=NDAYS*NSPD
C
C     ADD OR SUBTRACT SECONDS
      ELSEC = ELSEC+(IEDT(5)-IBDT(5))*3600.0
      ELSEC = ELSEC+(IEDT(6)-IBDT(6))*60.0
      ELSEC = ELSEC+(IEDT(7)-IBDT(7))
      ELSEC = ELSEC+(IEDT(8)-IBDT(8))*0.001
C
C     CONVERT SECONDS TO DAYS, HOURS, MINUTES, AND SECONDS
      NDAYS = ELSEC/NSPD
      RSECS = MOD(ELSEC,86400.0)
      NHOURS = RSECS/3600.0
      RSECS = MOD(RSECS,3600.0)
      NMINS = RSECS/60.0
      RSECS = MOD(RSECS,60.0)
      NSECS = RSECS
      RSECS = MOD(RSECS,1.0)
      MSECS = NINT(RSECS*1000.0)
      NRSECS = NSECS
      IF (RSECS.GE.0.5) NRSECS=NRSECS+1
C
C     Write elapsed time to screen
        IF (NDAYS.GT.0) THEN
          WRITE(*,1010) NDAYS,NHOURS,NMINS,NRSECS
 1010     FORMAT(1X,'Elapsed run time: ',I3,' Days, ',I2,' Hours, ',I2,
     &      ' Minutes, ',I2,' Seconds',/)
        ELSEIF (NHOURS.GT.0) THEN
          WRITE(*,1020) NHOURS,NMINS,NRSECS
 1020     FORMAT(1X,'Elapsed run time: ',I2,' Hours, ',I2,
     &      ' Minutes, ',I2,' Seconds',/)
        ELSEIF (NMINS.GT.0) THEN
          WRITE(*,1030) NMINS,NSECS,MSECS
 1030     FORMAT(1X,'Elapsed run time: ',I2,' Minutes, ',
     &      I2,'.',I3.3,' Seconds',/)
        ELSE
          WRITE(*,1040) NSECS,MSECS
 1040     FORMAT(1X,'Elapsed run time: ',I2,'.',I3.3,' Seconds',/)
        ENDIF
C
C     Write times to file if requested
      IF(IPRTIM.GT.0) THEN
        IF (NDAYS.GT.0) THEN
          WRITE(IOUT,1010) NDAYS,NHOURS,NMINS,NRSECS
        ELSEIF (NHOURS.GT.0) THEN
          WRITE(IOUT,1020) NHOURS,NMINS,NRSECS
        ELSEIF (NMINS.GT.0) THEN
          WRITE(IOUT,1030) NMINS,NSECS,MSECS
        ELSE
          WRITE(IOUT,1040) NSECS,MSECS
        ENDIF
      ENDIF
C
      RETURN
      END