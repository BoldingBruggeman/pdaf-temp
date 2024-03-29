! Copyright (c) 2014-2020 Paul Kirchgessner
!
! This file is part of PDAF.
!
! PDAF is free software: you can redistribute it and/or modify
! it under the terms of the GNU Lesser General Public License
! as published by the Free Software Foundation, either version
! 3 of the License, or (at your option) any later version.
!
! PDAF is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
! GNU Lesser General Public License for more details.
!
! You should have received a copy of the GNU Lesser General Public
! License along with PDAF.  If not, see <http://www.gnu.org/licenses/>.
!
!$Id: PDAF-D_lnetf_memtime.F90 374 2020-02-26 12:49:56Z lnerger $
!BOP
!
! !ROUTINE: PDAF_lnetf_memtime --- Display timing and memory information for LNETF
!
! !INTERFACE:
SUBROUTINE PDAF_lnetf_memtime(printtype)

! !DESCRIPTION:
! This routine displays the PDAF-internal timing and
! memory information for the LNETF.
!
! !  This is a core routine of PDAF and
!    should not be changed by the user   !
!
! !REVISION HISTORY:
! 2014-05 - Paul Kirchgessner - Initial code based on LETKF code
! Later revisions - see svn log
!
! !USES:
  USE PDAF_timer, &
       ONLY: PDAF_time_tot
  USE PDAF_memcounting, &
       ONLY: PDAF_memcount_get
  USE PDAF_mod_filter, &
       ONLY: subtype_filter, dim_lag, type_forget
  USE PDAF_mod_filterMPI, &
       ONLY: filterpe

  IMPLICIT NONE

! !ARGUMENTS:
  INTEGER, INTENT(in) :: printtype    ! Type of screen output:  
                                      ! (1) timings, (2) memory
!EOP

! *** Local variables ***
  INTEGER :: i   ! Counter


! ********************************
! *** Print screen information ***
! ********************************

  ptype: IF (printtype == 1 .and. filterpe) THEN

! **************************************
! *** Print basic timing information ***
! **************************************

     ! Generic part
     WRITE (*, '(//a, 21x, a)') 'PDAF', 'PDAF Timing information'
     WRITE (*, '(a, 10x, 45a)') 'PDAF', ('-', i=1, 45)
     WRITE (*, '(a, 18x, a, F11.3, 1x, a)') 'PDAF', 'Initialize PDAF:', pdaf_time_tot(1), 's'
     IF (subtype_filter /= 5) THEN
        IF (subtype_filter<2) THEN
           WRITE (*, '(a, 16x, a, F11.3, 1x, a)') 'PDAF', 'Ensemble forecast:', pdaf_time_tot(2), 's'
        ELSE
           WRITE (*, '(a, 19x, a, F11.3, 1x, a)') 'PDAF', 'State forecast:', pdaf_time_tot(2), 's'
        END IF
     END IF

     IF (filterpe) THEN
        ! Filter-specific part
        WRITE (*, '(a, 18x, a, 1x, F11.3, 1x, a)') 'PDAF', 'LNETF analysis:', pdaf_time_tot(3), 's'

        ! Generic part B
        WRITE (*, '(a, 22x, a, F11.3, 1x, a)') 'PDAF', 'Prepoststep:', pdaf_time_tot(5), 's'
     END IF

  ELSE IF (printtype == 2 .and. filterpe) THEN ptype

! *******************************
! *** Print allocated memory  ***
! *******************************

     WRITE (*, '(/a, 23x, a)') 'PDAF', 'PDAF Memory overview'
     WRITE (*, '(a, 10x, 45a)') 'PDAF', ('-', i=1, 45)
     WRITE (*, '(a, 21x, a)') 'PDAF', 'Allocated memory  (MiB)'
     WRITE (*, '(a, 14x, a, 1x, f10.3, a)') &
          'PDAF', 'state and A:', pdaf_memcount_get(1, 'M'), ' MiB (persistent)'
     WRITE (*, '(a, 11x, a, 1x, f10.3, a)') &
          'PDAF', 'ensemble array:', pdaf_memcount_get(2, 'M'), ' MiB (persistent)'
     WRITE (*, '(a, 12x, a, 1x, f10.3, a)') &
          'PDAF', 'analysis step:', pdaf_memcount_get(3, 'M'), ' MiB (temporary)'

  ELSE IF (printtype == 3) THEN ptype

