!        Generated by TAPENADE     (INRIA, Tropics team)
!  Tapenade 2.2.4 (r2308) - 03/04/2008 10:03
!  
!  Differentiation of bcfarfieldforcecouplingadj in reverse (adjoint) mode:
!   gradient, with respect to input variables: winfadj padj pinfcorradj
!                wadj normadj
!   of linear combination of output variables: padj wadj normadj
!
!      ******************************************************************
!      *                                                                *
!      * File:          bcFarfieldForcesAdj.f90                         *
!      * Author:        Edwin van der Weide                             *
!      *                Seongim Choi,C.A.(Sandy) Mader                  *
!      * Starting date: 03-21-2006                                      *
!      * Last modified: 06-09-2008                                      *
!      *                                                                *
!      ******************************************************************
!
SUBROUTINE BCFARFIELDFORCECOUPLINGADJ_B(secondhalo, winfadj, winfadjb, &
&  pinfcorradj, pinfcorradjb, wadj, wadjb, padj, padjb, siadj, sjadj, &
&  skadj, normadj, normadjb, mm, iibeg, iiend, jjbeg, jjend, i2beg, &
&  i2end, j2beg, j2end)
  USE blockpointers, ONLY : bcdata, nbocos, bctype, bcfaceid, gamma, &
&  il, jl, kl, w, p, ib, jb, kb
  USE bctypes
  USE constants
  USE iteration
  USE flowvarrefstate
  IMPLICIT NONE
!
!      ******************************************************************
!      *                                                                *
!      * bcFarfieldAdj applies the farfield boundary condition to       *
!      * subface nn of the block to which the pointers in blockPointers *
!      * currently point.                                               *
!      *                                                                *
!      ******************************************************************
!
! irho,ivx,ivy,ivz
! gammaInf, wInf, pInfCorr
!
!      Subroutine arguments.
!
!  integer(kind=intType) :: nn ! it's not needed anymore w/ normAdj
!       integer(kind=intType), intent(in) :: icBeg, icEnd, jcBeg, jcEnd
!       integer(kind=intType), intent(in) :: iOffset, jOffset
  INTEGER(KIND=INTTYPE), INTENT(IN) :: mm
  INTEGER(KIND=INTTYPE), INTENT(IN) :: iibeg, iiend, jjbeg, jjend
  INTEGER(KIND=INTTYPE), INTENT(IN) :: i2beg, i2end, j2beg, j2end
!       integer(kind=intType) :: iCell, jCell, kCell
  REAL(KIND=REALTYPE), DIMENSION(0:ib, 0:jb, 0:kb, nw) :: wadj
  REAL(KIND=REALTYPE), DIMENSION(0:ib, 0:jb, 0:kb, nw) :: wadjb
  REAL(KIND=REALTYPE), DIMENSION(0:ib, 0:jb, 0:kb) :: padj
  REAL(KIND=REALTYPE), DIMENSION(0:ib, 0:jb, 0:kb) :: padjb
  LOGICAL, INTENT(IN) :: secondhalo
  REAL(KIND=REALTYPE), DIMENSION(2, iibeg:iiend, jjbeg:jjend, 3) :: &
&  siadj
! notice the range of y dim is set 1:2 which corresponds to 1/jl
  REAL(KIND=REALTYPE), DIMENSION(iibeg:iiend, 2, jjbeg:jjend, 3) :: &
&  sjadj
! notice the range of z dim is set 1:2 which corresponds to 1/kl
  REAL(KIND=REALTYPE), DIMENSION(iibeg:iiend, jjbeg:jjend, 2, 3) :: &
&  skadj
  REAL(KIND=REALTYPE), DIMENSION(iibeg:iiend, jjbeg:jjend, 3) :: normadj
  REAL(KIND=REALTYPE), DIMENSION(iibeg:iiend, jjbeg:jjend, 3) :: &
