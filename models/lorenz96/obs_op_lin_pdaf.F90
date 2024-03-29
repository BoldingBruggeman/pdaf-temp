!$Id: obs_op_lin_pdaf.F90 710 2021-03-19 11:46:45Z lnerger $
!BOP
!
! !ROUTINE: obs_op_lin_pdaf --- Implementation of linearized observation operator
!
! !INTERFACE:
SUBROUTINE obs_op_lin_pdaf(step, dim, dim_obs, state, m_state)

! !DESCRIPTION:
! User-supplied routine for PDAF.
! Used in: 3D-Var, ensemble 3D-Var, hybrid 3D-Var
!
! The routine is called during the analysis step.
! It has to perform the operation of the
! observation operator acting on a state vector.
! For domain decomposition, the action is on the
! PE-local sub-domain of the state and has to 
! provide the observed sub-state for the PE-local 
! domain.
!
! The routine is called by all filter processes.
!
! !REVISION HISTORY:
! 2021-03 - Lars Nerger - Initial code
! Later revisions - see svn log
!
! !USES:
  USE mod_assimilation, &
       ONLY: use_obs_mask, obsindx

  IMPLICIT NONE

! !ARGUMENTS:
  INTEGER, INTENT(in) :: step           ! Currrent time step
  INTEGER, INTENT(in) :: dim            ! PE-local dimension of state
  INTEGER, INTENT(in) :: dim_obs        ! Dimension of observed state
  REAL, INTENT(in)    :: state(dim)     ! PE-local model state
  REAL, INTENT(out) :: m_state(dim_obs) ! PE-local observed state

! !CALLING SEQUENCE:
! Called by: PDAF_3dvar_costf_cvt
! Called by: PDAF_3dvar_costf_cg_cvt
!EOP

! *** Local variables ***
  INTEGER :: i               ! Counter


! *********************************************
! *** Perform application of measurement    ***
! *** operator H on vector or matrix column ***
! *********************************************

  IF (.NOT. use_obs_mask) THEN
     ! Full state is observed
     m_state(:) = state(:)
  ELSE
     ! Use gappy observations
     DO i = 1, dim_obs
        m_state(i) = state(obsindx(i))
     END DO
  END IF
 
END SUBROUTINE obs_op_lin_pdaf
