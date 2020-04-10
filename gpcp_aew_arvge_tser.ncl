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
   dir                      = "./"

  
     a  = addfile("GPCP_1DD_v1.2_199610-201510.nc", "r")
      print(a)
      cpc=a->PREC(:,:,:)
     
      lat=a->lat
      printMinMax(lat,False)
      
      lon=a->lon
      printMinMax(lon,False)
      time=a->time
      ;plev=a->plev
      ;print(plev)
      ntime = dimsizes(time)
      ;print(ntime)
      utc_date = cd_calendar(time,0)
      nc_year = toint(utc_date(:,0))
      nc_month = toint(utc_date(:,1))
      nc_day = toint(utc_date(:,2))

       nc_time = sprinti("%0.4i", nc_year) + "" + sprinti("%0.2i", nc_month) + "" + sprinti("%0.2i", nc_day)
    ;  print(nc_time)
       uAve_area = dim_avg_n(cpc(:,{7.5:20},{-20:0}),(/1,2/))
       print(uAve_area) 
       filename = "gpcp_daily_arealavg_precip.csv"
       dq = str_get_dq()
       fields = (/"nc_time", "uAve_area","plev"/)
       fields = dq + fields + dq
      header = [/str_join(fields,",")/]
      format = "%s,%4.2f"
    ;  system("rm -rf " + filename)
    ;  write_table(filename, "w", header, "%s") 
     ; write_table(filename,"w",[/nc_time,uAve_area/],"%2i,%2i")  
     ; lines = sprinti("%8d",nc_time) + "," + sprinti("%8i",uAve_area) 
     ; asciiwrite(filename,lines)
     ;write_table(filename, "w",  uAve_area(:,:), "%4.2f")
       alist = [/nc_time,uAve_area/]
      write_table(filename, "a", alist, format)

end
