;***************************************************************
; cpcfamine_1.ncl
;
; Concepts illustrated:
;   - Reading big endian binary files
;   - Adding geographic coordinates
;   - Explicitly setting contour levels
;
;***************************************************************
; CPC/Famine Early Warning System Daily Estimates
; Readme: ftp://ftp.cpc.ncep.noaa.gov/fews/newalgo_est/RFE_readme.txt
;***************************************************************

;*****************Load Libraries ************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
;**************************************************************
;                     MAIN
;**************************************************************
begin
;***************************************************************
      a1=addfile("mean_DJF_cpc2019.nc","r")
      a2=addfile("mean_MAM_cpc2019.nc","r")
      a3=addfile("mean_JJAS_cpc2019.nc","r")
      a4=addfile("mean_SON_cpc2019.nc","r")

      f1=addfile("DJF_meanclim_cpc2012.nc","r")
      f2=addfile("MAM_meanclim_cpc2012.nc","r")
      f3=addfile("JJAS_meanclim_cpc2012.nc","r")
      f4=addfile("SON_meanclim_cpc2012.nc","r")     


      cpc_clim_djf=a1->CPC
      ;print(cpc_clim_djf)
      lat=a1->lat
      lon=a1->lon
      cpc_clim_mam=a2->CPC
      cpc_clim_jjas=a3->CPC
      cpc_clim_son=a4->CPC

      cpc_2019_djf=f1->CPC
      cpc_2019_mam=f2->CPC
      cpc_2019_jjas=f3->CPC
      cpc_2019_son=f4->CPC
      anom_djf = cpc_2019_djf
      ;anom_djf = cpc_2019_djf - cpc_2019_djf
      ;print(anom_djf)



       wks    = gsn_open_wks("x11", "mean_2019")
       plot = new(4,graphic) 

      ; colors = (/"white", "PaleTurquoise","PaleGreen","SeaGreen3" ,"Yellow"  \
      ;         ,"Orange","HotPink","Red","Violet", "Purple", "Brown"/)



           colors = (/ "azure1","beige","lavender" \
            ,"PaleGreen","SeaGreen3","LightYellow" \
            ,"Yellow","HotPink","Red"/)         ; choose colors for color map 
       
        ; colors = (/ (/255,255,255/), (/244,255,244/), \
        ;      (/217,255,217/), (/163,255,163/), (/106,255,106/), \
        ;      (/43,255,106/), (/0,224,0/), (/0,134,0/),(/255,255,0/),\
        ;      (/255,127,0/) /) / 255.   ; be sure to make this a float!
       res                      = True     ; plot mods desired
       res@tiMainString         = "  "
       res@gsnAddCyclic         = False    ; data not global
       res@gsnMaximize          = True     ; make ps, eps, pdf large
     
       res@cnFillOn             = True     ; turn on color fill
       res@cnFillPalette        = colors   ; set color map
       res@cnLinesOn            = False    ; turn of contour lines
       res@cnFillMode           = "RasterFill"         ; Raster Mode
       res@cnLinesOn            =  False       ; Turn off contour lines
       res@cnLineLabelsOn       =  False       ; Turn off contour lines
       res@cnLevelSelectionMode = "ExplicitLevels"              
    ;   res@cnLevels             = (/0.1,1,1.5,3,5,7,11.5,12.8,25.6/) ; "mm/day
        res@cnLevels             = (/ 0.5, 1.0, 2.0 \ ; set unequal contour levels
                              , 3.0, 4.0, 5.0 \
                              , 7.5,10.0 /) 
       res@lbLabelBarOn        = False            ; turn off individual cb's
       ;res@lbOrientation        = "vertical"
       res@gsnRightString        =  " "
       res@gsnLeftString         =  " "
       res@mpMinLatF            =  -7 ;min(lat)
       res@mpMaxLatF            =  20 ;max(lat)
       res@mpMinLonF            =  20 ;min(lon)
       res@mpMaxLonF            =  55 ;max(lon)
       res@mpCenterLonF         = (res@mpMinLonF + res@mpMaxLonF)*0.5
       res@mpFillOn             = False
       res@mpOutlineBoundarySets= "National"    ; turn on country boundaries
   
       plot = gsn_csm_contour_map(wks,cpc_clim_djf(0,:,:), res)
       plot(0) = gsn_csm_contour_map(wks,cpc_clim_djf(0,:,:), res) 
       plot(1) = gsn_csm_contour_map(wks,cpc_clim_mam(0,:,:), res) 
       plot(2) = gsn_csm_contour_map(wks,cpc_clim_jjas(0,:,:), res) 
       plot(3) = gsn_csm_contour_map(wks,cpc_clim_son(0,:,:), res)
 
;;;;;;  Pnael resource
          resP                    = True                 ; modify the panel plot
          resP@gsnFrame           = True                ; don't advance panel plot
          resP@gsnPanelLabelBar   = True                 ; add common colorbar
          resP@gsnPanelBottom     = 0.05
          resP@gsnPanelMainString = " "     ; set main title
          ;gsn_panel(wks,plot,(/3,1/),resP)               ; now draw as one plot

          gsn_panel(wks,plot,(/2,2/),resP)             ; now draw as one plot

  
  end
