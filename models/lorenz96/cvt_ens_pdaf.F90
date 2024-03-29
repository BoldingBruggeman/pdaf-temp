!$Id: obs_op_pdaf.F90 1864 2017-12-20 19:53:30Z lnerger $
!BOP
!
! !ROUTINE: cvt_ens_pdaf --- Convert control vector to state increment
!
! !INTERFACE:
SUBROUTINE cvt_ens_pdaf(iter, dim_p, dim_ens, dim_cvec_ens, ens_p, cv_p, Vcv_p)

! !DESCRIPTION:
! User-supplied routine for PDAF.
! Used in: ensemble 3D-Var and hybrid 3D-Var
!
! The routine is called during the analysis step.
! It has to apply the covariance operator (square
! root of P) to a vector in control space.
!
! For ensemble-var the ensemble representation
! of the covariance operator is used.
!
! For domain decomposition, the action is on
! the control vector for the PE-local part of
! the sub-state vector for the PE-local domain.
!
! This code variant uses an explicit array holding
! the covariance operator as a matrix.
!
! !REVISION HISTORY:
! 2021-03 - Lars Nerger - Initial code
! Later revisions - see svn log
!
! !USES:
  USE mod_assimilation, &
       ONLY: Vmat_ens, type_opt, mcols_cvec_ens

  IMPLICIT NONE

! !ARGUMENTS:
  INTEGER, INTENT(in) :: iter               ! Iteration of optimization
  INTEGER, INTENT(in) :: dim_p              ! PE-local dimension of state
  INTEGER, INTENT(in) :: dim_ens            ! Ensemble size
  INTEGER, INTENT(in) :: dim_cvec_ens       ! PE-local dimension of control vector
  REAL, INTENT(in) :: ens_p(dim_p, dim_ens) ! PE-local ensemble
  REAL, INTENT(in) :: cv_p(dim_cvec_ens)    ! PE-local control vector
  REAL, INTENT(inout) :: Vcv_p(dim_p)       ! PE-local state increment
!EOP

! *** local variables ***
  INTEGER :: i, member, row          ! Counters
  REAL :: fact                       ! Scaling factor
  REAL, ALLOCATABLE :: Vmat_p(:,:)   ! Extended ensemble perturbation matrix
  REAL :: invdimens                  ! Inverse ensemble size


! *************************************************
! *** Convert control vector to state increment ***
! *************************************************

  firstiter: IF (iter==1) THEN

     ! *** Generate control vector transform matrix ***

     fact = 1.0/SQRT(REAL(dim_cvec_ens-1))

     IF (ALLOCATED(Vmat_ens)) DEALLOCATE(Vmat_ens)
     ALLOCATE(Vmat_ens(dim_p, dim_cvec_ens))
  
     Vcv_p = 0.0
     invdimens = 1.0 / REAL(dim_ens)
     DO member = 1, dim_ens
        DO row = 1, dim_p
           Vcv_p(row) = Vcv_p(row) + invdimens * ens_p(row, member)
        END DO
     END DO
  
     DO member = 1, dim_ens
        Vmat_ens(:,member) = fact*(ens_p(:,member) - Vcv_p(:))
     END DO

     DO i = 2, mcols_cvec_ens

        DO member = (i-1)*dim_ens+1, i*dim_ens
           Vmat_ens(:,member) = ens_p(:,member-(i-1)*dim_ens)
        END DO
     END DO
  
  END IF firstiter


  ! *** Apply Vmat to control vector ***

  CALL dgemv('n', dim_p, dim_cvec_ens, 1.0, Vmat_ens, &
       dim_p, cv_p, 1, 0.0, Vcv_p, 1)

END SUBROUTINE cvt_ens_pdaf
