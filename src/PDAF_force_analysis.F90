! Copyright (c) 2004-2020 Lars Nerger
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
!$Id: PDAF_force_analysis.F90 666 2021-02-18 17:16:31Z lnerger $
!BOP
!
! !ROUTINE: PDAF_force_analysis --- Set ensemble index to force an analysis step
!
! !INTERFACE:
SUBROUTINE PDAF_force_analysis()

! !DESCRIPTION:
! Helper routine for PDAF.
! The routine overwrite member index of the ensemble 
! state by local_dim_ens and the counter cnt_steps
! by nsteps-1. This forces that the analysis
! step is executed at the next call to PDAF_put_state
! or PDAF_assimilate.
!
! !  This is a core routine of PDAF and
!    should not be changed by the user   !
!
! !REVISION HISTORY:
! 2021-02 - Lars Nerger - Initial code
! Later revisions - see svn log
!
! !USES:
  USE PDAF_mod_filter, &
       ONLY: member, local_dim_ens, nsteps, cnt_steps

  IMPLICIT NONE
!EOP

! *** Set ensemble member ***

  member = local_dim_ens
  
  cnt_steps = nsteps - 1

END SUBROUTINE PDAF_force_analysis
