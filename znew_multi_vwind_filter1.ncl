; **********************************************
; filters_3.ncl
; **********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"    
begin

  dir = "./"
;  files = systemfunc("ls -1"+ dir + "zzdaymean*")
   files = systemfunc (" ls -1 " + dir + "jjason_latlon_va850_AFR-44_CSIRO-QCCCE-CSIRO-Mk3-6-0_rcp85_r1i1p1_SMHI-RCA4_v1_day*.nc")  ; 
   numfiles = dimsizes(files)
   print(files)
   print(" ")


; ***********************************************
; create the filter weights and apply
; ***********************************************

  ihp                        = 2                             ; band pass
  sigma                      = 1.0                           ; Lanczos sigma

  nWgt                       = 61                           ; loose 100 each end                            
  fca                        = 1./10.                       ; start freq
  fcb                        = 1./2.                        ; last  freq
  wgt                        = filwgts_lanczos (nWgt, ihp, fca, fcb, sigma )
  printVarSummary(wgt)

 do it = 0,numfiles-1
    ; vName                      = "v"        ; name of variable on the file
     f = addfile(files(it), "w")

     x = f->va850
    ; x = f->ua
  
    xBPF                       = wgt_runave_n_Wrap( x, wgt, 0,0 )      ; 20-100 day
  
    printVarSummary(xBPF)
    f->vvwind = xBPF 
  
end do

end