&  normadjb
!!$   integer(kind=intType) ::isbeg,jsbeg,ksbeg,isend,jsend,ksend
!!$  integer(kind=intType) ::ibbeg,jbbeg,kbbeg,ibend,jbend,kbend
!!$  integer(kind=intType) ::icbeg,jcbeg,kcbeg,icend,jcend,kcend
!!$  integer(kind=intType) :: iOffset, jOffset, kOffset
!real(kind=realType), dimension(-2:2,-2:2,-2:2)::rlvAdj, revAdj
!real(kind=realType), dimension(-2:2,-2:2)::rlvAdj1, rlvAdj2
!real(kind=realType), dimension(-2:2,-2:2)::revAdj1, revAdj2
  REAL(KIND=REALTYPE), DIMENSION(nw) :: winfadj
  REAL(KIND=REALTYPE), DIMENSION(nw) :: winfadjb
!  real(kind=realType), dimension(-2:2,-2:2,-2:2,3), intent(in) :: &
!       siAdj, sjAdj, skAdj
!  real(kind=realType), dimension(nBocos,-2:2,-2:2,3), intent(in) :: normAdj
!  real(kind=realType), dimension(-2:2,-2:2,-2:2,nw), &
!       intent(in) :: wAdj
!  real(kind=realType), dimension(-2:2,-2:2,-2:2),intent(in) :: pAdj
  REAL(KIND=REALTYPE) :: pinfcorradj
  REAL(KIND=REALTYPE) :: pinfcorradjb
  REAL(KIND=REALTYPE), DIMENSION(iibeg:iiend, jjbeg:jjend, nw) :: wadj0&
&  , wadj1
  REAL(KIND=REALTYPE), DIMENSION(iibeg:iiend, jjbeg:jjend, nw) :: wadj0b&
&  , wadj1b
  REAL(KIND=REALTYPE), DIMENSION(iibeg:iiend, jjbeg:jjend, nw) :: wadj2&
&  , wadj3
  REAL(KIND=REALTYPE), DIMENSION(iibeg:iiend, jjbeg:jjend, nw) :: wadj2b&
&  , wadj3b
  REAL(KIND=REALTYPE), DIMENSION(iibeg:iiend, jjbeg:jjend) :: padj0, &
&  padj1
  REAL(KIND=REALTYPE), DIMENSION(iibeg:iiend, jjbeg:jjend) :: padj0b, &
&  padj1b
  REAL(KIND=REALTYPE), DIMENSION(iibeg:iiend, jjbeg:jjend) :: padj2, &
&  padj3
  REAL(KIND=REALTYPE), DIMENSION(iibeg:iiend, jjbeg:jjend) :: padj2b, &
&  padj3b
  REAL(KIND=REALTYPE), DIMENSION(0:ib, 0:jb, 0:kb) :: rlvadj, revadj
  REAL(KIND=REALTYPE), DIMENSION(iibeg:iiend, jjbeg:jjend) :: rlvadj1, &
&  rlvadj2
  REAL(KIND=REALTYPE), DIMENSION(iibeg:iiend, jjbeg:jjend) :: revadj1, &
