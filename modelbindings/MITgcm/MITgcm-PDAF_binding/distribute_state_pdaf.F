C     $Id: distribute_state_pdaf.F 7 2018-01-31 18:11:38Z lnerger $
#include "CPP_OPTIONS.h"
C     !BOP
C
C     !ROUTINE: distribute_state_pdaf --- Initialize model fields from state vector
C
C     !INTERFACE:
      SUBROUTINE distribute_state_pdaf(dim_p, state_p)

C     !DESCRIPTION:
C     User-supplied routine for PDAF.
C
C     During the forecast phase of the filter this
C     subroutine is called from PDAF\_get\_state
C     supplying a model state which has to be evolved. 
C     The routine has to initialize the fields of the 
C     model (typically available through a module) from 
C     the state vector of PDAF. With parallelization, 
C     MPI communication might be required to 
C     initialize all subdomains on the model PEs.
C
C     The routine is executed by each process that is
C     participating in the model integrations.
C
C     !REVISION HISTORY:
C     2004-10 - Lars Nerger - Initial code
C     Later revisions - see svn log
C
C     !USES:
      USE mod_assimilation,
     &     ONLY: myIter, myThid

      IMPLICIT NONE
  
C     !ARGUMENTS:
      INTEGER, INTENT(in) :: dim_p ! PE-local state dimension
      _RL, INTENT(inout) :: state_p(dim_p) ! PE-local state vector

C     !Local variables:
#include "SIZE.h"
#include "EEPARAMS.h"
#include "GRID.h"
#include "DYNVARS.h"

C     Local variables
      INTEGER i,j,k,bi,bj,koffset
      CHARACTER*(MAX_LEN_MBUF) msgBuf

C     !CALLING SEQUENCE:
C     Called by: PDAF_get_state   (as U_dist_state)
C!EOP

      
C     *******************************************
C     *** Initialize model fields from state  ***
C     *** Each model PE knows his sub-state   ***
C     *******************************************

      koffset = 0

C     *** Sea surface height (etaN) ***
      DO bj=myByLo(myThid),myByHi(myThid)
         DO bi=myBxLo(myThid),myBxHi(myThid)
            DO j=1,sNy
               DO i=1,sNx
                  koffset = koffset + 1
                  etaN(i,j,bi,bj) = state_p(koffset)
               ENDDO
            ENDDO
         ENDDO
      ENDDO
      
C     *** TEMP (theta) ***
      DO bj=myByLo(myThid),myByHi(myThid)
         DO bi=myBxLo(myThid),myBxHi(myThid)
            DO k=1,Nr
               DO j=1,sNy
                  DO i=1,sNx
                     koffset = koffset + 1
                     theta(i,j,k,bi,bj)= state_p(koffset) 
                  ENDDO
               ENDDO
            ENDDO
         ENDDO
      ENDDO

C     *** SALT (salt) ***
      DO bj=myByLo(myThid),myByHi(myThid)
         DO bi=myBxLo(myThid),myBxHi(myThid)
            DO k=1,Nr
               DO j=1,sNy
                  DO i=1,sNx
                     koffset = koffset + 1
                     salt(i,j,k,bi,bj)= state_p(koffset)
                  ENDDO
               ENDDO
            ENDDO
         ENDDO
      ENDDO

C     *** U velocity (uVel) ***
      DO bj=myByLo(myThid),myByHi(myThid)
         DO bi=myBxLo(myThid),myBxHi(myThid)
            DO k=1,Nr
               DO j=1,sNy
                  DO i=1,sNx
                     koffset = koffset + 1
                     uVel(i,j,k,bi,bj) = state_p(koffset) 
                  ENDDO
               ENDDO
            ENDDO
         ENDDO
      ENDDO

C     *** V velocity (vVel) ***
      DO bj=myByLo(myThid),myByHi(myThid)
         DO bi=myBxLo(myThid),myBxHi(myThid)
            DO k=1,Nr
               DO j=1,sNy
                  DO i=1,sNx
                     koffset = koffset + 1
                     vVel(i,j,k,bi,bj)= state_p(koffset)
                  ENDDO
               ENDDO
            ENDDO
         ENDDO
      ENDDO

      CALL DO_FIELDS_BLOCKING_EXCHANGES(myThid)

      
      IF ( koffset < dim_p ) THEN
         WRITE(msgBuf,'(A,I7,A,I7)')
     &        'DISTRIBUTE_STATE_PDAF: koffset < dim_p:', koffset,
     &        ' > ', dim_p
         CALL PRINT_ERROR( msgBuf, myThid )
         CALL ALL_PROC_DIE( 0 )
         STOP 'ABNORMAL END: S/R CONFIG_CHECK'
      ENDIF
         
      IF ( koffset .GT. dim_p ) THEN
         WRITE(msgBuf,'(A,I7,A,I7)')
     &        'DISTRIBUTE_STATE_PDAF: koffset > dim_p:', koffset,
     &        ' > ', dim_p
         CALL PRINT_ERROR( msgBuf, myThid )
         CALL ALL_PROC_DIE( 0 )
         STOP 'ABNORMAL END: S/R CONFIG_CHECK'
      ENDIF

      END
