;  $Id: time_series.pro,v 1.7 2003-05-15 04:30:39 brandenb Exp $
;
;  here we read the rprint files
;  to generate an index catalogue of what is written
;
@data/index
print,'nname=',nname
;
;  set datatopdir to default value
;
default, datatopdir, 'data'
filen=datatopdir+'/time_series.dat'
;
;  read table
;
a=input_table(filen)
if defined(i_t) ne 0 then tt=reform(a(i_t-1,*))
if defined(i_it) ne 0 then it=reform(a(i_it-1,*))
if defined(i_dt) ne 0 then dt=reform(a(i_dt-1,*))
if defined(i_urms) ne 0 then urms=reform(a(i_urms-1,*))
if defined(i_umax) ne 0 then umax=reform(a(i_umax-1,*))
if defined(i_u2m) ne 0 then u2m=reform(a(i_u2m-1,*))
if defined(i_um2) ne 0 then um2=reform(a(i_um2-1,*))
if defined(i_b2m) ne 0 then b2m=reform(a(i_b2m-1,*))
if defined(i_orms) ne 0 then orms=reform(a(i_orms-1,*))
if defined(i_epsK) ne 0 then epsK=reform(a(i_epsK-1,*))
if defined(i_epsM) ne 0 then epsM=reform(a(i_epsM-1,*))
if defined(i_ugradpm) ne 0 then ugradpm=reform(a(i_ugradpm-1,*))
if defined(i_brms) ne 0 then brms=reform(a(i_brms-1,*))
if defined(i_bm2) ne 0 then bm2=reform(a(i_bm2-1,*))
if defined(i_abm) ne 0 then abm=reform(a(i_abm-1,*))
if defined(i_jbm) ne 0 then jbm=reform(a(i_jbm-1,*))
if defined(i_oum) ne 0 then oum=reform(a(i_oum-1,*))
if defined(i_ssm) ne 0 then ssm=reform(a(i_ssm-1,*))
if defined(i_TTm) ne 0 then TTm=reform(a(i_TTm-1,*))
if defined(i_yHm) ne 0 then yHm=reform(a(i_yHm-1,*))
if defined(i_eth) ne 0 then eth=reform(a(i_eth-1,*))
if defined(i_ekin) ne 0 then ekin=reform(a(i_ekin-1,*))
if defined(i_rhom) ne 0 then rhom=reform(a(i_rhom-1,*))
if defined(i_bmx) ne 0 then bmx=reform(a(i_bmx-1,*))
if defined(i_bmy) ne 0 then bmy=reform(a(i_bmy-1,*))
if defined(i_bmz) ne 0 then bmz=reform(a(i_bmz-1,*))
if defined(i_umx) ne 0 then umx=reform(a(i_umx-1,*))
if defined(i_umy) ne 0 then umy=reform(a(i_umy-1,*))
if defined(i_umz) ne 0 then umz=reform(a(i_umz-1,*))
if defined(i_ruxm) ne 0 then ruxm=reform(a(i_ruxm-1,*))
if defined(i_ruym) ne 0 then ruym=reform(a(i_ruym-1,*))
if defined(i_ruzm) ne 0 then ruzm=reform(a(i_ruzm-1,*))
if defined(i_uxBm) ne 0 then uxBm=reform(a(i_uxBm-1,*))
if defined(i_oxuxBm) ne 0 then oxuxBm=reform(a(i_oxuxBm-1,*))
if defined(i_JxBxBm) ne 0 then JxBxBm=reform(a(i_JxBxBm-1,*))
if defined(i_ucm) ne 0 then ucm=reform(a(i_ucm-1,*))
if defined(i_uudcm) ne 0 then uudcm=reform(a(i_uudcm-1,*))
if defined(i_lnccm) ne 0 then lnccm=reform(a(i_lnccm-1,*))
if defined(i_Erad_rms) ne 0 then Erad_rms=reform(a(i_Erad_rms-1,*))
if defined(i_Erad_max) ne 0 then Erad_max=reform(a(i_Erad_max-1,*))
if defined(i_Egas_rms) ne 0 then Egas_rms=reform(a(i_Egas_rms-1,*))
if defined(i_Egas_max) ne 0 then Egas_max=reform(a(i_Egas_max-1,*))
if defined(i_Frms) ne 0 then Frms=reform(a(i_Frms-1,*))
if defined(i_Fmax) ne 0 then Fmax=reform(a(i_Fmax-1,*))
if defined(i_lnccm) ne 0 then lnccm=reform(a(i_lnccm-1,*))
;
pmulti = !p.multi
;
if (((i_urms or i_um2) ne 0) and ((i_brms or i_bm2) ne 0)) then $
    !p.multi=[0,1,2]
if i_urms ne 0 then plot,tt,urms,yst=0,TITLE='Velocity'
if i_um2 ne 0 then oplot,tt,sqrt(um2),line=1
if i_brms ne 0 then plot_io,tt,brms,TITLE='B-field'
if i_bm2 ne 0 then oplot,tt,sqrt(bm2),line=1
;
!p.multi=[0,pmulti[1:*]]

;!p.multi=0
;save,file='hydro.sav',t,jmax2,j2m,bmax2,b2m
;save,file='magnetic.sav',t,jmax2,j2m,bmax2,b2m
END
