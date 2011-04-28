! $Id$
!
!  This modules deals with all aspects of shear; if no
!  shear is invoked, a corresponding replacement dummy
!  routine is used instead which absorbs all the calls to the
!  shear relevant subroutines listed in here.
!  Shear can either be given relative to Omega (using qshear),
!  or in absolute fashion via the parameters Sshear.
!
!** AUTOMATIC CPARAM.INC GENERATION ****************************
! Declare (for generation of cparam.inc) the number of f array
! variables and auxiliary variables added by this module
!
! CPARAM logical, parameter :: lshear = .true.
!
!***************************************************************
module Shear
!
  use Cdata
  use Messages, only: svn_id
  use Sub, only: keep_compiler_quiet
!
  implicit none
!
  real :: x0_shear=0.0, qshear0=0.0, sini=0.0
  real :: Sshear1=0.0, Sshear_sini=0.0
  logical :: lshearadvection_as_shift=.false.
  logical :: lmagnetic_stretching=.true.,lrandomx0=.false.
  logical :: lmagnetic_tilt=.false.
!
  include 'shear.h'
!
  namelist /shear_init_pars/ &
      qshear, qshear0, Sshear, Sshear1, deltay, Omega, &
      lshearadvection_as_shift, lmagnetic_stretching, lrandomx0, x0_shear, &
      sini
!
  namelist /shear_run_pars/ &
      qshear, qshear0, Sshear, Sshear1, deltay, Omega, &
      lshearadvection_as_shift, lmagnetic_stretching, lrandomx0, x0_shear, &
      sini
!
  integer :: idiag_dtshear=0    ! DIAG_DOC: advec\_shear/cdt
  integer :: idiag_deltay=0     ! DIAG_DOC: deltay
!
  contains
!***********************************************************************
    subroutine register_shear()
!
!  Initialise variables.
!
!  2-july-02/nils: coded
!
      if (lroot) call svn_id( &
           "$Id$")
!
    endsubroutine register_shear
!***********************************************************************
    subroutine initialize_shear()
!
!  21-nov-02/tony: coded
!  08-jul-04/anders: Sshear calculated whenever qshear /= 0
!
!  Calculate shear flow velocity; if qshear is given, then
!    Sshear=-(qshear-qshear0)*Omega  (shear in advection and magnetic stretching)
!    Sshear1=-qshear*Omega           (Lagrangian shear)
!  are calculated. Otherwise Sshear and Sshear1 keep their values from the input
!  list.
!
!  Definitions:
!    qshear = -(R / Omega) d Omega / dR,
!    qshear0 = 1 - Omega_p / Omega,
!  where Omega_p is the angular speed at which the shearing box revolves about
!  the central host.  If Omega_p = Omega, the usual shearing approximation is
!  recovered.
!
      if (qshear/=0.0) then
        Sshear=-(qshear-qshear0)*Omega
        Sshear1=-qshear*Omega
      else if (Sshear/=0.0.and.Sshear1==0.0) then
        Sshear1=Sshear
      endif
!
      if (lroot .and. ip<=12) then
        print*, 'initialize_shear: Sshear,Sshear1=', Sshear, Sshear1
        print*, 'initialize_shear: qshear,qshear0=', qshear, qshear0
      endif
!
!  Turn on tilt of magnetic stretching if requested.
!
      if (sini /= 0.) then
        lmagnetic_tilt=.true.
        if (lroot) then
          print*, 'initialize_shear: turn on tilt of magnetic stretching with sini = ', sini
          if (abs(sini) > .1) print*, 'Warning: current formulation only allows for small sini. '
        endif
        Sshear_sini=Sshear*sini
      endif
!
    endsubroutine initialize_shear
!***********************************************************************
    subroutine read_shear_init_pars(unit,iostat)
!
!  Read initial shear parameters.
!
      integer, intent(in) :: unit
      integer, intent(inout), optional :: iostat
