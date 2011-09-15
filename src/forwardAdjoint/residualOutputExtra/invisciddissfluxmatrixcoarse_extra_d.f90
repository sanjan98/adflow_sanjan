   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.4 (r3375) - 10 Feb 2010 15:08
   !
   !  Differentiation of invisciddissfluxmatrixcoarse in forward (tangent) mode:
   !   variations   of useful results: *fw
   !   with respect to varying inputs: *p *sfacei *sfacej *gamma *sfacek
   !                *w
   !
   !      ******************************************************************
   !      *                                                                *
   !      * File:          inviscidDissFluxMatrixCoarse.f90                *
   !      * Author:        Edwin van der Weide                             *
   !      * Starting date: 03-25-2003                                      *
   !      * Last modified: 08-25-2005                                      *
   !      *                                                                *
   !      ******************************************************************
   !
   SUBROUTINE INVISCIDDISSFLUXMATRIXCOARSE_EXTRA_D()
   USE FLOWVARREFSTATE
   USE INPUTPHYSICS
   USE BLOCKPOINTERS_D
   USE ITERATION
   USE INPUTDISCRETIZATION
   USE CONSTANTS
   IMPLICIT NONE
   !
   !      ******************************************************************
   !      *                                                                *
   !      * inviscidDissFluxMatrixCoarse computes the matrix artificial    *
   !      * dissipation term. Instead of the spectral radius, as used in   *
   !      * the scalar dissipation scheme, the absolute value of the flux  *
   !      * jacobian is used. This routine is used on the coarser grids in *
   !      * the multigrid cycle and only computes the first order          *
   !      * dissipation term. It is assumed that the pointers in           *
   !      * blockPointers already point to the correct block.              *
   !      *                                                                *
   !      ******************************************************************
   !
   !
   !      Local parameters.
   !
   REAL(kind=realtype), PARAMETER :: epsacoustic=0.25_realType
   REAL(kind=realtype), PARAMETER :: epsshear=0.025_realType
   !
   !      Local variables.
   !
   INTEGER(kind=inttype) :: i, j, k
   REAL(kind=realtype) :: sfil, fis0, dis0, ppor, rrad, sface
   REAL(kind=realtype) :: rradd, sfaced
   REAL(kind=realtype) :: gammaavg, gm1, ovgm1, gm53, tmp, fs
   REAL(kind=realtype) :: gammaavgd, gm1d, ovgm1d, gm53d, fsd
   REAL(kind=realtype) :: dr, dru, drv, drw, dre, drk, sx, sy, sz
   REAL(kind=realtype) :: drd, drud, drvd, drwd, dred, drkd
   REAL(kind=realtype) :: uavg, vavg, wavg, a2avg, aavg, havg
   REAL(kind=realtype) :: uavgd, vavgd, wavgd, a2avgd, aavgd, havgd
   REAL(kind=realtype) :: alphaavg, unavg, ovaavg, ova2avg
   REAL(kind=realtype) :: alphaavgd, unavgd, ovaavgd, ova2avgd
   REAL(kind=realtype) :: kavg, lam1, lam2, lam3, area
   REAL(kind=realtype) :: kavgd, lam1d, lam2d, lam3d
   REAL(kind=realtype) :: abv1, abv2, abv3, abv4, abv5, abv6, abv7
   REAL(kind=realtype) :: abv1d, abv2d, abv3d, abv4d, abv5d, abv6d, abv7d
   LOGICAL :: correctfork
   REAL(kind=realtype) :: arg1
   INTRINSIC MAX
   INTRINSIC ABS
   INTRINSIC SQRT
   REAL(realType) :: max3
   REAL(realType) :: max2
   REAL(realType) :: max1
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Begin execution                                                *
   !      *                                                                *
   !      ******************************************************************
   !
   ! Check if rFil == 0. If so, the dissipative flux needs not to
   ! be computed.
   IF (rfil .EQ. zero) THEN
   fwd = 0.0
   RETURN
   ELSE
   ! Determine whether or not the total energy must be corrected
   ! for the presence of the turbulent kinetic energy.
   IF (kpresent) THEN
   IF (currentlevel .EQ. groundlevel .OR. turbcoupled) THEN
   correctfork = .true.
   ELSE
   correctfork = .false.
   END IF
   ELSE
   correctfork = .false.
   END IF
   ! Initialize sface to zero. This value will be used if the
   ! block is not moving.
   sface = zero
   ! Set a couple of constants for the scheme.
   fis0 = rfil*vis2coarse
   sfil = one - rfil
   ! Initialize the dissipative residual to a certain times,
   ! possibly zero, the previously stored value. Owned cells
   ! only, because the halo values do not matter.
   DO k=2,kl
   DO j=2,jl
   DO i=2,il
   fwd(i, j, k, irho) = 0.0
   fw(i, j, k, irho) = sfil*fw(i, j, k, irho)
   fwd(i, j, k, imx) = 0.0
   fw(i, j, k, imx) = sfil*fw(i, j, k, imx)
   fwd(i, j, k, imy) = 0.0
   fw(i, j, k, imy) = sfil*fw(i, j, k, imy)
   fwd(i, j, k, imz) = 0.0
   fw(i, j, k, imz) = sfil*fw(i, j, k, imz)
   fwd(i, j, k, irhoe) = 0.0
   fw(i, j, k, irhoe) = sfil*fw(i, j, k, irhoe)
   END DO
   END DO
   END DO
   fwd = 0.0
   sfaced = 0.0
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Dissipative fluxes in the i-direction.                         *
   !      *                                                                *
   !      ******************************************************************
   !
   DO k=2,kl
   DO j=2,jl
   DO i=1,il
   ! Compute the dissipation coefficient for this face.
   ppor = zero
   IF (pori(i, j, k) .EQ. normalflux) ppor = one
   dis0 = fis0*ppor
   ! Construct the vector of the first differences multiplied
   ! by dis0.
   drd = dis0*(wd(i+1, j, k, irho)-wd(i, j, k, irho))
   dr = dis0*(w(i+1, j, k, irho)-w(i, j, k, irho))
   drud = dis0*(wd(i+1, j, k, irho)*w(i+1, j, k, ivx)+w(i+1, j, k&
   &            , irho)*wd(i+1, j, k, ivx)-wd(i, j, k, irho)*w(i, j, k, ivx)&
   &            -w(i, j, k, irho)*wd(i, j, k, ivx))
   dru = dis0*(w(i+1, j, k, irho)*w(i+1, j, k, ivx)-w(i, j, k, &
   &            irho)*w(i, j, k, ivx))
   drvd = dis0*(wd(i+1, j, k, irho)*w(i+1, j, k, ivy)+w(i+1, j, k&
   &            , irho)*wd(i+1, j, k, ivy)-wd(i, j, k, irho)*w(i, j, k, ivy)&
   &            -w(i, j, k, irho)*wd(i, j, k, ivy))
   drv = dis0*(w(i+1, j, k, irho)*w(i+1, j, k, ivy)-w(i, j, k, &
   &            irho)*w(i, j, k, ivy))
   drwd = dis0*(wd(i+1, j, k, irho)*w(i+1, j, k, ivz)+w(i+1, j, k&
   &            , irho)*wd(i+1, j, k, ivz)-wd(i, j, k, irho)*w(i, j, k, ivz)&
   &            -w(i, j, k, irho)*wd(i, j, k, ivz))
   drw = dis0*(w(i+1, j, k, irho)*w(i+1, j, k, ivz)-w(i, j, k, &
   &            irho)*w(i, j, k, ivz))
   dred = dis0*(wd(i+1, j, k, irhoe)-wd(i, j, k, irhoe))
   dre = dis0*(w(i+1, j, k, irhoe)-w(i, j, k, irhoe))
   ! In case a k-equation is present, compute the difference
   ! of rhok and store the average value of k. If not present,
   ! set both these values to zero, such that later on no
   ! decision needs to be made anymore.
   IF (correctfork) THEN
   drkd = dis0*(wd(i+1, j, k, irho)*w(i+1, j, k, itu1)+w(i+1, j&
   &              , k, irho)*wd(i+1, j, k, itu1)-wd(i, j, k, irho)*w(i, j, k&
   &              , itu1)-w(i, j, k, irho)*wd(i, j, k, itu1))
   drk = dis0*(w(i+1, j, k, irho)*w(i+1, j, k, itu1)-w(i, j, k&
   &              , irho)*w(i, j, k, itu1))
   kavgd = half*(wd(i+1, j, k, itu1)+wd(i, j, k, itu1))
   kavg = half*(w(i+1, j, k, itu1)+w(i, j, k, itu1))
   ELSE
   drk = zero
   kavg = zero
   kavgd = 0.0
   drkd = 0.0
   END IF
   ! Compute the average value of gamma and compute some
   ! expressions in which it occurs.
   gammaavgd = half*(gammad(i+1, j, k)+gammad(i, j, k))
   gammaavg = half*(gamma(i+1, j, k)+gamma(i, j, k))
   gm1d = gammaavgd
   gm1 = gammaavg - one
   ovgm1d = -(one*gm1d/gm1**2)
   ovgm1 = one/gm1
   gm53d = gammaavgd
   gm53 = gammaavg - five*third
   ! Compute the average state at the interface.
   uavgd = half*(wd(i+1, j, k, ivx)+wd(i, j, k, ivx))
   uavg = half*(w(i+1, j, k, ivx)+w(i, j, k, ivx))
   vavgd = half*(wd(i+1, j, k, ivy)+wd(i, j, k, ivy))
   vavg = half*(w(i+1, j, k, ivy)+w(i, j, k, ivy))
   wavgd = half*(wd(i+1, j, k, ivz)+wd(i, j, k, ivz))
   wavg = half*(w(i+1, j, k, ivz)+w(i, j, k, ivz))
   a2avgd = half*(((gammad(i+1, j, k)*p(i+1, j, k)+gamma(i+1, j, &
   &            k)*pd(i+1, j, k))*w(i+1, j, k, irho)-gamma(i+1, j, k)*p(i+1&
   &            , j, k)*wd(i+1, j, k, irho))/w(i+1, j, k, irho)**2+((gammad(&
   &            i, j, k)*p(i, j, k)+gamma(i, j, k)*pd(i, j, k))*w(i, j, k, &
   &            irho)-gamma(i, j, k)*p(i, j, k)*wd(i, j, k, irho))/w(i, j, k&
   &            , irho)**2)
   a2avg = half*(gamma(i+1, j, k)*p(i+1, j, k)/w(i+1, j, k, irho)&
   &            +gamma(i, j, k)*p(i, j, k)/w(i, j, k, irho))
   sx = si(i, j, k, 1)
   sy = si(i, j, k, 2)
   sz = si(i, j, k, 3)
   arg1 = sx**2 + sy**2 + sz**2
   area = SQRT(arg1)
   IF (1.e-25_realType .LT. area) THEN
   max1 = area
   ELSE
   max1 = 1.e-25_realType
   END IF
   tmp = one/max1
   sx = sx*tmp
   sy = sy*tmp
   sz = sz*tmp
   alphaavgd = half*(2*uavg*uavgd+2*vavg*vavgd+2*wavg*wavgd)
   alphaavg = half*(uavg**2+vavg**2+wavg**2)
   havgd = alphaavgd + ovgm1d*(a2avg-gm53*kavg) + ovgm1*(a2avgd-&
   &            gm53d*kavg-gm53*kavgd)
   havg = alphaavg + ovgm1*(a2avg-gm53*kavg)
   IF (a2avg .EQ. 0.0) THEN
   aavgd = 0.0
   ELSE
   aavgd = a2avgd/(2.0*SQRT(a2avg))
   END IF
   aavg = SQRT(a2avg)
   unavgd = sx*uavgd + sy*vavgd + sz*wavgd
   unavg = uavg*sx + vavg*sy + wavg*sz
   ovaavgd = -(one*aavgd/aavg**2)
   ovaavg = one/aavg
   ova2avgd = -(one*a2avgd/a2avg**2)
   ova2avg = one/a2avg
   ! The mesh velocity if the face is moving. It must be
   ! divided by the area to obtain a true velocity.
   IF (addgridvelocities) THEN
   sfaced = tmp*sfaceid(i, j, k)
   sface = sfacei(i, j, k)*tmp
   END IF
   IF (unavg - sface + aavg .GE. 0.) THEN
   lam1d = unavgd - sfaced + aavgd
   lam1 = unavg - sface + aavg
   ELSE
   lam1d = -(unavgd-sfaced+aavgd)
   lam1 = -(unavg-sface+aavg)
   END IF
   IF (unavg - sface - aavg .GE. 0.) THEN
   lam2d = unavgd - sfaced - aavgd
   lam2 = unavg - sface - aavg
   ELSE
   lam2d = -(unavgd-sfaced-aavgd)
   lam2 = -(unavg-sface-aavg)
   END IF
   IF (unavg - sface .GE. 0.) THEN
   lam3d = unavgd - sfaced
   lam3 = unavg - sface
   ELSE
   lam3d = -(unavgd-sfaced)
   lam3 = -(unavg-sface)
   END IF
   rradd = lam3d + aavgd
   rrad = lam3 + aavg
   IF (lam1 .LT. epsacoustic*rrad) THEN
   lam1d = epsacoustic*rradd
   lam1 = epsacoustic*rrad
   ELSE
   lam1 = lam1
   END IF
   IF (lam2 .LT. epsacoustic*rrad) THEN
   lam2d = epsacoustic*rradd
   lam2 = epsacoustic*rrad
   ELSE
   lam2 = lam2
   END IF
   IF (lam3 .LT. epsshear*rrad) THEN
   lam3d = epsshear*rradd
   lam3 = epsshear*rrad
   ELSE
   lam3 = lam3
   END IF
   ! Multiply the eigenvalues by the area to obtain
   ! the correct values for the dissipation term.
   lam1d = area*lam1d
   lam1 = lam1*area
   lam2d = area*lam2d
   lam2 = lam2*area
   lam3d = area*lam3d
   lam3 = lam3*area
   ! Some abbreviations, which occur quite often in the
   ! dissipation terms.
   abv1d = half*(lam1d+lam2d)
   abv1 = half*(lam1+lam2)
   abv2d = half*(lam1d-lam2d)
   abv2 = half*(lam1-lam2)
   abv3d = abv1d - lam3d
   abv3 = abv1 - lam3
   abv4d = gm1d*(alphaavg*dr-uavg*dru-vavg*drv-wavg*drw+dre) + &
   &            gm1*(alphaavgd*dr+alphaavg*drd-uavgd*dru-uavg*drud-vavgd*drv&
   &            -vavg*drvd-wavgd*drw-wavg*drwd+dred) - gm53d*drk - gm53*drkd
   abv4 = gm1*(alphaavg*dr-uavg*dru-vavg*drv-wavg*drw+dre) - gm53&
   &            *drk
   abv5d = sx*drud + sy*drvd + sz*drwd - unavgd*dr - unavg*drd
   abv5 = sx*dru + sy*drv + sz*drw - unavg*dr
   abv6d = (abv3d*abv4+abv3*abv4d)*ova2avg + abv3*abv4*ova2avgd +&
   &            (abv2d*abv5+abv2*abv5d)*ovaavg + abv2*abv5*ovaavgd
   abv6 = abv3*abv4*ova2avg + abv2*abv5*ovaavg
   abv7d = (abv2d*abv4+abv2*abv4d)*ovaavg + abv2*abv4*ovaavgd + &
   &            abv3d*abv5 + abv3*abv5d
   abv7 = abv2*abv4*ovaavg + abv3*abv5
   ! Compute and scatter the dissipative flux.
   ! Density.
   fsd = lam3d*dr + lam3*drd + abv6d
   fs = lam3*dr + abv6
   fwd(i+1, j, k, irho) = fwd(i+1, j, k, irho) + fsd
   fw(i+1, j, k, irho) = fw(i+1, j, k, irho) + fs
   fwd(i, j, k, irho) = fwd(i, j, k, irho) - fsd
   fw(i, j, k, irho) = fw(i, j, k, irho) - fs
   ! X-momentum.
   fsd = lam3d*dru + lam3*drud + uavgd*abv6 + uavg*abv6d + sx*&
   &            abv7d
   fs = lam3*dru + uavg*abv6 + sx*abv7
   fwd(i+1, j, k, imx) = fwd(i+1, j, k, imx) + fsd
   fw(i+1, j, k, imx) = fw(i+1, j, k, imx) + fs
   fwd(i, j, k, imx) = fwd(i, j, k, imx) - fsd
   fw(i, j, k, imx) = fw(i, j, k, imx) - fs
   ! Y-momentum.
   fsd = lam3d*drv + lam3*drvd + vavgd*abv6 + vavg*abv6d + sy*&
   &            abv7d
   fs = lam3*drv + vavg*abv6 + sy*abv7
   fwd(i+1, j, k, imy) = fwd(i+1, j, k, imy) + fsd
   fw(i+1, j, k, imy) = fw(i+1, j, k, imy) + fs
   fwd(i, j, k, imy) = fwd(i, j, k, imy) - fsd
   fw(i, j, k, imy) = fw(i, j, k, imy) - fs
   ! Z-momentum.
   fsd = lam3d*drw + lam3*drwd + wavgd*abv6 + wavg*abv6d + sz*&
   &            abv7d
   fs = lam3*drw + wavg*abv6 + sz*abv7
   fwd(i+1, j, k, imz) = fwd(i+1, j, k, imz) + fsd
   fw(i+1, j, k, imz) = fw(i+1, j, k, imz) + fs
   fwd(i, j, k, imz) = fwd(i, j, k, imz) - fsd
   fw(i, j, k, imz) = fw(i, j, k, imz) - fs
   ! Energy.
   fsd = lam3d*dre + lam3*dred + havgd*abv6 + havg*abv6d + unavgd&
   &            *abv7 + unavg*abv7d
   fs = lam3*dre + havg*abv6 + unavg*abv7
   fwd(i+1, j, k, irhoe) = fwd(i+1, j, k, irhoe) + fsd
   fw(i+1, j, k, irhoe) = fw(i+1, j, k, irhoe) + fs
   fwd(i, j, k, irhoe) = fwd(i, j, k, irhoe) - fsd
   fw(i, j, k, irhoe) = fw(i, j, k, irhoe) - fs
   END DO
   END DO
   END DO
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Dissipative fluxes in the j-direction.                         *
   !      *                                                                *
   !      ******************************************************************
   !
   DO k=2,kl
   DO j=1,jl
   DO i=2,il
   ! Compute the dissipation coefficient for this face.
   ppor = zero
   IF (porj(i, j, k) .EQ. normalflux) ppor = one
   dis0 = fis0*ppor
   ! Construct the vector of the first differences multiplied
   ! by dis0.
   drd = dis0*(wd(i, j+1, k, irho)-wd(i, j, k, irho))
   dr = dis0*(w(i, j+1, k, irho)-w(i, j, k, irho))
   drud = dis0*(wd(i, j+1, k, irho)*w(i, j+1, k, ivx)+w(i, j+1, k&
   &            , irho)*wd(i, j+1, k, ivx)-wd(i, j, k, irho)*w(i, j, k, ivx)&
   &            -w(i, j, k, irho)*wd(i, j, k, ivx))
   dru = dis0*(w(i, j+1, k, irho)*w(i, j+1, k, ivx)-w(i, j, k, &
   &            irho)*w(i, j, k, ivx))
   drvd = dis0*(wd(i, j+1, k, irho)*w(i, j+1, k, ivy)+w(i, j+1, k&
   &            , irho)*wd(i, j+1, k, ivy)-wd(i, j, k, irho)*w(i, j, k, ivy)&
   &            -w(i, j, k, irho)*wd(i, j, k, ivy))
   drv = dis0*(w(i, j+1, k, irho)*w(i, j+1, k, ivy)-w(i, j, k, &
   &            irho)*w(i, j, k, ivy))
   drwd = dis0*(wd(i, j+1, k, irho)*w(i, j+1, k, ivz)+w(i, j+1, k&
   &            , irho)*wd(i, j+1, k, ivz)-wd(i, j, k, irho)*w(i, j, k, ivz)&
   &            -w(i, j, k, irho)*wd(i, j, k, ivz))
   drw = dis0*(w(i, j+1, k, irho)*w(i, j+1, k, ivz)-w(i, j, k, &
   &            irho)*w(i, j, k, ivz))
   dred = dis0*(wd(i, j+1, k, irhoe)-wd(i, j, k, irhoe))
   dre = dis0*(w(i, j+1, k, irhoe)-w(i, j, k, irhoe))
   ! In case a k-equation is present, compute the difference
   ! of rhok and store the average value of k. If not present,
   ! set both these values to zero, such that later on no
   ! decision needs to be made anymore.
   IF (correctfork) THEN
   drkd = dis0*(wd(i, j+1, k, irho)*w(i, j+1, k, itu1)+w(i, j+1&
   &              , k, irho)*wd(i, j+1, k, itu1)-wd(i, j, k, irho)*w(i, j, k&
   &              , itu1)-w(i, j, k, irho)*wd(i, j, k, itu1))
   drk = dis0*(w(i, j+1, k, irho)*w(i, j+1, k, itu1)-w(i, j, k&
   &              , irho)*w(i, j, k, itu1))
   kavgd = half*(wd(i, j+1, k, itu1)+wd(i, j, k, itu1))
   kavg = half*(w(i, j+1, k, itu1)+w(i, j, k, itu1))
   ELSE
   drk = zero
   kavg = zero
   kavgd = 0.0
   drkd = 0.0
   END IF
   ! Compute the average value of gamma and compute some
   ! expressions in which it occurs.
   gammaavgd = half*(gammad(i, j+1, k)+gammad(i, j, k))
   gammaavg = half*(gamma(i, j+1, k)+gamma(i, j, k))
   gm1d = gammaavgd
   gm1 = gammaavg - one
   ovgm1d = -(one*gm1d/gm1**2)
   ovgm1 = one/gm1
   gm53d = gammaavgd
   gm53 = gammaavg - five*third
   ! Compute the average state at the interface.
   uavgd = half*(wd(i, j+1, k, ivx)+wd(i, j, k, ivx))
   uavg = half*(w(i, j+1, k, ivx)+w(i, j, k, ivx))
   vavgd = half*(wd(i, j+1, k, ivy)+wd(i, j, k, ivy))
   vavg = half*(w(i, j+1, k, ivy)+w(i, j, k, ivy))
   wavgd = half*(wd(i, j+1, k, ivz)+wd(i, j, k, ivz))
   wavg = half*(w(i, j+1, k, ivz)+w(i, j, k, ivz))
   a2avgd = half*(((gammad(i, j+1, k)*p(i, j+1, k)+gamma(i, j+1, &
   &            k)*pd(i, j+1, k))*w(i, j+1, k, irho)-gamma(i, j+1, k)*p(i, j&
   &            +1, k)*wd(i, j+1, k, irho))/w(i, j+1, k, irho)**2+((gammad(i&
   &            , j, k)*p(i, j, k)+gamma(i, j, k)*pd(i, j, k))*w(i, j, k, &
   &            irho)-gamma(i, j, k)*p(i, j, k)*wd(i, j, k, irho))/w(i, j, k&
   &            , irho)**2)
   a2avg = half*(gamma(i, j+1, k)*p(i, j+1, k)/w(i, j+1, k, irho)&
   &            +gamma(i, j, k)*p(i, j, k)/w(i, j, k, irho))
   sx = sj(i, j, k, 1)
   sy = sj(i, j, k, 2)
   sz = sj(i, j, k, 3)
   arg1 = sx**2 + sy**2 + sz**2
   area = SQRT(arg1)
   IF (1.e-25_realType .LT. area) THEN
   max2 = area
   ELSE
   max2 = 1.e-25_realType
   END IF
   tmp = one/max2
   sx = sx*tmp
   sy = sy*tmp
   sz = sz*tmp
   alphaavgd = half*(2*uavg*uavgd+2*vavg*vavgd+2*wavg*wavgd)
   alphaavg = half*(uavg**2+vavg**2+wavg**2)
   havgd = alphaavgd + ovgm1d*(a2avg-gm53*kavg) + ovgm1*(a2avgd-&
   &            gm53d*kavg-gm53*kavgd)
   havg = alphaavg + ovgm1*(a2avg-gm53*kavg)
   IF (a2avg .EQ. 0.0) THEN
   aavgd = 0.0
   ELSE
   aavgd = a2avgd/(2.0*SQRT(a2avg))
   END IF
   aavg = SQRT(a2avg)
   unavgd = sx*uavgd + sy*vavgd + sz*wavgd
   unavg = uavg*sx + vavg*sy + wavg*sz
   ovaavgd = -(one*aavgd/aavg**2)
   ovaavg = one/aavg
   ova2avgd = -(one*a2avgd/a2avg**2)
   ova2avg = one/a2avg
   ! The mesh velocity if the face is moving. It must be
   ! divided by the area to obtain a true velocity.
   IF (addgridvelocities) THEN
   sfaced = tmp*sfacejd(i, j, k)
   sface = sfacej(i, j, k)*tmp
   END IF
   IF (unavg - sface + aavg .GE. 0.) THEN
   lam1d = unavgd - sfaced + aavgd
   lam1 = unavg - sface + aavg
   ELSE
   lam1d = -(unavgd-sfaced+aavgd)
   lam1 = -(unavg-sface+aavg)
   END IF
   IF (unavg - sface - aavg .GE. 0.) THEN
   lam2d = unavgd - sfaced - aavgd
   lam2 = unavg - sface - aavg
   ELSE
   lam2d = -(unavgd-sfaced-aavgd)
   lam2 = -(unavg-sface-aavg)
   END IF
   IF (unavg - sface .GE. 0.) THEN
   lam3d = unavgd - sfaced
   lam3 = unavg - sface
   ELSE
   lam3d = -(unavgd-sfaced)
   lam3 = -(unavg-sface)
   END IF
   rradd = lam3d + aavgd
   rrad = lam3 + aavg
   IF (lam1 .LT. epsacoustic*rrad) THEN
   lam1d = epsacoustic*rradd
   lam1 = epsacoustic*rrad
   ELSE
   lam1 = lam1
   END IF
   IF (lam2 .LT. epsacoustic*rrad) THEN
   lam2d = epsacoustic*rradd
   lam2 = epsacoustic*rrad
   ELSE
   lam2 = lam2
   END IF
   IF (lam3 .LT. epsshear*rrad) THEN
   lam3d = epsshear*rradd
   lam3 = epsshear*rrad
   ELSE
   lam3 = lam3
   END IF
   ! Multiply the eigenvalues by the area to obtain
   ! the correct values for the dissipation term.
   lam1d = area*lam1d
   lam1 = lam1*area
   lam2d = area*lam2d
   lam2 = lam2*area
   lam3d = area*lam3d
   lam3 = lam3*area
   ! Some abbreviations, which occur quite often in the
   ! dissipation terms.
   abv1d = half*(lam1d+lam2d)
   abv1 = half*(lam1+lam2)
   abv2d = half*(lam1d-lam2d)
   abv2 = half*(lam1-lam2)
   abv3d = abv1d - lam3d
   abv3 = abv1 - lam3
   abv4d = gm1d*(alphaavg*dr-uavg*dru-vavg*drv-wavg*drw+dre) + &
   &            gm1*(alphaavgd*dr+alphaavg*drd-uavgd*dru-uavg*drud-vavgd*drv&
   &            -vavg*drvd-wavgd*drw-wavg*drwd+dred) - gm53d*drk - gm53*drkd
   abv4 = gm1*(alphaavg*dr-uavg*dru-vavg*drv-wavg*drw+dre) - gm53&
   &            *drk
   abv5d = sx*drud + sy*drvd + sz*drwd - unavgd*dr - unavg*drd
   abv5 = sx*dru + sy*drv + sz*drw - unavg*dr
   abv6d = (abv3d*abv4+abv3*abv4d)*ova2avg + abv3*abv4*ova2avgd +&
   &            (abv2d*abv5+abv2*abv5d)*ovaavg + abv2*abv5*ovaavgd
   abv6 = abv3*abv4*ova2avg + abv2*abv5*ovaavg
   abv7d = (abv2d*abv4+abv2*abv4d)*ovaavg + abv2*abv4*ovaavgd + &
   &            abv3d*abv5 + abv3*abv5d
   abv7 = abv2*abv4*ovaavg + abv3*abv5
   ! Compute and scatter the dissipative flux.
   ! Density.
   fsd = lam3d*dr + lam3*drd + abv6d
   fs = lam3*dr + abv6
   fwd(i, j+1, k, irho) = fwd(i, j+1, k, irho) + fsd
   fw(i, j+1, k, irho) = fw(i, j+1, k, irho) + fs
   fwd(i, j, k, irho) = fwd(i, j, k, irho) - fsd
   fw(i, j, k, irho) = fw(i, j, k, irho) - fs
   ! X-momentum.
   fsd = lam3d*dru + lam3*drud + uavgd*abv6 + uavg*abv6d + sx*&
   &            abv7d
   fs = lam3*dru + uavg*abv6 + sx*abv7
   fwd(i, j+1, k, imx) = fwd(i, j+1, k, imx) + fsd
   fw(i, j+1, k, imx) = fw(i, j+1, k, imx) + fs
   fwd(i, j, k, imx) = fwd(i, j, k, imx) - fsd
   fw(i, j, k, imx) = fw(i, j, k, imx) - fs
   ! Y-momentum.
   fsd = lam3d*drv + lam3*drvd + vavgd*abv6 + vavg*abv6d + sy*&
   &            abv7d
   fs = lam3*drv + vavg*abv6 + sy*abv7
   fwd(i, j+1, k, imy) = fwd(i, j+1, k, imy) + fsd
   fw(i, j+1, k, imy) = fw(i, j+1, k, imy) + fs
   fwd(i, j, k, imy) = fwd(i, j, k, imy) - fsd
   fw(i, j, k, imy) = fw(i, j, k, imy) - fs
   ! Z-momentum.
   fsd = lam3d*drw + lam3*drwd + wavgd*abv6 + wavg*abv6d + sz*&
   &            abv7d
   fs = lam3*drw + wavg*abv6 + sz*abv7
   fwd(i, j+1, k, imz) = fwd(i, j+1, k, imz) + fsd
   fw(i, j+1, k, imz) = fw(i, j+1, k, imz) + fs
   fwd(i, j, k, imz) = fwd(i, j, k, imz) - fsd
   fw(i, j, k, imz) = fw(i, j, k, imz) - fs
   ! Energy.
   fsd = lam3d*dre + lam3*dred + havgd*abv6 + havg*abv6d + unavgd&
   &            *abv7 + unavg*abv7d
   fs = lam3*dre + havg*abv6 + unavg*abv7
   fwd(i, j+1, k, irhoe) = fwd(i, j+1, k, irhoe) + fsd
   fw(i, j+1, k, irhoe) = fw(i, j+1, k, irhoe) + fs
   fwd(i, j, k, irhoe) = fwd(i, j, k, irhoe) - fsd
   fw(i, j, k, irhoe) = fw(i, j, k, irhoe) - fs
   END DO
   END DO
   END DO
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Dissipative fluxes in the k-direction.                         *
   !      *                                                                *
   !      ******************************************************************
   !
   DO k=1,kl
   DO j=2,jl
   DO i=2,il
   ! Compute the dissipation coefficient for this face.
   ppor = zero
   IF (pork(i, j, k) .EQ. normalflux) ppor = one
   dis0 = fis0*ppor
   ! Construct the vector of the first differences multiplied
   ! by dis0.
   drd = dis0*(wd(i, j, k+1, irho)-wd(i, j, k, irho))
   dr = dis0*(w(i, j, k+1, irho)-w(i, j, k, irho))
   drud = dis0*(wd(i, j, k+1, irho)*w(i, j, k+1, ivx)+w(i, j, k+1&
   &            , irho)*wd(i, j, k+1, ivx)-wd(i, j, k, irho)*w(i, j, k, ivx)&
   &            -w(i, j, k, irho)*wd(i, j, k, ivx))
   dru = dis0*(w(i, j, k+1, irho)*w(i, j, k+1, ivx)-w(i, j, k, &
   &            irho)*w(i, j, k, ivx))
   drvd = dis0*(wd(i, j, k+1, irho)*w(i, j, k+1, ivy)+w(i, j, k+1&
   &            , irho)*wd(i, j, k+1, ivy)-wd(i, j, k, irho)*w(i, j, k, ivy)&
   &            -w(i, j, k, irho)*wd(i, j, k, ivy))
   drv = dis0*(w(i, j, k+1, irho)*w(i, j, k+1, ivy)-w(i, j, k, &
   &            irho)*w(i, j, k, ivy))
   drwd = dis0*(wd(i, j, k+1, irho)*w(i, j, k+1, ivz)+w(i, j, k+1&
   &            , irho)*wd(i, j, k+1, ivz)-wd(i, j, k, irho)*w(i, j, k, ivz)&
   &            -w(i, j, k, irho)*wd(i, j, k, ivz))
   drw = dis0*(w(i, j, k+1, irho)*w(i, j, k+1, ivz)-w(i, j, k, &
   &            irho)*w(i, j, k, ivz))
   dred = dis0*(wd(i, j, k+1, irhoe)-wd(i, j, k, irhoe))
   dre = dis0*(w(i, j, k+1, irhoe)-w(i, j, k, irhoe))
   ! In case a k-equation is present, compute the difference
   ! of rhok and store the average value of k. If not present,
   ! set both these values to zero, such that later on no
   ! decision needs to be made anymore.
   IF (correctfork) THEN
   drkd = dis0*(wd(i, j, k+1, irho)*w(i, j, k+1, itu1)+w(i, j, &
   &              k+1, irho)*wd(i, j, k+1, itu1)-wd(i, j, k, irho)*w(i, j, k&
   &              , itu1)-w(i, j, k, irho)*wd(i, j, k, itu1))
   drk = dis0*(w(i, j, k+1, irho)*w(i, j, k+1, itu1)-w(i, j, k&
   &              , irho)*w(i, j, k, itu1))
   kavgd = half*(wd(i, j, k+1, itu1)+wd(i, j, k, itu1))
   kavg = half*(w(i, j, k+1, itu1)+w(i, j, k, itu1))
   ELSE
   drk = zero
   kavg = zero
   kavgd = 0.0
   drkd = 0.0
   END IF
   ! Compute the average value of gamma and compute some
   ! expressions in which it occurs.
   gammaavgd = half*(gammad(i, j, k+1)+gammad(i, j, k))
   gammaavg = half*(gamma(i, j, k+1)+gamma(i, j, k))
   gm1d = gammaavgd
   gm1 = gammaavg - one
   ovgm1d = -(one*gm1d/gm1**2)
   ovgm1 = one/gm1
   gm53d = gammaavgd
   gm53 = gammaavg - five*third
   ! Compute the average state at the interface.
   uavgd = half*(wd(i, j, k+1, ivx)+wd(i, j, k, ivx))
   uavg = half*(w(i, j, k+1, ivx)+w(i, j, k, ivx))
   vavgd = half*(wd(i, j, k+1, ivy)+wd(i, j, k, ivy))
   vavg = half*(w(i, j, k+1, ivy)+w(i, j, k, ivy))
   wavgd = half*(wd(i, j, k+1, ivz)+wd(i, j, k, ivz))
   wavg = half*(w(i, j, k+1, ivz)+w(i, j, k, ivz))
   a2avgd = half*(((gammad(i, j, k+1)*p(i, j, k+1)+gamma(i, j, k+&
   &            1)*pd(i, j, k+1))*w(i, j, k+1, irho)-gamma(i, j, k+1)*p(i, j&
   &            , k+1)*wd(i, j, k+1, irho))/w(i, j, k+1, irho)**2+((gammad(i&
   &            , j, k)*p(i, j, k)+gamma(i, j, k)*pd(i, j, k))*w(i, j, k, &
   &            irho)-gamma(i, j, k)*p(i, j, k)*wd(i, j, k, irho))/w(i, j, k&
   &            , irho)**2)
   a2avg = half*(gamma(i, j, k+1)*p(i, j, k+1)/w(i, j, k+1, irho)&
   &            +gamma(i, j, k)*p(i, j, k)/w(i, j, k, irho))
   sx = sk(i, j, k, 1)
   sy = sk(i, j, k, 2)
   sz = sk(i, j, k, 3)
   arg1 = sx**2 + sy**2 + sz**2
   area = SQRT(arg1)
   IF (1.e-25_realType .LT. area) THEN
   max3 = area
   ELSE
   max3 = 1.e-25_realType
   END IF
   tmp = one/max3
   sx = sx*tmp
   sy = sy*tmp
   sz = sz*tmp
   alphaavgd = half*(2*uavg*uavgd+2*vavg*vavgd+2*wavg*wavgd)
   alphaavg = half*(uavg**2+vavg**2+wavg**2)
   havgd = alphaavgd + ovgm1d*(a2avg-gm53*kavg) + ovgm1*(a2avgd-&
   &            gm53d*kavg-gm53*kavgd)
   havg = alphaavg + ovgm1*(a2avg-gm53*kavg)
   IF (a2avg .EQ. 0.0) THEN
   aavgd = 0.0
   ELSE
   aavgd = a2avgd/(2.0*SQRT(a2avg))
   END IF
   aavg = SQRT(a2avg)
   unavgd = sx*uavgd + sy*vavgd + sz*wavgd
   unavg = uavg*sx + vavg*sy + wavg*sz
   ovaavgd = -(one*aavgd/aavg**2)
   ovaavg = one/aavg
   ova2avgd = -(one*a2avgd/a2avg**2)
   ova2avg = one/a2avg
   ! The mesh velocity if the face is moving. It must be
   ! divided by the area to obtain a true velocity.
   IF (addgridvelocities) THEN
   sfaced = tmp*sfacekd(i, j, k)
   sface = sfacek(i, j, k)*tmp
   END IF
   IF (unavg - sface + aavg .GE. 0.) THEN
   lam1d = unavgd - sfaced + aavgd
   lam1 = unavg - sface + aavg
   ELSE
   lam1d = -(unavgd-sfaced+aavgd)
   lam1 = -(unavg-sface+aavg)
   END IF
   IF (unavg - sface - aavg .GE. 0.) THEN
   lam2d = unavgd - sfaced - aavgd
   lam2 = unavg - sface - aavg
   ELSE
   lam2d = -(unavgd-sfaced-aavgd)
   lam2 = -(unavg-sface-aavg)
   END IF
   IF (unavg - sface .GE. 0.) THEN
   lam3d = unavgd - sfaced
   lam3 = unavg - sface
   ELSE
   lam3d = -(unavgd-sfaced)
   lam3 = -(unavg-sface)
   END IF
   rradd = lam3d + aavgd
   rrad = lam3 + aavg
   IF (lam1 .LT. epsacoustic*rrad) THEN
   lam1d = epsacoustic*rradd
   lam1 = epsacoustic*rrad
   ELSE
   lam1 = lam1
   END IF
   IF (lam2 .LT. epsacoustic*rrad) THEN
   lam2d = epsacoustic*rradd
   lam2 = epsacoustic*rrad
   ELSE
   lam2 = lam2
   END IF
   IF (lam3 .LT. epsshear*rrad) THEN
   lam3d = epsshear*rradd
   lam3 = epsshear*rrad
   ELSE
   lam3 = lam3
   END IF
   ! Multiply the eigenvalues by the area to obtain
   ! the correct values for the dissipation term.
   lam1d = area*lam1d
   lam1 = lam1*area
   lam2d = area*lam2d
   lam2 = lam2*area
   lam3d = area*lam3d
   lam3 = lam3*area
   ! Some abbreviations, which occur quite often in the
   ! dissipation terms.
   abv1d = half*(lam1d+lam2d)
   abv1 = half*(lam1+lam2)
   abv2d = half*(lam1d-lam2d)
   abv2 = half*(lam1-lam2)
   abv3d = abv1d - lam3d
   abv3 = abv1 - lam3
   abv4d = gm1d*(alphaavg*dr-uavg*dru-vavg*drv-wavg*drw+dre) + &
   &            gm1*(alphaavgd*dr+alphaavg*drd-uavgd*dru-uavg*drud-vavgd*drv&
   &            -vavg*drvd-wavgd*drw-wavg*drwd+dred) - gm53d*drk - gm53*drkd
   abv4 = gm1*(alphaavg*dr-uavg*dru-vavg*drv-wavg*drw+dre) - gm53&
   &            *drk
   abv5d = sx*drud + sy*drvd + sz*drwd - unavgd*dr - unavg*drd
   abv5 = sx*dru + sy*drv + sz*drw - unavg*dr
   abv6d = (abv3d*abv4+abv3*abv4d)*ova2avg + abv3*abv4*ova2avgd +&
   &            (abv2d*abv5+abv2*abv5d)*ovaavg + abv2*abv5*ovaavgd
   abv6 = abv3*abv4*ova2avg + abv2*abv5*ovaavg
   abv7d = (abv2d*abv4+abv2*abv4d)*ovaavg + abv2*abv4*ovaavgd + &
   &            abv3d*abv5 + abv3*abv5d
   abv7 = abv2*abv4*ovaavg + abv3*abv5
   ! Compute and scatter the dissipative flux.
   ! Density.
   fsd = lam3d*dr + lam3*drd + abv6d
   fs = lam3*dr + abv6
   fwd(i, j, k+1, irho) = fwd(i, j, k+1, irho) + fsd
   fw(i, j, k+1, irho) = fw(i, j, k+1, irho) + fs
   fwd(i, j, k, irho) = fwd(i, j, k, irho) - fsd
   fw(i, j, k, irho) = fw(i, j, k, irho) - fs
   ! X-momentum.
   fsd = lam3d*dru + lam3*drud + uavgd*abv6 + uavg*abv6d + sx*&
   &            abv7d
   fs = lam3*dru + uavg*abv6 + sx*abv7
   fwd(i, j, k+1, imx) = fwd(i, j, k+1, imx) + fsd
   fw(i, j, k+1, imx) = fw(i, j, k+1, imx) + fs
   fwd(i, j, k, imx) = fwd(i, j, k, imx) - fsd
   fw(i, j, k, imx) = fw(i, j, k, imx) - fs
   ! Y-momentum.
   fsd = lam3d*drv + lam3*drvd + vavgd*abv6 + vavg*abv6d + sy*&
   &            abv7d
   fs = lam3*drv + vavg*abv6 + sy*abv7
   fwd(i, j, k+1, imy) = fwd(i, j, k+1, imy) + fsd
   fw(i, j, k+1, imy) = fw(i, j, k+1, imy) + fs
   fwd(i, j, k, imy) = fwd(i, j, k, imy) - fsd
   fw(i, j, k, imy) = fw(i, j, k, imy) - fs
   ! Z-momentum.
   fsd = lam3d*drw + lam3*drwd + wavgd*abv6 + wavg*abv6d + sz*&
   &            abv7d
   fs = lam3*drw + wavg*abv6 + sz*abv7
   fwd(i, j, k+1, imz) = fwd(i, j, k+1, imz) + fsd
   fw(i, j, k+1, imz) = fw(i, j, k+1, imz) + fs
   fwd(i, j, k, imz) = fwd(i, j, k, imz) - fsd
   fw(i, j, k, imz) = fw(i, j, k, imz) - fs
   ! Energy.
   fsd = lam3d*dre + lam3*dred + havgd*abv6 + havg*abv6d + unavgd&
   &            *abv7 + unavg*abv7d
   fs = lam3*dre + havg*abv6 + unavg*abv7
   fwd(i, j, k+1, irhoe) = fwd(i, j, k+1, irhoe) + fsd
   fw(i, j, k+1, irhoe) = fw(i, j, k+1, irhoe) + fs
   fwd(i, j, k, irhoe) = fwd(i, j, k, irhoe) - fsd
   fw(i, j, k, irhoe) = fw(i, j, k, irhoe) - fs
   END DO
   END DO
   END DO
   END IF
   END SUBROUTINE INVISCIDDISSFLUXMATRIXCOARSE_EXTRA_D
