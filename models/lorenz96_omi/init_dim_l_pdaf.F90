!$Id: init_dim_l_pdaf.F90 393 2020-03-05 16:05:31Z lnerger $
!BOP
!
! !ROUTINE: init_dim_l_pdaf --- Set dimension of local model state
!
! !INTERFACE:
SUBROUTINE init_dim_l_pdaf(step, domain, dim_l)

! !DESCRIPTION:
! User-supplied routine for PDAF (LSEIK):
!
! The routine is called during analysis step
! in the llop over all local analysis domain.
! It has to set the dimension of local model 
! state on the current analysis domain.
!
! This variant is for the Lorenz96 model without
! parallelization. We simply consider each single 
! grid point  as a local analysis domain.
!
! !REVISION HISTORY:
! 2009-11 - Lars Nerger - Initial code
! Later revisions - see svn log
!
! !USES:
  USE mod_assimilation, &         ! Variables for assimilation
       ONLY: coords_l

  IMPLICIT NONE

! !ARGUMENTS:
  INTEGER, INTENT(in)  :: step    ! Current time step
  INTEGER, INTENT(in)  :: domain  ! Current local analysis domain
  INTEGER, INTENT(out) :: dim_l   ! Local state dimension

! !CALLING SEQUENCE:
! Called by: PDAF_lseik_update   (as U_init_dim_l)
!EOP


! ****************************************
! *** Initialize local state dimension ***
! ****************************************
  
  ! Simply one here
  dim_l = 1


! **********************************************
! *** Initialize coordinates of local domain ***
! **********************************************

  ! Simply the grid point index here
  coords_l(1) = REAL(domain)

END SUBROUTINE init_dim_l_pdaf