!
      if (present(iostat)) then
        read(unit,NML=shear_init_pars,ERR=99, IOSTAT=iostat)
      else
        read(unit,NML=shear_init_pars,ERR=99)
      endif
!
99    return
!
    endsubroutine read_shear_init_pars
!***********************************************************************
    subroutine write_shear_init_pars(unit)
!
!  Write initial shear parameters.
!
      integer, intent(in) :: unit
!
      write(unit,NML=shear_init_pars)
!
    endsubroutine write_shear_init_pars
!***********************************************************************
    subroutine read_shear_run_pars(unit,iostat)
!
!  Read run shear parameters.
!
      integer, intent(in) :: unit
      integer, intent(inout), optional :: iostat
!
      if (present(iostat)) then
        read(unit,NML=shear_run_pars,ERR=99, IOSTAT=iostat)
      else
        read(unit,NML=shear_run_pars,ERR=99)
      endif
!
99    return
!
    endsubroutine read_shear_run_pars
!***********************************************************************
    subroutine write_shear_run_pars(unit)
!
!  Write run shear parameters.
!
      integer, intent(in) :: unit
!
      write(unit,NML=shear_run_pars)
!
    endsubroutine write_shear_run_pars
!***********************************************************************
    subroutine shear_before_boundary(f)
!
!  Actions to take before boundary conditions are set.
!
!   1-may-08/anders: coded
!
      use General, only: random_number_wrapper
      use Mpicomm, only: mpibcast_real
!
      real, dimension (mx,my,mz,mfarray) :: f
!
!  Possible to shear around a random position in x, to let all points
!  be subjected to shear in a statistically equal way.
!
      if (lfirst) then
        if (lrandomx0) then
          if (lroot) then
            call random_number_wrapper(x0_shear)
            x0_shear=x0_shear*Lxyz(1)+xyz0(1)
          endif
          call mpibcast_real(x0_shear,1,0)
        endif
      endif
!
      call keep_compiler_quiet(f)
!
    endsubroutine shear_before_boundary
!***********************************************************************
    subroutine pencil_criteria_shear()
!
!  All pencils that the Shear module depends on are specified here.
!
!  01-may-09/wlad: coded
!
      if (lhydro)    lpenc_requested(i_uu)=.true.
      if (lmagnetic) lpenc_requested(i_aa)=.true.
!
    endsubroutine pencil_criteria_shear
!***********************************************************************
    subroutine pencil_interdep_shear(lpencil_in)
!
!  Interdependency among pencils from the Shear module is specified here.
!
!  01-may-09/wlad: coded
!
      logical, dimension(npencils) :: lpencil_in
!
      call keep_compiler_quiet(lpencil_in)
!
    endsubroutine pencil_interdep_shear
!***********************************************************************
    subroutine calc_pencils_shear(f,p)
!
!  Calculate Shear pencils.
!  Most basic pencils should come first, as others may depend on them.
!
!  01-may-09/wlad: coded
!
      real, dimension (mx,my,mz,mfarray) :: f
      type (pencil_case) :: p
!
      intent(in) :: f,p
!
      call keep_compiler_quiet(f)
      call keep_compiler_quiet(p)
!
    endsubroutine calc_pencils_shear
!***********************************************************************
    subroutine shearing(f,df,p)
!
!  Calculates the shear terms -uy0*df/dy (shearing sheat approximation).
!
!  2-jul-02/nils: coded
!  6-jul-02/axel: runs through all nvar variables; added timestep check
! 16-aug-02/axel: use now Sshear which is calculated in param_io.f90
! 20-aug-02/axel: added magnetic stretching term
! 25-feb-11/MR:   restored shearing of testflow solutions, when demanded
! 20-Mar-11/MR:   testflow variables now completely processed in testflow module
!
      use Deriv, only: der
      use Diagnostics, only: max_mn_name
      use Cparam, only: ltestflow
!
      real, dimension (mx,my,mz,mfarray) :: f
      real, dimension (mx,my,mz,mvar) :: df
      type (pencil_case) :: p
