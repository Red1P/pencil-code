module Gravity

!
!  Radial gravity
!

  use Cparam

  implicit none

  contains

!***********************************************************************
    subroutine register_grav()
!
!  initialise gravity flags
!
!  10-jan-02/wolf: coded
!
      use Cdata
      use Mpicomm
      use Sub
!
      logical, save :: first=.true.
!
      if (.not. first) call stop_it('register_grav called twice')
      first = .false.
!
!  identify version number
!
      if (lroot) call cvs_id( &
           "$RCSfile: grav_r.f90,v $", &
           "$Revision: 1.4 $", &
           "$Date: 2002-01-17 11:42:43 $")
!
      lgrav = .true.
      lgravz = .false.
      lgravr = .true.
!
    endsubroutine register_grav
!***********************************************************************
    subroutine init_grav(f,init,ampl,xx,yy,zz)
!
!  initialise gravity; called from start.f90
!  10-jan-02/wolf: coded
!
      use Cdata
!
      real, dimension (mx,my,mz,mvar) :: f
      real, dimension (mx,my,mz) :: xx,yy,zz
      real :: ampl
      integer :: init
!
! Not doing anything (this might change if we decide to store gg)
!
!
    endsubroutine init_grav
!***********************************************************************
    subroutine duu_dt_grav(f,df)
!
!  add duu/dt according to gravity
!
!  10-jan-02/wolf: coded
!
      use Cdata
!      use Mpicomm
      use Sub
      use Global
!      use Slices
!
      real, dimension (mx,my,mz,mvar) :: f,df
      real, dimension (nx,3) :: gg
!
      call grad(m_pot,1,gg)     ! gg = - grad(pot)
      df(l1:l2,m,n,iux:iuz) = df(l1:l2,m,n,iux:iuz) + gg
!
    endsubroutine duu_dt_grav
!***********************************************************************

endmodule Gravity