&  revadj2
!real(kind=realType), dimension(-2:2,-2:2,nw) :: wAdj0, wAdj1
!real(kind=realType), dimension(-2:2,-2:2,nw) :: wAdj2, wAdj3
!real(kind=realType), dimension(-2:2,-2:2)    :: pAdj0, pAdj1
!real(kind=realType), dimension(-2:2,-2:2)    :: pAdj2, pAdj3
!real(kind=realType), dimension(nBocos,-2:2,-2:2,3), intent(in) :: normAdj
!
!      Local variables.
!
  INTEGER(KIND=INTTYPE) :: i, j, l, ii, jj
  REAL(KIND=REALTYPE) :: nnx, nny, nnz
  REAL(KIND=REALTYPE) :: nnxb, nnyb, nnzb
  REAL(KIND=REALTYPE) :: gm1, ovgm1, gm53, factk, ac1, ac2
  REAL(KIND=REALTYPE) :: ac1b, ac2b
  REAL(KIND=REALTYPE) :: r0, u0, v0, w0, qn0, vn0, c0, s0
  REAL(KIND=REALTYPE) :: r0b, u0b, v0b, w0b, qn0b, c0b, s0b
  REAL(KIND=REALTYPE) :: re, ue, ve, we, qne, ce
  REAL(KIND=REALTYPE) :: reb, ueb, veb, web, qneb, ceb
  REAL(KIND=REALTYPE) :: qnf, cf, uf, vf, wf, sf, cc, qq
  REAL(KIND=REALTYPE) :: qnfb, cfb, ufb, vfb, wfb, sfb, ccb
  REAL(KIND=REALTYPE) :: rface
  REAL(KIND=REALTYPE) :: tmp
  REAL(KIND=REALTYPE) :: tmpb
  REAL(KIND=REALTYPE) :: tmp0
  REAL(KIND=REALTYPE) :: tmp0b
  INTEGER :: branch
  REAL(KIND=REALTYPE) :: tempb4
  REAL(KIND=REALTYPE) :: tempb3
  REAL(KIND=REALTYPE) :: tempb2
  REAL(KIND=REALTYPE) :: tempb1
  REAL(KIND=REALTYPE) :: tempb0
  REAL(KIND=REALTYPE) :: tempb
  INTRINSIC SQRT
!
!      Interfaces
!
!
!      ******************************************************************
!      *                                                                *
!      * Begin execution                                                *
!      *                                                                *
!      ******************************************************************
!
! Some constants needed to compute the riemann invariants.
  gm1 = gammainf - one
  ovgm1 = one/gm1
  gm53 = gammainf - five*third
  factk = -(ovgm1*gm53)
! Compute the three velocity components, the speed of sound and
! the entropy of the free stream.
  r0 = one/winfadj(irho)
  u0 = winfadj(ivx)
  v0 = winfadj(ivy)
  w0 = winfadj(ivz)
  c0 = SQRT(gammainf*pinfcorradj*r0)
  s0 = winfadj(irho)**gammainf/pinfcorradj
! Check for farfield boundary conditions.
  IF (bctype(mm) .EQ. farfield) THEN
    CALL EXTRACTBCSTATESFORCECOUPLINGADJ(mm, wadj, padj, wadj0, wadj1, &
&                                   wadj2, wadj3, padj0, padj1, padj2, &
&                                   padj3, rlvadj, revadj, rlvadj1, &
&                                   rlvadj2, revadj1, revadj2, iibeg, &
&                                   jjbeg, iiend, jjend, secondhalo)
! Loop over the generic subface to set the state in the
! halo cells.
!     do j=jcBeg, jcEnd
!        do i=icBeg, icEnd
    DO j=jjbeg,jjend
      DO i=iibeg,iiend
        CALL PUSHINTEGER4(ii)
        ii = i
        CALL PUSHINTEGER4(jj)
        jj = j
        rface = bcdata(mm)%rface(i, j)
        CALL PUSHREAL8(nnx)
! Store the three components of the unit normal a
! bit easier.
        nnx = normadj(ii, jj, 1)
        CALL PUSHREAL8(nny)
        nny = normadj(ii, jj, 2)
        CALL PUSHREAL8(nnz)
        nnz = normadj(ii, jj, 3)
        CALL PUSHREAL8(qn0)
! Compute the normal velocity of the free stream and
! substract the normal velocity of the mesh.
        qn0 = u0*nnx + v0*nny + w0*nnz
        vn0 = qn0 - rface
        CALL PUSHREAL8(re)