! *******************************************************
! *** Print timing information for call-back routines ***
! *******************************************************

     ! Generic part
     WRITE (*, '(//a, 12x, a)') 'PDAF', 'PDAF Timing information - call-back routines'
     WRITE (*, '(a, 8x, 52a)') 'PDAF', ('-', i=1, 52)
     WRITE (*, '(a, 10x, a, 15x, F11.3, 1x, a)') 'PDAF', 'Initialize PDAF:', pdaf_time_tot(1), 's'
     WRITE (*, '(a, 12x, a, 17x, F11.3, 1x, a)') 'PDAF', 'init_ens_pdaf:', pdaf_time_tot(39), 's'
     IF (subtype_filter /= 5) THEN
        IF (subtype_filter<2) THEN
           WRITE (*, '(a, 10x, a, 13x, F11.3, 1x, a)') 'PDAF', 'Ensemble forecast:', pdaf_time_tot(2), 's'
        ELSE
           WRITE (*, '(a, 10x, a, 17x, F11.3, 1x, a)') 'PDAF', 'State forecast:', pdaf_time_tot(2), 's'
        END IF
        WRITE (*, '(a, 12x, a, 5x, F11.3, 1x, a)') 'PDAF', 'MPI communication in PDAF:', pdaf_time_tot(19), 's'
        WRITE (*, '(a, 12x, a, 9x, F11.3, 1x, a)') 'PDAF', 'distribute_state_pdaf:', pdaf_time_tot(40), 's'
        WRITE (*, '(a, 12x, a, 12x, F11.3, 1x, a)') 'PDAF', 'collect_state_pdaf:', pdaf_time_tot(41), 's'
        IF (.not.filterpe) WRITE (*, '(a, 7x, a)') 'PDAF', &
             'Note: for filterpe=F, the time (2) includes the wait time for the analysis step'
     END IF

     IF (filterpe) THEN
        ! Filter-specific part
        WRITE (*, '(a, 10x, a, 16x, F11.3, 1x, a)') 'PDAF', 'LNETF analysis:', pdaf_time_tot(3), 's'
        WRITE (*, '(a, 12x, a, 6x, F11.3, 1x, a)') 'PDAF', 'PDAF-internal operations:', pdaf_time_tot(51), 's'
        WRITE (*, '(a, 12x, a, 11x, F11.3, 1x, a)') 'PDAF', 'init_n_domains_pdaf:', pdaf_time_tot(42), 's'
        WRITE (*, '(a, 12x, a, 11x, F11.3, 1x, a)') 'PDAF', 'init_dim_obs_f_pdaf:', pdaf_time_tot(43), 's'
        WRITE (*, '(a, 12x, a, 17x, F11.3, 1x, a)') 'PDAF', 'obs_op_f_pdaf:', pdaf_time_tot(44), 's'
        IF (type_forget==1) THEN
           WRITE (*, '(a, 12x, a, 15x, F11.3, 1x, a)') 'PDAF', 'init_obs_f_pdaf:', pdaf_time_tot(50), 's'
           WRITE (*, '(a, 12x, a, 14x, F11.3, 1x, a)') 'PDAF', 'init_obsvar_pdaf:', pdaf_time_tot(49), 's'
        END IF
        WRITE (*, '(a, 12x, a, 15x, F11.3, 1x, a)') 'PDAF', 'init_dim_l_pdaf:', pdaf_time_tot(45), 's'
        WRITE (*, '(a, 12x, a, 11x, F11.3, 1x, a)') 'PDAF', 'init_dim_obs_l_pdaf:', pdaf_time_tot(9), 's'
        WRITE (*, '(a, 12x, a, 16x, F11.3, 1x, a)') 'PDAF', 'g2l_state_pdaf:', pdaf_time_tot(15), 's'
        WRITE (*, '(a, 12x, a, 18x, F11.3, 1x, a)') 'PDAF', 'g2l_obs_pdaf:', pdaf_time_tot(46), 's'
        WRITE (*, '(a, 12x, a, 15x, F11.3, 1x, a)') 'PDAF', 'init_obs_l_pdaf:', pdaf_time_tot(21), 's'
        IF (type_forget==1) THEN
           WRITE (*, '(a, 12x, a, 12x, F11.3, 1x, a)') 'PDAF', 'init_obsvar_l_pdaf:', pdaf_time_tot(52), 's'
        END IF
        WRITE (*, '(a, 12x, a, 13x, F11.3, 1x, a)') 'PDAF', 'likelihood_l_pdaf:', pdaf_time_tot(47), 's'
        WRITE (*, '(a, 12x, a, 16x, F11.3, 1x, a)') 'PDAF', 'l2g_state_pdaf:', pdaf_time_tot(16), 's'

        ! Generic part B
        WRITE (*, '(a, 10x, a, 14x, F11.3, 1x, a)') 'PDAF', 'prepoststep_pdaf:', pdaf_time_tot(5), 's'
     END IF

  ELSE IF (printtype == 4 .and. filterpe) THEN ptype

