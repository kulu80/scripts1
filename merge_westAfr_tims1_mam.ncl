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
      a=addfile("merge_cpc_all_mam_westAfr.nc","r")
      cpc=a->CPC
      lat=a->lat
      lon=a->lon
      time=a->time
      ntime = dimsizes(time)
      print(ntime)
      utc_date = cd_calendar(time,0)
      nc_year = toint(utc_date(:,0))
      nc_month = toint(utc_date(:,1))
      nc_day = toint(utc_date(:,2))

      nc_time = sprinti("%0.4i", nc_year) + "" + sprinti("%0.2i", nc_month) + "" + sprinti("%0.2i", nc_day)
      print(nc_time)
      uAve_area = wgt_areaave(cpc, 1.0, 1.0, 0)
      print(uAve_area) 
      filename = "dialy_arealave_westAfr_mam.csv"
      dq = str_get_dq()
      fields = (/"date", "Precip","time"/)
      fields = dq + fields + dq
      header = [/str_join(fields,",")/]
      format = "%s,%4.2f"
      system("rm -rf " + filename)
      write_table(filename, "w", header, "%s") 
     ; write_table(filename,"w",[/nc_time,uAve_area/],"%2i,%2i")  
     ; lines = sprinti("%8d",nc_time) + "," + sprinti("%8i",uAve_area) 
     ; asciiwrite(filename,lines)

     ;PLOT   = False                            ; generate plots
 do it=0,ntime-1 
        PLOT   = False                            ; generate plots
     ; print(nc_time(it))
     ; write_table(filename,"w",[/nc_time(it),uAve_area(it)/],"%2i,%2i")
       alist = [/nc_time(it),uAve_area(it)/]
       write_table(filename, "a", alist, format)
       if (PLOT) then
       wks    = gsn_open_wks("x11", "test")
       colors = (/"white", "PaleTurquoise","PaleGreen","SeaGreen3" ,"Yellow"  \
               ,"Orange","HotPink","Red","Violet", "Purple", "Brown"/) 
   
       res                      = True     ; plot mods desired
       res@tiMainString         = "CPC Famine EWS: "
       res@gsnAddCyclic         = False    ; data not global
       res@gsnMaximize          = True     ; make ps, eps, pdf large
     
       res@cnFillOn             = True     ; turn on color fill
       res@cnFillPalette        = colors   ; set color map
       res@cnLinesOn            = False    ; turn of contour lines
       res@cnFillMode           = "RasterFill"         ; Raster Mode
       res@cnLinesOn            =  False       ; Turn off contour lines
       res@cnLineLabelsOn       =  False       ; Turn off contour lines
       res@cnLevelSelectionMode = "ExplicitLevels"              
       res@cnLevels             = (/0.1,1,2.5,5,10,15,20,25,50,75/) ; "mm/day" 

       res@lbOrientation        = "vertical"
   
       res@mpMinLatF            = min(lat)
       res@mpMaxLatF            = max(lat)
       res@mpMinLonF            = min(lon)
       res@mpMaxLonF            = max(lon)
       res@mpCenterLonF         = (res@mpMinLonF + res@mpMaxLonF)*0.5
       res@mpFillOn             = False
       res@mpOutlineBoundarySets= "National"    ; turn on country boundaries
   
       plot = gsn_csm_contour_map(wks,cpc(it,:,:), res)
  end if 
end do
  
  end