!
      real, dimension (nx) :: uy0,dfdy
      integer :: j,k,jseg,nseg,na,ne
!
      intent(in)  :: f
!
!  Print identifier.
!
      if (headtt.or.ldebug) then
        print*, 'shearing: Sshear,Sshear1=', Sshear, Sshear1
        print*, 'shearing: qshear,qshear0=', qshear, qshear0
      endif
!
!  Add shear (advection) term, -uy0*df/dy, for all variables.
!
      uy0=Sshear*(x(l1:l2)-x0_shear)
!
!  Advection of all variables by shear flow.
!
      if (.not. lshearadvection_as_shift) then
! 
        if ( ltestflow ) then
!
!  Treatment of variables in two segments necessary as 
!  shear is potentially handled differently in testflow
!
          nseg = 2
          ne = iuutest-1
        else
          nseg = 1
          ne = nvar
        endif
!
        na=1
        do jseg=1,nseg
!
          do j=na,ne
            call der(f,j,dfdy,2)
            df(l1:l2,m,n,j)=df(l1:l2,m,n,j)-uy0*dfdy
          enddo
!
          na=iuutest+ntestflow
          ne=nvar
!
        enddo
      endif
!
!  Lagrangian shear of background velocity profile. Appears like a correction
!  to the Coriolis force, but is actually not related to the Coriolis
!  force.
!
      if (lhydro) df(l1:l2,m,n,iuy)=df(l1:l2,m,n,iuy)-Sshear1*p%uu(:,1)
!
!  Add (Lagrangian) shear term for all dust species.
!
      if (ldustvelocity) then
        do k=1,ndustspec
          df(l1:l2,m,n,iudy(k))=df(l1:l2,m,n,iudy(k)) &
            -Sshear1*f(l1:l2,m,n,iudx(k))
        enddo
      endif
!
!  Magnetic stretching and tilt terms (can be turned off for debugging purposes).
!
      if (lmagnetic .and. lmagnetic_stretching) then
        df(l1:l2,m,n,iax)=df(l1:l2,m,n,iax)-Sshear*p%aa(:,2)
        if (lmagnetic_tilt) then
          df(l1:l2,m,n,iax)=df(l1:l2,m,n,iax)-Sshear_sini*p%aa(:,1)
          df(l1:l2,m,n,iay)=df(l1:l2,m,n,iay)+Sshear_sini*p%aa(:,2)
        endif
      endif
!
!  Testfield stretching term.
!  Loop through all the dax/dt equations and add -S*ay contribution.
!
      if (ltestfield) then
        do j=iaatest,iaxtestpq,3
          df(l1:l2,m,n,j)=df(l1:l2,m,n,j)-Sshear*f(l1:l2,m,n,j+1)
        enddo
        if (iuutest/=0) then
          do j=iuutest,iuztestpq,3
            df(l1:l2,m,n,j+1)=df(l1:l2,m,n,j+1)-Sshear*f(l1:l2,m,n,j)
          enddo
        endif
      endif
!
!  Meanfield stretching term.
!  Loop through all the dax/dt equations and add -S*ay contribution.
!
      if (iam/=0) then
        df(l1:l2,m,n,iamx)=df(l1:l2,m,n,iamx)-Sshear*f(l1:l2,m,n,iamy)
      endif
!
!  Take shear into account for calculating time step.
!
      if (lfirst.and.ldt.and.(lhydro.or.ldensity).and. &
          (.not.lshearadvection_as_shift)) &
          advec_shear=abs(uy0*dy_1(m))
!
!  Calculate shearing related diagnostics.
!
      if (ldiagnos) then
        if (idiag_dtshear/=0) &
            call max_mn_name(advec_shear/cdt,idiag_dtshear,l_dt=.true.)
      endif
!
    endsubroutine shearing
!***********************************************************************
    subroutine shear_variables(f,df,nvars,jstart,jstep,shear1)
