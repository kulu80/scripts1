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
; User Input
;***************************************************************
  diri = "./"
  fili = systemfunc (" ls -1 " + diri + "daily_clim.bin.* ")
  nfili = dimsizes(fili)
  print(nfili)
  print(fili)
  print (" ")

  do it=0,5                                           ; OUTPUT
   netCDF = True                             ; generate netCDF file
   PLOT   = True                             ; generate plots

   if (netCDF) then
       ncDir   = "./"                        ; directory for netCDF output
       ncFil   = fili(it) + ".nc"                ; netCDF name output
   end if

   if (PLOT) then
       pltDir  = "./"                        ; directory for plot output
       pltName = "cpcFamine"                 ; netCDF name output
       pltType = "x11"                       ; send graphics to PNG file 
   end if

;***************************************************************
; End User Input
;***************************************************************
; Miscellaneous: Parse the file name to extract date string
;***************************************************************
   filc        = stringtochar(fili(it)) 
   date_str    = chartostring(filc(15:22))    ; yyyymmdd as a string
   if (PLOT) then
       pltName = pltName +"_"+date_str
   end if

;***************************************************************
; Read (big endian) binary file regardless of current system
;***************************************************************
   setfileoption("bin","ReadByteOrder","BigEndian")

   nlat  = 801
   mlon  = 751 

   cpc   = fbindirread(diri+fili(it),0, (/nlat,mlon/),"float")

;***************************************************************
; Add meta data
;***************************************************************
   cpc@_FillValue  = -999.
   cpc@units       = "mm/day"
   cpc@long_name   = "precip"

;***************************************************************
; Create/Add coordinate variables. See readme file
;***************************************************************
   lat       = -40 + ispan(0,nlat-1,1)*0.10  
   lon       = -20 + ispan(0,mlon-1,1)*0.10 
                                        ;latitude
   lat!0     = "lat"
   lat&lat   =  lat
   lat@units = "degrees_north"
                                        ;longitude
   lon!0     = "lon"
   lon&lon   =  lon
   lon@units = "degrees_east"

;***************************************************************
; Associate the spatial coordinates with variables
;***************************************************************

   cpc!0    = "lat"                   ; 1st ... name the dimensions
   cpc!1    = "lon"
   cpc&lat  =  lat                    ; create coordinate variable
   cpc&lon  =  lon                 

;***************************************************************
; Simple data exploration: 
;    Are there missing data?
;    Count the number of missing values in each variable
;    Calculate weighted areal averages: ignore missing grid points
;    Print Min/Max
;    Print dispersion information
; Print results
;***************************************************************

   nMsg      = num(ismissing(cpc ))

   rad      = 4.*atan(1.0)/180.
   clat     = cos(lat*rad)    ; simple cosine weighting
   cpcAvg   = wgt_areaave( cpc, clat, 1.0, 0)

   print(" ")
   print("Number missing:  nMsg="+nMsg+": cpcAvg="+cpcAvg+" "+cpc@units)
   printMinMax(cpc, True)
   print(" ")
   
   opt = True
   opt@PrintStat = True
   statb = stat_dispersion(cpc, opt )  ; most values are 0.0
                                       ; possible 'outliers'
;************************************************
; Create plot ?
;************************************************
   if (PLOT) then
       wks    = gsn_open_wks(pltType, pltDir+pltName)
       colors = (/"white", "PaleTurquoise","PaleGreen","SeaGreen3" ,"Yellow"  \
               ,"Orange","HotPink","Red","Violet", "Purple", "Brown"/) 
   
       res                      = True     ; plot mods desired
       res@tiMainString         = "CPC Famine EWS: "+date_str
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
   
       plot = gsn_csm_contour_map(wks,cpc, res)
   end if    ; PLOT
  
;************************************************
; Create netCDF ?
; Recommend to always create a 'time' dimension 
;************************************************

   if (netCDF) then
       ntim     = 1
       yyyy     = stringtointeger( (/filc(15:18)/) ) 
       mm       = stringtointeger( (/filc(19:20)/) ) 
       dd       = stringtointeger( (/filc(21:22)/) ) 
       hh       = 12             ; center of 'mass' for the day
       mn       = 0

       tunits   = "hours since 1990-01-01 00:00:0.0"
       time     = cd_inv_calendar(yyyy,mm,dd,hh,mn,0d0,tunits, 0)
       time!0   = "time"

       date     = yyyy*1000000 + mm*10000 + dd*100 + hh
       date!0   = "time"
       date@units = "yyyymmddhh"
       
       nline  = inttochar(10)

       globeAtt              = 1
       globeAtt@title        = "CPC/Famine Early Warning System Daily Estimates"
       globeAtt@ftp          = "ftp://ftp.cpc.ncep.noaa.gov/fews/newalfo_est/"
       globeAtt@description  = "http://www.cpc.noaa.gov/fews/newalfo_est/readme.txt"
       globeAtt@creation_date= systemfunc ("date" )
     
       NCFILE = ncDir + ncFil
       system ("/bin/rm -f " +  NCFILE)    ; remove any pre-exist file 
           
       ncdf   = addfile(NCFILE,"c")     
     
      ;setfileoption(ncdf, "definemode", True)
     
       fileattdef( ncdf, globeAtt )        ; create the global [file] attributes
                                         
       dimNames = (/"time", "lat", "lon" /)  
       dimSizes = (/ ntim ,  nlat,  mlon /) 
       dimUnlim = (/ True , False, False /)   
       filedimdef(ncdf, dimNames  , dimSizes,  dimUnlim )
     
       filevardef   (ncdf, "time"  , typeof(time), getvardims(time) )
       filevarattdef(ncdf, "time", time)
     
       filevardef   (ncdf, "lat", typeof(lat), getvardims(lat))
       filevarattdef(ncdf, "lat", lat)
          
       filevardef   (ncdf, "lon", typeof(lon), getvardims(lon))
       filevarattdef(ncdf, "lon", lon)
     
       filevardef   (ncdf, "date"  , typeof(date), getvardims(date) )
       filevarattdef(ncdf, "date", date)
     
       filevardef    (ncdf, "CPC", typeof(cpc ) , (/ "time", "lat", "lon" /) )

       filevarattdef (ncdf, "CPC", cpc )
     
       ncdf->time   = (/ time /)
       ncdf->lat    = (/ lat /)
       ncdf->lon    = (/ lon /)
       ncdf->date   = (/ date /)

       ncdf->CPC(0,:,:) = (/ cpc  /)

   end if    ; netCDF
end do
  end