! *********************************************
! *** Print second-level timing information ***
! *********************************************

     ! Generic part
     WRITE (*, '(//a, 21x, a)') 'PDAF', 'PDAF Timing information'
     WRITE (*, '(a, 10x, 45a)') 'PDAF', ('-', i=1, 45)
     WRITE (*, '(a, 21x, a, F11.3, 1x, a)') 'PDAF', 'Initialize PDAF (1):', pdaf_time_tot(1), 's'
     IF (subtype_filter /= 5) THEN
        WRITE (*, '(a, 19x, a, F11.3, 1x, a)') 'PDAF', 'Ensemble forecast (2):', pdaf_time_tot(2), 's'
        WRITE (*, '(a, 12x, a, F11.3, 1x, a)') 'PDAF', 'MPI communication in PDAF (19):', pdaf_time_tot(19), 's'
        IF (.not.filterpe) WRITE (*, '(a, 7x, a)') 'PDAF', &
             'Note: for filterpe=F, the time (2) includes the wait time for the analysis step'
     END IF

     IF (filterpe) THEN
        ! Filter-specific part
        WRITE (*, '(a, 22x, a, F11.3, 1x, a)') 'PDAF', 'LNETF analysis (3):', pdaf_time_tot(3), 's'
        WRITE (*, '(a, 19x, a, F11.3, 1x, a)') 'PDAF', 'global preparations (4):', pdaf_time_tot(4), 's'
        WRITE (*, '(a, 25x, a, F11.3, 1x, a)') 'PDAF', 'get mean state (11):', pdaf_time_tot(11), 's'
        WRITE (*, '(a, 19x, a, F11.3, 1x, a)') 'PDAF', 'local analysis loop (6):', pdaf_time_tot(6), 's'
        WRITE (*, '(a, 16x, a, F11.3, 1x, a)') 'PDAF', 'search local obs. domain (9):', pdaf_time_tot(9), 's'
        WRITE (*, '(a, 24x, a, F11.3, 1x, a)') 'PDAF', 'global to local (15):', pdaf_time_tot(15), 's'
        WRITE (*, '(a, 26x, a, F11.3, 1x, a)') 'PDAF', 'local analysis (7):', pdaf_time_tot(7), 's'
        WRITE (*, '(a, 24x, a, F11.3, 1x, a)') 'PDAF', 'local to global (16):', pdaf_time_tot(16), 's'
        IF (dim_lag >0) THEN
           WRITE (*, '(a, 13x, a, F11.3, 1x, a)') 'PDAF', 'compute smoother transform (17):', pdaf_time_tot(17), 's'
           WRITE (*, '(a, 22x, a, F11.3, 1x, a)') 'PDAF', 'perform smoothing (18):', pdaf_time_tot(18), 's'
        END IF

        ! Generic part B
        WRITE (*, '(a, 25x, a, F11.3, 1x, a)') 'PDAF', 'Prepoststep (5):', pdaf_time_tot(5), 's'
     END IF

  ELSE IF (printtype == 5 .and. filterpe) THEN ptype