! Compute the three velocity components, the normal
! velocity and the speed of sound of the current state
! in the internal cell.
        re = one/wadj2(ii, jj, irho)
        CALL PUSHREAL8(ue)
        ue = wadj2(ii, jj, ivx)
        CALL PUSHREAL8(ve)
        ve = wadj2(ii, jj, ivy)
        CALL PUSHREAL8(we)
        we = wadj2(ii, jj, ivz)
        CALL PUSHREAL8(qne)
        qne = ue*nnx + ve*nny + we*nnz
        ce = SQRT(gammainf*padj2(ii, jj)*re)
! Compute the new values of the riemann invariants in
! the halo cell. Either the value in the internal cell
! is taken (positive sign of the corresponding
! eigenvalue) or the free stream value is taken
! (otherwise).
        IF (vn0 .GT. -c0) THEN
! Outflow or subsonic inflow.
          ac1 = qne + two*ovgm1*ce
          CALL PUSHINTEGER4(0)
        ELSE
! Supersonic inflow.
          ac1 = qn0 + two*ovgm1*c0
          CALL PUSHINTEGER4(1)
        END IF
        IF (vn0 .GT. c0) THEN
! Supersonic outflow.
          ac2 = qne - two*ovgm1*ce
          CALL PUSHINTEGER4(0)
        ELSE
! Inflow or subsonic outflow.
          ac2 = qn0 - two*ovgm1*c0
          CALL PUSHINTEGER4(1)
        END IF
        CALL PUSHREAL8(qnf)
        qnf = half*(ac1+ac2)
        CALL PUSHREAL8(cf)
        cf = fourth*(ac1-ac2)*gm1
        IF (vn0 .GT. zero) THEN
          CALL PUSHREAL8(uf)
! Outflow.
          uf = ue + (qnf-qne)*nnx
          CALL PUSHREAL8(vf)
          vf = ve + (qnf-qne)*nny
          CALL PUSHREAL8(wf)
          wf = we + (qnf-qne)*nnz
          CALL PUSHREAL8(sf)
          sf = wadj2(ii, jj, irho)**gammainf/padj2(ii, jj)
          DO l=nt1mg,nt2mg
            CALL PUSHREAL8(wadj1(ii, jj, l))
            wadj1(ii, jj, l) = wadj2(ii, jj, l)
          END DO
          CALL PUSHINTEGER4(0)
        ELSE
          CALL PUSHREAL8(uf)
! Inflow
          uf = u0 + (qnf-qn0)*nnx
          CALL PUSHREAL8(vf)
          vf = v0 + (qnf-qn0)*nny
          CALL PUSHREAL8(wf)
          wf = w0 + (qnf-qn0)*nnz
          CALL PUSHREAL8(sf)
          sf = s0
          DO l=nt1mg,nt2mg
            CALL PUSHREAL8(wadj1(ii, jj, l))
            wadj1(ii, jj, l) = winfadj(l)
          END DO
          CALL PUSHINTEGER4(1)
        END IF
        CALL PUSHREAL8(cc)
! Compute the density, velocity and pressure in the
! halo cell.
        cc = cf*cf/gammainf
        CALL PUSHREAL8(wadj1(ii, jj, irho))
        wadj1(ii, jj, irho) = (sf*cc)**ovgm1
        CALL PUSHREAL8(wadj1(ii, jj, ivx))
        wadj1(ii, jj, ivx) = uf
        CALL PUSHREAL8(wadj1(ii, jj, ivy))
        wadj1(ii, jj, ivy) = vf
        CALL PUSHREAL8(wadj1(ii, jj, ivz))
        wadj1(ii, jj, ivz) = wf
        padj1(ii, jj) = wadj1(ii, jj, irho)*cc
! Compute the total energy.
        tmp = ovgm1*padj1(ii, jj) + half*wadj1(ii, jj, irho)*(uf**2+vf**&
&          2+wf**2)
        CALL PUSHREAL8(wadj1(ii, jj, irhoe))
        wadj1(ii, jj, irhoe) = tmp
        IF (kpresent) THEN
          tmp0 = wadj1(ii, jj, irhoe) - factk*wadj1(ii, jj, irho)*wadj1(&
&            ii, jj, itu1)
          CALL PUSHREAL8(wadj1(ii, jj, irhoe))
          wadj1(ii, jj, irhoe) = tmp0
          CALL PUSHINTEGER4(2)
        ELSE
          CALL PUSHINTEGER4(1)
        END IF
      END DO
    END DO
