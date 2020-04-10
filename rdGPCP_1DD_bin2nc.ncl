; -------------------------------------------------------
; GPCP ONE-DEGREE DAILY PRECIPITATION DATA SET
;
; standard: http://precip.gsfc.nasa.gov/
;
; -------------------------------------------------------
; read the documentation for updates and details
; -------------------------------------------------------
; Convert binary to netCDF
; -------------------------------------------------------
;               USER INPUT
; -------------------------------------------------------

  VERSION = "v1.2"
  DIRI    = "/scratch/shea/GPCP/1dd-"+VERSION+"/"    ; input directory w ungzipped files
  DIRO    = "/scratch/shea/GPCP/netCDF_"+VERSION+"/NC4/" ; output directory with netCDF

  NCV     = "NC4"           ; "NC3" or "NC4"
  PACK    = False
; -------------------------------------------------------
;               END USER INPUT
; -------------------------------------------------------
  if (PACK) then
      optPack = True
      optPack@min_value = 0.
      optPack@max_value = 5000.                   ; Max value thru 2009 = 1975 mm/day :-)
      optPack@scale_factor =  0.1                 ; Hence, 5000 is more than adequate.
      optPack@add_offset   =  0.0
  else
      optPack = False
  end if

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

; -------------------------------------------------------
; define lat/lon grid: GPCP goes from N=>S
; -------------------------------------------------------
  nlat = 180
  mlon = 360
  lon  = lonGlobeFo(mlon,"lon","longitude","degrees_east")
  lat  = latGlobeFo(nlat,"lat","latitude","degrees_north")
  lat  = lat(::-1)      ; make N=>S
  printVarSummary(lat)

; -------------------------------------------------------
; Define generic file attributes
; -------------------------------------------------------

   nline           = inttochar(10)    ; new line character
   fAtt            = 0  ; attributes for netCDF file
   fAtt@creation_date =  systemfunc("date")

   fAtt@ref_3      =  nline + \
       "Adler, Robert F., Guojun Gu, George J. Huffman, 2012: " + nline + \ 
       "Estimating Climatological Bias Errors for the Global Precipitation Climatology Project (GPCP)" + nline + \
       "J. Appl. Meteor. Climatol., 51, 84-99" + nline + \
       "http://dx.doi.org/10.1175/JAMC-D-11-052.1" + nline 

   fAtt@ref_2      =  nline + \
       "Bolvin, David T., Robert F. Adler, George J. Huffman  " + nline + \
       "Eric J. Nelkin, Jani P. Poutiainen, 2009:             " + nline + \
       "Comparison of GPCP Monthly and Daily Precipitation Estimates with High-Latitude Gauge Observations" + nline + \
       "J. Appl. Meteor. Climatol., 48, 1843-1857" + nline + \
       "http://dx.doi.org/10.1175/2009JAMC2147.1" + nline

   fAtt@ref_1      =  nline + \
       "Huffman, G.J., R.F. Adler, M.M. Morrissey, S. Curtis  " + nline + \
       "R. Joyce, B. McGavock, and J. Susskind, 2001:         " + nline + \
       "Global precipitation at one-degree daily resolution from multi-satellite observations" + nline +\  
       "J. Hydrometeor., 2, 36-50" + nline

   fAtt@Conversion = "NCL: http://www.ncl.ucar.edu/"
   fAtt@comment    = "netCDF version of original binary file(s)"
   fAtt@Convention = "CF-1.0"
   fAtt@Acknowledgement = nline + \
"Please cite the original source of the data." + nline +\
"Please email the citation to george.j.huffman@nasa.gov or david.t.bolvin@nasa.gov" + nline
   fAtt@Source     = "ftp://meso.gfsc.nasa.gov//pub/1dd-v1.2/"
   fAtt@information= "http://precip.gsfc.nasa.gov/gpcp_daily_comb.html"
   fAtt@GSFC       = "http://precip.gsfc.nasa.gov/"
   fAtt@title      = "GPCP ONE-DEGREE DAILY PRECIPITATION DATA SET"

; -------------------------------------------------------
; names of all 1dd files in the directory "diri"
; -------------------------------------------------------
   diri = DIRI
   fili = systemfunc("cd "+diri+" ; ls gpcp_1dd_"+VERSION+"_p1d*")
   nfil = dimsizes( fili )
   print(fili)

   diro = DIRO