! *****************************************
! *** Print detailed timing information ***
! *****************************************

     ! Generic part
     WRITE (*, '(//a, 21x, a)') 'PDAF', 'PDAF Timing information'
     WRITE (*, '(a, 10x, 45a)') 'PDAF', ('-', i=1, 45)
     WRITE (*, '(a, 21x, a, F11.3, 1x, a)') 'PDAF', 'Initialize PDAF (1):', pdaf_time_tot(1), 's'
     IF (subtype_filter /= 5) THEN
        WRITE (*, '(a, 19x, a, F11.3, 1x, a)') 'PDAF', 'Ensemble forecast (2):', pdaf_time_tot(2), 's'
        WRITE (*, '(a, 12x, a, F11.3, 1x, a)') 'PDAF', 'MPI communication in PDAF (19):', pdaf_time_tot(19), 's'
        IF (.not.filterpe) WRITE (*, '(a, 7x, a)') 'PDAF', &
             'Note: for filterpe=F, the time (2) includes the wait time for the analysis step'
     END IF

     IF (filterpe) THEN
        ! Filter-specific part
        WRITE (*, '(a, 22x, a, F11.3, 1x, a)') 'PDAF', 'LNETF analysis (3):', pdaf_time_tot(3), 's'
        WRITE (*, '(a, 19x, a, F11.3, 1x, a)') 'PDAF', 'global preparations (4):', pdaf_time_tot(4), 's'
        IF (dim_lag>0) &
             WRITE (*, '(a, 16x, a, F11.3, 1x, a)') 'PDAF', 'compute HX for smoother (27):', pdaf_time_tot(27), 's'
        IF (type_forget==0 .OR. type_forget==1) &
             WRITE (*, '(a, 16x, a, F11.3, 1x, a)') 'PDAF', 'apply forgetting factor (14):', pdaf_time_tot(14), 's'
        WRITE (*, '(a, 18x, a, F11.3, 1x, a)')  'PDAF', 'compute HX for filter (12):', pdaf_time_tot(12), 's'
        WRITE (*, '(a, 25x, a, F11.3, 1x, a)') 'PDAF', 'get mean state (11):', pdaf_time_tot(11), 's'
        WRITE (*, '(a, 17x, a, F11.3, 1x, a)') 'PDAF', 'generate random matrix (13):', pdaf_time_tot(13), 's'
        WRITE (*, '(a, 19x, a, F11.3, 1x, a)') 'PDAF', 'local analysis loop (6):', pdaf_time_tot(6), 's'
        WRITE (*, '(a, 16x, a, F11.3, 1x, a)') 'PDAF', 'search local obs. domain (9):', pdaf_time_tot(9), 's'
        WRITE (*, '(a, 24x, a, F11.3, 1x, a)') 'PDAF', 'global to local (15):', pdaf_time_tot(15), 's'
        WRITE (*, '(a, 26x, a, F11.3, 1x, a)') 'PDAF', 'local analysis (7):', pdaf_time_tot(7), 's'
        WRITE (*, '(a, 27x, a, F11.3, 1x, a)') 'PDAF', 'init local obs (21):', pdaf_time_tot(21), 's'
        WRITE (*, '(a, 17x, a, F11.3, 1x, a)') 'PDAF', 'compute particle weights (22):', pdaf_time_tot(22), 's'
        WRITE (*, '(a, 32x, a, F11.3, 1x, a)') 'PDAF', 'compute A (23):', pdaf_time_tot(23), 's'
        WRITE (*, '(a, 17x, a, F11.3, 1x, a)') 'PDAF', 'compute transform matrix (24):', pdaf_time_tot(24), 's'
        WRITE (*, '(a, 16x, a, F11.3, 1x, a)') 'PDAF', 'compute SVD of W-ww^t and T (31):', pdaf_time_tot(31), 's'
        WRITE (*, '(a, 17x, a, F11.3, 1x, a)') 'PDAF', 'compute product of T and A (32):', pdaf_time_tot(32), 's'
        WRITE (*, '(a, 24x, a, F11.3, 1x, a)') 'PDAF', 'multiply with svals (33):', pdaf_time_tot(33), 's'
        IF (type_forget==2 .OR. type_forget==3) &
             WRITE (*, '(a, 20x, a, F11.3, 1x, a)') 'PDAF', 'apply forgetting factor (34):', pdaf_time_tot(34), 's'
        WRITE (*, '(a, 24x, a, F11.3, 1x, a)') 'PDAF', 'apply random matrix (35):', pdaf_time_tot(35), 's'
        WRITE (*, '(a, 23x, a, F11.3, 1x, a)') 'PDAF', 'transform ensemble (25):', pdaf_time_tot(25), 's'
        WRITE (*, '(a, 22x, a, F11.3, 1x, a)') 'PDAF', 'store ensemble matrix (36):', pdaf_time_tot(36), 's'
        WRITE (*, '(a, 28x, a, F11.3, 1x, a)') 'PDAF', 'update ensemble (37):', pdaf_time_tot(37), 's'

        WRITE (*, '(a, 24x, a, F11.3, 1x, a)') 'PDAF', 'local to global (16):', pdaf_time_tot(16), 's'
        IF (dim_lag >0) THEN
           WRITE (*, '(a, 13x, a, F11.3, 1x, a)') 'PDAF', 'compute smoother transform (17):', pdaf_time_tot(17), 's'
           WRITE (*, '(a, 22x, a, F11.3, 1x, a)') 'PDAF', 'perform smoothing (18):', pdaf_time_tot(18), 's'
        END IF
        
        ! Generic part B
        WRITE (*, '(a, 25x, a, F11.3, 1x, a)') 'PDAF', 'Prepoststep (5):', pdaf_time_tot(5), 's'
     END IF
  END IF ptype


END SUBROUTINE PDAF_lnetf_memtime