!
!        Input the viscous effects - rlv1(), and rev1()
!
! Extrapolate the state vectors in case a second halo
! is needed.
    IF (secondhalo) THEN
      CALL PUSHINTEGER4(1)
    ELSE
      CALL PUSHINTEGER4(0)
    END IF
    CALL REPLACEBCSTATESFORCECOUPLINGADJ_B(mm, wadj0, wadj0b, wadj1, &
&                                     wadj1b, wadj2, wadj3, padj0, &
&                                     padj0b, padj1, padj1b, padj2, &
&                                     padj3, rlvadj1, rlvadj2, revadj1, &
&                                     revadj2, wadj, wadjb, padj, padjb&
&                                     , rlvadj, revadj, iibeg, jjbeg, &
&                                     iiend, jjend, secondhalo)
    CALL POPINTEGER4(branch)
    IF (branch .LT. 1) THEN
      padj2b(:, :) = 0.0
      wadj2b(:, :, :) = 0.0
    ELSE
      CALL EXTRAPOLATE2NDHALOFORCECOUPLINGADJ_B(mm, iibeg, iiend, jjbeg&
&                                          , jjend, wadj0, wadj0b, wadj1&
&                                          , wadj1b, wadj2, wadj2b, &
&                                          padj0, padj0b, padj1, padj1b&
&                                          , padj2, padj2b)
    END IF
    winfadjb(:) = 0.0
    v0b = 0.0
    s0b = 0.0
    c0b = 0.0
    w0b = 0.0
    u0b = 0.0
    DO j=jjend,jjbeg,-1
      DO i=iiend,iibeg,-1
        CALL POPINTEGER4(branch)
        IF (.NOT.branch .LT. 2) THEN
          CALL POPREAL8(wadj1(ii, jj, irhoe))
          tmp0b = wadj1b(ii, jj, irhoe)
          wadj1b(ii, jj, irhoe) = tmp0b
          wadj1b(ii, jj, irho) = wadj1b(ii, jj, irho) - factk*wadj1(ii, &
&            jj, itu1)*tmp0b
          wadj1b(ii, jj, itu1) = wadj1b(ii, jj, itu1) - factk*wadj1(ii, &
&            jj, irho)*tmp0b
        END IF
        CALL POPREAL8(wadj1(ii, jj, irhoe))
        tmpb = wadj1b(ii, jj, irhoe)
        wadj1b(ii, jj, irhoe) = 0.0
        tempb3 = half*wadj1(ii, jj, irho)*tmpb
        padj1b(ii, jj) = padj1b(ii, jj) + ovgm1*tmpb
        wadj1b(ii, jj, irho) = wadj1b(ii, jj, irho) + cc*padj1b(ii, jj) &
