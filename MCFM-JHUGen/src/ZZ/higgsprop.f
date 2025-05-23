      double complex function higgsprop(s)
c--- computes Higgs propagator for Higgs boson four-momentum squared s
c--- if CPscheme = .true. then it is computed in the complex pole
c---   scheme (Goria, Passarino, Rosco, arXiv:1112.5517,
c---           and c.f. Eq. (2.11) of arXiv:1206.4803)
c--- otherwise it takes the usual Breit-Wigner form
      implicit none
      include 'constants.f'
      include 'masses.f'
      include 'cpscheme.f'
      include 'widthscheme.f'
      include 'spinzerohiggs_anomcoupl.f'
      !include 'first.f'
      double precision s,mhbarsq,mhbar,gammahbar
      double complex cfac
      double precision qqq, qqq0 !added for running width
      save mhbarsq,cfac

      ! PRINT *, "h1:", hmass, hwidth
      if (CPscheme) then
c--- complex pole scheme propagator      
        mhbarsq=hmass**2+hwidth**2
        mhbar=sqrt(mhbarsq)
        gammahbar=mhbar/hmass*hwidth
        cfac=dcmplx(1d0,gammahbar/mhbar)
        higgsprop=cfac/(s*cfac-dcmplx(mhbarsq,0d0))
      else
c--- Breit Wigner propagator
        if(widthscheme.eq.0) then
            higgsprop = 1d0
        else if(widthscheme.eq.1) then
            higgsprop=1d0/dcmplx(s-hmass**2,s*hwidth/hmass)
        else if(widthscheme.eq.2) then
            higgsprop=1d0/dcmplx(s-hmass**2,hmass*hwidth)
        else if(widthscheme.eq.4) then !3 is skipped as by JHU convention it would be the CPscheme, but that is already covered
            if (0.25d0*s < zmass**2) then
                  qqq = 0
            else
                  qqq = sqrt(0.25d0*s - zmass**2)
            endif
            qqq0 = sqrt(0.25d0*(hmass**2) - zmass**2)
            !   PRINT *, s, qqq, qqq0
            higgsprop=1d0/dcmplx(s-hmass**2,hmass*hwidth*qqq/qqq0) !inserted multiplication by qqq/qqq0 for running width
        else
            print *, "Invalid width scheme", widthscheme
        endif
      endif
c--- Jeff: Apply Form Factors regardless of width scheme
c--- Note: default value (n=1) does not change propagator
c--- FF1(2) = 1/(1+|Q^2|/(Lambda_FF1(2))^2)^n_ff1(2)
      if (AllowAnomalousCouplings .eq. 1) then
        higgsprop = higgsprop * 
     &  1d0/(1d0+abs(s)/(Lambda_ff1**2))**n_ff1 * 
     &  1d0/(1d0+abs(s)/(Lambda_ff2**2))**n_ff2
      endif
      return
   
   99 format(' *    MHB = ',f9.4,' GeV    GHB = ',f9.4,' GeV    *')
      
      end
      

      double complex function higgs2prop(s)
c--- computes HM Higgs propagator for Higgs boson four-momentum squared s
c--- if CPscheme = .true. then it is computed in the complex pole
c---   scheme (Goria, Passarino, Rosco, arXiv:1112.5517,
c---           and c.f. Eq. (2.11) of arXiv:1206.4803)
c--- otherwise it takes the usual Breit-Wigner form
      implicit none
      include 'constants.f'
      include 'masses.f'
      include 'cpscheme.f'
      include 'widthscheme.f'
      !include 'first.f'
      include 'spinzerohiggs_anomcoupl.f'
      double precision s,mhbarsq,mhbar,gammahbar
      double complex cfac
      double precision qqq, qqq0 !added for running width
      save mhbarsq,cfac

      ! PRINT *, "h2:", h2mass, h2width
      if(h2mass.lt.zip) then
         higgs2prop=czip
         return
      endif

      if (CPscheme) then
c--- complex pole scheme propagator      
        mhbarsq=h2mass**2+h2width**2
        mhbar=sqrt(mhbarsq)
        gammahbar=mhbar/h2mass*h2width
        cfac=dcmplx(1d0,gammahbar/mhbar)
        higgs2prop=cfac/(s*cfac-dcmplx(mhbarsq,0d0))
      else
c--- Breit Wigner propagator
        if(widthscheme.eq.0) then
            higgs2prop = 1d0
        else if(widthscheme.eq.1) then
            higgs2prop=1d0/dcmplx(s-h2mass**2,s*h2width/h2mass)
        else if(widthscheme.eq.2) then
            higgs2prop=1d0/dcmplx(s-h2mass**2,h2mass*h2width)
        else if(widthscheme.eq.4) then !3 is skipped as by JHU convention is would be the CPscheme, but that is already covered
            if (0.25d0*s < zmass**2) then
                  qqq = 0
            else
                  qqq = sqrt(0.25d0*s - zmass**2)
            endif
            qqq0 = sqrt(0.25d0*(h2mass**2) - zmass**2)
            !   PRINT *, s, qqq, qqq0
            higgs2prop=1d0/dcmplx(s-h2mass**2,h2mass*h2width*qqq/qqq0) !inserted multiplication by qqq/qqq0 for running width
        else
            print *, "Invalid width scheme", widthscheme
        endif
      endif
c--- Jeff: Apply Form Factors regardless of width scheme
c--- Note: default value (n=0) does not change propagator
c--- FF1(2) = 1/(1+|Q^2|/(Lambda2_FF1(2))^2)^n2_ff1(2)
c---if (AllowAnomalousCouplings .eq. 1) 
      higgs2prop = higgs2prop * 
     &  1d0/(1d0+abs(s)/(Lambda2_ff1**2))**n2_ff1 * 
     &  1d0/(1d0+abs(s)/(Lambda2_ff2**2))**n2_ff2
      
      return
   
   99 format(' *    MHB = ',f9.4,' GeV    GHB = ',f9.4,' GeV    *')
      
      end
c--- 
c---  One-loop correction to the Higgs propagator
c---      
      function sigmah(s,c6,wfr)
      implicit none
c---  include 'types.f'
      double complex sigmah

      include 'constants.f'
c---  include 'cplx.h'
      include 'masses.f'
      include 'ewcouple.f'
      include 'qlfirst.f'
      double precision s, c6, wfr, MH2, dB0h, dZh, dmhsq
      double complex qlI2

      if (qlfirst) then
        qlfirst=.false. 
        call qlinit
      endif

      MH2=hmass**2

c--- Wavefunction renormalisation
      dB0h = (-9 + 2*sqrt(3d0)*Pi)/(9*MH2)
      dZh  = -wfr*dB0h  
c--- Mass renormalisation
      dmhsq = qlI2(MH2,MH2,MH2,1d0,0)
c--- Renormalised correction
      sigmah = (9*c6*(2d0 + c6)*MH2**2*
     & (-dZh*(MH2 - s)))/
     & (32d0*Pi**2*vevsq)

      sigmah = sigmah + (9*c6*(2d0 + c6)*MH2**2*
     & (qlI2(s,MH2,MH2,1d0,0) - dmhsq))/
     & (32d0*Pi**2*vevsq)

      sigmah= sigmah/dcmplx(s-MH2,hmass*hwidth) 

      return 
      end
      