; -------------------------------------------------------
; Loop over all files and create individual netCDF.
; Use "ncrcat" if one file is desired.
; -------------------------------------------------------
  setfileoption("bin","ReadByteOrder","BigEndian")

  if (NCV.eq."NC4") then
      setfileoption("nc","Format","NetCDF4Classic")
  end if

  do nf=0,nfil-1
     yyyy  = toint( str_get_cols(fili(nf), 18, 21) )
     mm    = toint( str_get_cols(fili(nf), 22, 23) )

     ntim  = days_in_month(yyyy, mm )

          ; read header + all days in the month
     dumy  = fbindirread(diri+fili(nf),0,360+ntim*360*180,"float")

          ; create netCDF
     prec  = onedtond( dumy(360:), (/ntim,nlat,mlon/) )   ; skip header
     delete (dumy)   ; size may change for next month

; ---------------------------------------------------------
; Construct primary data structure
; ---------------------------------------------------------
     prec@version    = VERSION  
     prec@missing_value = -99999.
     prec@_FillValue = -99999.
     prec@units      = "mm/day"
     prec@long_name  = "GPCP: daily precipitation"

     prec!0   = "time"
     prec!1   = "lat"
     prec!2   = "lon"

     prec&lat =  lat
     prec&lon =  lon

; ---------------------------------------------------------
; create (multiple) time variables for user convenience
; ---------------------------------------------------------
     yyyymm = yyyy*100 + mm
     days   = ispan(1,ntim,1)
     hh     = 12                      ; middle of day (arbitrary) 

     date   = yyyymm*100 + days   
     date!0 = "time"
     date@units     = "yyyymmdd"
     date@long_name = "gregorian date"

     yyyyddd= yyyymmdd_to_yyyyddd( date ) 
     yyyyddd!0 = "time"
     
     YYYY   = conform(date, yyyy, -1)  ; make scalar a vector to match "days"
     MM     = conform(date,   mm, -1)
     HH     = conform(date,   hh, -1)
     ZERO   = conform(date,    0, -1)

     tunits = "days since 1990-01-01 00:00:00"      ; arbitrary
     time   = ut_inv_calendar(YYYY,MM,days,HH, ZERO , ZERO ,tunits, 0)
     time!0 = "time"
     time@long_name = "time"
     time@units     = tunits

; ---------------------------------------------------------
; create netCDF
; ---------------------------------------------------------
     yyyymm = yyyy*100 + mm
    ;ncfile = diro+fili(nf)+".nc"
     ncfile = diro+"GPCP_1DD_"+VERSION+"_"+yyyymm+".nc"
     print (""+ncfile)
     system ("/bin/rm -f " + ncfile)  ; remove an pre-file
   
     ncdf   = addfile(ncfile,"c")       ; "c"reate the netCDF file
   
     fileattdef( ncdf, fAtt )
   
     dimNames = (/ "time", "lon", "lat"  /)
     dimSizes = (/   -1  ,  mlon, nlat   /)
     dimUnlim = (/  True , False, False  /)
     filedimdef( ncdf, dimNames, dimSizes, dimUnlim )
                                            ; Define 1D variables.
     filevardef   ( ncdf, "time", typeof(time), getvardims(time) )
     filevarattdef( ncdf, "time", time )
   
     filevardef   ( ncdf, "lat", typeof(lat), getvardims(lat) )
     filevarattdef( ncdf, "lat", lat )
   
     filevardef   ( ncdf, "lon", typeof(lon), getvardims(lon) )
     filevarattdef( ncdf, "lon", lon )
                                            ; Define 1D variables.
     filevardef   ( ncdf, "date", typeof(date), getvardims(date) )
     filevarattdef( ncdf, "date", date )

     filevardef   ( ncdf, "yyyyddd", typeof(yyyyddd), getvardims(yyyyddd) )
     filevarattdef( ncdf, "yyyyddd", yyyyddd )
   
     if (PACK) then
         filevardef   ( ncdf, "PREC", "short", getvardims(prec) )
         pShort     = pack_values(prec, "short", optPack)
         delete(pShort@vMin_original_data)     ; extraneous
         delete(pShort@vMax_original_data)
         filevarattdef( ncdf, "PREC", pShort )
     else
         filevardef   ( ncdf, "PREC", typeof(prec), getvardims(prec) )
         filevarattdef( ncdf, "PREC", prec )
     end if
                                               ; Write variables.
     ncdf->time     = (/time/)
     ncdf->lat      = (/lat /)
     ncdf->lon      = (/lon /)
     ncdf->date     = (/date/)
     ncdf->yyyyddd  = (/yyyyddd/)
     if (PACK) then
         ncdf->PREC = (/pShort/)
         delete(pShort)
     else
         ncdf->PREC = (/prec/)
     end if

                    ; size may change for next month
     delete( [/ prec, time, date, days, yyyyddd, YYYY, MM, HH, ZERO/] )
  end do
  
end