!
!  Allow shear treatment of variables in other modules
!  jstart, jend - start and end indices of slots in df 
!                 to which advection term is added
!  jstep        - stepsize in df for selecting slots to 
!                 which Langrangian shear is added;
!                 only relevant for velocity variables, 
!                 jstart corresponds to u_x; default value: 3
!                 = 0 : Langrangian shear is not added
!
! 20-Mar-11/MR: coded
!
      use Deriv, only: der
!
      real, dimension(mx,my,mz,mfarray), intent(in)  :: f
      real, dimension(mx,my,mz,mvar)   , intent(out) :: df
!
      integer, intent(in) :: nvars, jstart 
      integer, intent(in), optional :: jstep
      logical, intent(in), optional :: shear1
!
      integer :: j,jend,js
      real, dimension (nx) :: uy0,dfdy
      real :: sh
!
      if ( .not.present(jstep) ) then
        js = 3
      else
        js = jstep
      endif
!
      if ( .not.present(shear1) ) then
        sh = Sshear
      else if ( shear1 ) then
        sh = Sshear1
      else
        sh = Sshear
      endif
!
!  Add shear (advection) term, -uy0*df/dy, for all variables.
!
      uy0=Sshear*(x(l1:l2)-x0_shear)
!
!  Advection of all variables by shear flow.
!
      jend = jstart+nvars-1
!
      if (.not. lshearadvection_as_shift) then
        do j=jstart,jend
          call der(f,j,dfdy,2)
          df(l1:l2,m,n,j)=df(l1:l2,m,n,j)-uy0*dfdy
        enddo
      endif
!
!  Lagrangian shear of background velocity profile.
!
      if ( js>0 ) then
        do j=jstart,jend,js
          df(l1:l2,m,n,j+1)=df(l1:l2,m,n,j+1)-sh*f(l1:l2,m,n,j)
        enddo
      endif
!
    endsubroutine shear_variables  
!***********************************************************************
    subroutine advance_shear(f,df,dt_shear)
!
!  Advance shear distance, deltay, using dt. Using t instead introduces
!  significant errors when nt = t/dt exceeds ~100,000 steps.
!  This formulation works also when Sshear is changed during the run.
!
!  18-aug-02/axel: incorporated from nompicomm.f90
!
      use Diagnostics, only: save_name
      use Fourier, only: fourier_shift_y
!
      real, dimension (mx,my,mz,mfarray) :: f
      real, dimension (mx,my,mz,mvar) :: df
      real :: dt_shear
!
      real, dimension (nx,ny,nz) :: tmp
      real, dimension (nx) :: uy0
      integer :: ivar
!
!  Must currently use lshearadvection_as_shift=T when Sshear is positive.
!
      if (Sshear>0. .and. .not. lshearadvection_as_shift &
        .and. ncpus/=1 .and. headt) then
        print*
        print*, 'NOTE: for Sshear > 0, MPI is not completely correct.'
        print*, 'It is better to use lshearadvection_as_shift=T and use:'
        print*, 'FOURIER=fourier_fftpack'
        print*
      endif
!
!  Make sure deltay is in the range 0 <= deltay < Ly (assuming Sshear<0).
!
      deltay=deltay-Sshear*Lx*dt_shear
      deltay=deltay-int(deltay/Ly)*Ly
!
!  Solve for advection by shear motion by shifting all variables and their
!  time derivative (following Gammie 2001). Removes time-step constraint
!  from shear motion.
!
      if (lshearadvection_as_shift) then
        uy0=Sshear*(x(l1:l2)-x0_shear)
        do ivar=1,mvar
          tmp=f(l1:l2,m1:m2,n1:n2,ivar)
          call fourier_shift_y(tmp,uy0*dt_shear)
          f(l1:l2,m1:m2,n1:n2,ivar)=tmp
        enddo
        if (.not. llast) then
          do ivar=1,mvar
            tmp=df(l1:l2,m1:m2,n1:n2,ivar)
            call fourier_shift_y(tmp,uy0*dt_shear)
            df(l1:l2,m1:m2,n1:n2,ivar)=tmp
          enddo
        endif
      endif