&          + half*(uf**2+vf**2+wf**2)*tmpb
        wfb = wadj1b(ii, jj, ivz) + 2*wf*tempb3
        wadj1b(ii, jj, ivz) = 0.0
        vfb = wadj1b(ii, jj, ivy) + 2*vf*tempb3
        wadj1b(ii, jj, ivy) = 0.0
        ufb = wadj1b(ii, jj, ivx) + 2*uf*tempb3
        wadj1b(ii, jj, ivx) = 0.0
        IF (sf*cc .LE. 0.0 .AND. (ovgm1 .EQ. 0.0 .OR. ovgm1 .NE. INT(&
&            ovgm1))) THEN
          tempb4 = 0.0
        ELSE
          tempb4 = ovgm1*(sf*cc)**(ovgm1-1)*wadj1b(ii, jj, irho)
        END IF
        ccb = sf*tempb4 + wadj1(ii, jj, irho)*padj1b(ii, jj)
        padj1b(ii, jj) = 0.0
        CALL POPREAL8(wadj1(ii, jj, ivz))
        CALL POPREAL8(wadj1(ii, jj, ivy))
        CALL POPREAL8(wadj1(ii, jj, ivx))
        CALL POPREAL8(wadj1(ii, jj, irho))
        sfb = cc*tempb4
        wadj1b(ii, jj, irho) = 0.0
        CALL POPREAL8(cc)
        cfb = 2*cf*ccb/gammainf
        CALL POPINTEGER4(branch)
        IF (branch .LT. 1) THEN
          DO l=nt2mg,nt1mg,-1
            CALL POPREAL8(wadj1(ii, jj, l))
            wadj2b(ii, jj, l) = wadj2b(ii, jj, l) + wadj1b(ii, jj, l)
            wadj1b(ii, jj, l) = 0.0
          END DO
          CALL POPREAL8(sf)
          tempb2 = sfb/padj2(ii, jj)
          IF (.NOT.(wadj2(ii, jj, irho) .LE. 0.0 .AND. (gammainf .EQ. &
&              0.0 .OR. gammainf .NE. INT(gammainf)))) wadj2b(ii, jj, &
&            irho) = wadj2b(ii, jj, irho) + gammainf*wadj2(ii, jj, irho)&
&              **(gammainf-1)*tempb2
          padj2b(ii, jj) = padj2b(ii, jj) - wadj2(ii, jj, irho)**&
