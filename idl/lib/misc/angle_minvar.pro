;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   angle_minvar.pro   ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;
;;;  Author: wd (Wolfgang.Dobler@ucalgary.ca)
;;;  Date:   03-Feb-2005
;;;
;;;  Description:
;;;   Mak an angle array as continuous as possible (i.e. minimize the
;;;   total variation) by adding or subtracting 2*!pi wherever necessary 
;;;  Usage:
;;;   plot, t, angle_minvar(phi)
;;;   plot, t, angle_minvar(phi, /CENTER)

function angle_minvar, v

  vec = reform(v)
  s = size(vec)
  if (s[0] ne 1) then message, 'Need 1-d array'
  N = s[s[0]+2]

  pi2 = 2*!pi
  for i=1,N-1 do begin
    dv = vec[i]-vec[i-1]
    ;; Can't use mod, because IDL's mod() is really stupid for
    ;; negative arguments --- but floor does the job:
    shift = -floor(dv/pi2+0.5)*pi2
    vec[i:*] = vec[i:*]+shift

  endfor

  return, vec

end
; End of file angle_minvar.pro