!
!  Print identifier.
!
      if (headtt.or.ldebug) print*, 'advance_shear: deltay=',deltay
!
!  Calculate shearing related diagnostics
!
      if (ldiagnos) then
        if (idiag_deltay/=0) &
            call save_name(deltay,idiag_deltay)
      endif
!
    endsubroutine advance_shear
!***********************************************************************
    subroutine boundcond_shear(f,ivar1,ivar2)
!
!  Shearing boundary conditions, called from the Boundconds module.
!
!  02-oct-07/anders: coded
!
      use Mpicomm, only: initiate_shearing, finalize_shearing
!
      real, dimension (mx,my,mz,mfarray) :: f
      integer :: ivar1, ivar2
!
      if (ip<12.and.headtt) print*, &
          'boundconds_x: use shearing sheet boundary condition'
!
      if (lshearadvection_as_shift) then
        call fourier_shift_ghostzones(f,ivar1,ivar2)
      else
        call initiate_shearing(f,ivar1,ivar2)
        call finalize_shearing(f,ivar1,ivar2)
      endif
!
    endsubroutine boundcond_shear
!***********************************************************************
    subroutine fourier_shift_ghostzones(f,ivar1,ivar2)
!
!  Shearing boundary conditions by Fourier interpolation.
!
!  02-oct-07/anders: coded
!
      use Fourier, only: fourier_shift_yz_y
!
      real, dimension (mx,my,mz,mfarray) :: f
      integer :: ivar1, ivar2
!
      real, dimension (ny,nz) :: f_tmp_yz
      integer :: i, ivar
!
      if (nxgrid/=1) then
        f(l2+1:mx,m1:m2,n1:n2,ivar1:ivar2)=f(l1:l1+2,m1:m2,n1:n2,ivar1:ivar2)
        f( 1:l1-1,m1:m2,n1:n2,ivar1:ivar2)=f(l2-2:l2,m1:m2,n1:n2,ivar1:ivar2)
      endif
!
      if (nygrid/=1) then
        do ivar=ivar1,ivar2
          do i=1,3
            f_tmp_yz=f(l1-i,m1:m2,n1:n2,ivar)
            call fourier_shift_yz_y(f_tmp_yz,+deltay)
            f(l1-i,m1:m2,n1:n2,ivar)=f_tmp_yz
            f_tmp_yz=f(l2+i,m1:m2,n1:n2,ivar)
            call fourier_shift_yz_y(f_tmp_yz,-deltay)
            f(l2+i,m1:m2,n1:n2,ivar)=f_tmp_yz
          enddo
        enddo
      endif
!
    endsubroutine fourier_shift_ghostzones
!***********************************************************************
    subroutine rprint_shear(lreset,lwrite)
!
!  Reads and registers print parameters relevant to shearing.
!
!   2-jul-04/tobi: adapted from entropy
!
      use Diagnostics, only: parse_name
!
      integer :: iname
      logical :: lreset,lwr
      logical, optional :: lwrite
!
      lwr = .false.
      if (present(lwrite)) lwr=lwrite
!
!  Reset everything in case of reset.
!  (this needs to be consistent with what is defined above!)
!
      if (lreset) then
        idiag_dtshear=0
        idiag_deltay=0
      endif
!
!  iname runs through all possible names that may be listed in print.in.
!
      do iname=1,nname
        call parse_name(iname,cname(iname),cform(iname),'dtshear',idiag_dtshear)
        call parse_name(iname,cname(iname),cform(iname),'deltay',idiag_deltay)
      enddo
!
!  Write column where which shear variable is stored.
!
      if (lwr) then
!
      endif
!
    endsubroutine rprint_shear
!***********************************************************************
endmodule Shear