&            gammainf*tempb2/padj2(ii, jj)
          CALL POPREAL8(wf)
          web = wfb
          qnfb = nny*vfb + nnx*ufb + nnz*wfb
          qneb = -(nny*vfb) - nnx*ufb - nnz*wfb
          nnzb = (qnf-qne)*wfb
          CALL POPREAL8(vf)
          veb = vfb
          nnyb = (qnf-qne)*vfb
          CALL POPREAL8(uf)
          ueb = ufb
          nnxb = (qnf-qne)*ufb
          qn0b = 0.0
        ELSE
          DO l=nt2mg,nt1mg,-1
            CALL POPREAL8(wadj1(ii, jj, l))
            winfadjb(l) = winfadjb(l) + wadj1b(ii, jj, l)
            wadj1b(ii, jj, l) = 0.0
          END DO
          CALL POPREAL8(sf)
          s0b = s0b + sfb
          CALL POPREAL8(wf)
          w0b = w0b + wfb
          qnfb = nny*vfb + nnx*ufb + nnz*wfb
          qn0b = -(nny*vfb) - nnx*ufb - nnz*wfb
          nnzb = (qnf-qn0)*wfb
          CALL POPREAL8(vf)
          v0b = v0b + vfb
          nnyb = (qnf-qn0)*vfb
          CALL POPREAL8(uf)
          u0b = u0b + ufb
          nnxb = (qnf-qn0)*ufb
          qneb = 0.0
          ueb = 0.0
          veb = 0.0
          web = 0.0
        END IF
        CALL POPREAL8(cf)
        tempb1 = fourth*gm1*cfb
        ac1b = half*qnfb + tempb1
        ac2b = half*qnfb - tempb1
        CALL POPREAL8(qnf)
        CALL POPINTEGER4(branch)
        IF (branch .LT. 1) THEN
          qneb = qneb + ac2b
          ceb = -(two*ovgm1*ac2b)
        ELSE
          qn0b = qn0b + ac2b
          c0b = c0b - two*ovgm1*ac2b
          ceb = 0.0
        END IF
        CALL POPINTEGER4(branch)
        IF (branch .LT. 1) THEN
          qneb = qneb + ac1b
          ceb = ceb + two*ovgm1*ac1b
        ELSE
          qn0b = qn0b + ac1b
          c0b = c0b + two*ovgm1*ac1b
        END IF
        IF (gammainf*(padj2(ii, jj)*re) .EQ. 0.0) THEN
          tempb0 = 0.0
        ELSE
          tempb0 = gammainf*ceb/(2.0*SQRT(gammainf*(padj2(ii, jj)*re)))
        END IF
        padj2b(ii, jj) = padj2b(ii, jj) + re*tempb0
        reb = padj2(ii, jj)*tempb0
        CALL POPREAL8(qne)
        ueb = ueb + nnx*qneb
        nnxb = nnxb + u0*qn0b + ue*qneb
        veb = veb + nny*qneb
        nnyb = nnyb + v0*qn0b + ve*qneb
        web = web + nnz*qneb
        nnzb = nnzb + w0*qn0b + we*qneb
        CALL POPREAL8(we)
        wadj2b(ii, jj, ivz) = wadj2b(ii, jj, ivz) + web
        CALL POPREAL8(ve)
        wadj2b(ii, jj, ivy) = wadj2b(ii, jj, ivy) + veb
        CALL POPREAL8(ue)
        wadj2b(ii, jj, ivx) = wadj2b(ii, jj, ivx) + ueb
        CALL POPREAL8(re)
        wadj2b(ii, jj, irho) = wadj2b(ii, jj, irho) - one*reb/wadj2(ii, &
&          jj, irho)**2
        CALL POPREAL8(qn0)
        u0b = u0b + nnx*qn0b
        v0b = v0b + nny*qn0b
        w0b = w0b + nnz*qn0b
        CALL POPREAL8(nnz)
        normadjb(ii, jj, 3) = normadjb(ii, jj, 3) + nnzb
        CALL POPREAL8(nny)
        normadjb(ii, jj, 2) = normadjb(ii, jj, 2) + nnyb
        CALL POPREAL8(nnx)
        normadjb(ii, jj, 1) = normadjb(ii, jj, 1) + nnxb
        CALL POPINTEGER4(jj)
        CALL POPINTEGER4(ii)
      END DO
    END DO
    padj3b(:, :) = 0.0
    wadj3b(:, :, :) = 0.0
    CALL EXTRACTBCSTATESFORCECOUPLINGADJ_B(mm, wadj, wadjb, padj, padjb&
&                                     , wadj0, wadj0b, wadj1, wadj1b, &
&                                     wadj2, wadj2b, wadj3, wadj3b, &
&                                     padj0, padj0b, padj1, padj1b, &
&                                     padj2, padj2b, padj3, padj3b, &
&                                     rlvadj, revadj, rlvadj1, rlvadj2, &
&                                     revadj1, revadj2, iibeg, jjbeg, &
&                                     iiend, jjend, secondhalo)
  ELSE
    winfadjb(:) = 0.0
    v0b = 0.0
    s0b = 0.0
    c0b = 0.0
    w0b = 0.0
    u0b = 0.0
  END IF
  IF (.NOT.(winfadj(irho) .LE. 0.0 .AND. (gammainf .EQ. 0.0 .OR. &
&      gammainf .NE. INT(gammainf)))) winfadjb(irho) = winfadjb(irho) + &
&      gammainf*winfadj(irho)**(gammainf-1)*s0b/pinfcorradj
  IF (gammainf*(pinfcorradj*r0) .EQ. 0.0) THEN
    tempb = 0.0
  ELSE
    tempb = gammainf*c0b/(2.0*SQRT(gammainf*(pinfcorradj*r0)))
  END IF
  pinfcorradjb = r0*tempb - winfadj(irho)**gammainf*s0b/pinfcorradj**2
  r0b = pinfcorradj*tempb
  winfadjb(ivz) = winfadjb(ivz) + w0b
  winfadjb(ivy) = winfadjb(ivy) + v0b
  winfadjb(ivx) = winfadjb(ivx) + u0b
  winfadjb(irho) = winfadjb(irho) - one*r0b/winfadj(irho)**2
END SUBROUTINE BCFARFIELDFORCECOUPLINGADJ_B