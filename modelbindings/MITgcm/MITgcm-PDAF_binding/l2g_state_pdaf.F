C     $Id: l2g_state_pdaf.F 7 2018-01-31 18:11:38Z lnerger $
C
C     !ROUTINE: l2g_state_pdaf --- Initialize full state from local analysis
C
C     !INTERFACE:
      SUBROUTINE l2g_state_pdaf(step, domain_p,
     &      dim_l, state_l, dim_p, state_p)

C     !DESCRIPTION:
C     User-supplied routine for PDAF.
C     Used in the filters: LSEIK/LETKF/LESTKF
C
C     The routine is called during the loop over all
C     local analysis domains in PDAF\_X\_update 
C     after the analysis and ensemble transformation 
C     on a single local analysis domain. It has to 
C     initialize elements of the PE-local full state 
C     vector from the provided analysis state vector 
C     on the local analysis domain.
C
C     !REVISION HISTORY:
C     2013-02 - Lars Nerger - Initial code
C     Later revisions - see svn log
C
C     !USES:
      USE mod_assimilation,
     &     ONLY: off_fields, nfields

      IMPLICIT NONE

C     !ARGUMENTS:
      INTEGER, INTENT(in) :: step           ! Current time step
      INTEGER, INTENT(in) :: domain_p       ! Current local analysis domain
      INTEGER, INTENT(in) :: dim_l          ! Local state dimension
      INTEGER, INTENT(in) :: dim_p          ! PE-local full state dimension
      REAL*8, INTENT(in)    :: state_l(dim_l) ! State vector on local analysis domain
      REAL*8, INTENT(inout) :: state_p(dim_p) ! PE-local full state vector 

C     !CALLING SEQUENCE:
C     Called by: PDAF_lestkf_update   (as U_l2g_state)
C     Called by: PDAF_letkf_update    (as U_l2g_state)

C     *** local variables ***
#include "SIZE.h"
      INTEGER :: i, lay, cnt  ! Counters


C     **************************************************
C     *** Initialize elements of global state vector ***
C     **************************************************

C     Sea surface height
      state_p(domain_p) = state_l(1)

C     3D fields
      cnt = 2
      DO i = 2, nfields
         DO lay = 1, Nr
            state_p(domain_p + off_fields(i) + (lay-1)*(sNx*sNy))
     &           = state_l(cnt)
            cnt = cnt+1
         ENDDO
      ENDDO

      END SUBROUTINE l2g_state_pdaf
