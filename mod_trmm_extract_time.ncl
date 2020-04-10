;******************************************************************************
;
;   Lakemariam Y. Worku - 2019
;
;******************************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
load "/home/bantwale/ftp.cpc.ncep.noaa.gov/fews/fewsdata/africa/arc2/bin/is_in_common.ncl"

begin



; Read trmm data and its dimension
          diri = "./"
          fili = systemfunc (" ls -1 " + diri + "3B42_Daily*.nc4 ")
          nfili = dimsizes(fili)
         ; print(nfili)
         ; print(fili)
         ; print (" ")
do it=0,nfili-1
        f = addfile(fili(it), "r")
        print(f)
        precip = f->precipitation
        ;time = f->time
        ;print(time)
        lat  = f->lat
        lon  = f->lon
	nlon = 1440 ;
	nlat = 400 ;

;**************************************************************
    filc        = tochar(fili(it) )
    print(filc)
    date_str    = (/ filc(13:20) /)        ; yyyymmdd as a string
    print(date_str)
    file_str    = (/ filc(2:20)/)        ; unique

    print(file_str)
           
   lat!0     = "lat"
   lat&lat   =  lat
   lat@units = "degrees_north"
                                        ;longitude
   lon!0     = "lon"
   lon&lon   =  lon
   lon@units = "degrees_east"
   precip@_FillValue = -9999.
   precip@units      = "mm/day"
   precip@long_name  = "Precipitation"
   ntim     = 1
  yyyymmdd  = stringtointeger( (/date_str( 0: 7)/) )  ;(/19900101, 19950105, 19981102, 20030423, 20100612/)

  ntim  = nfili

  yyyy  = yyyymmdd/10000 
  mmdd  = yyyymmdd-yyyy*10000                ; mmdd = yyyymmdd%10000
  mm    = mmdd/100
  dd    = mmdd-mm*100                        ; dd   = mmdd%100

  hh    = dd                                 ; create arrays [*] of required size
  mn    = dd
  sc    = dd

  hh    = 0                                  ; array syntax
  mn    = 0
  sc    = 0
                                             ; user specified
  units  = "hours since 1900-01-01 00:00:00" ; "seconds/hours/days since ...."
                                             ; do NOT use "months since ...."

  time   = cd_inv_calendar(yyyy,mm,dd,hh,mn,sc,units, 0) 
  time!0 = "time"
  time&time = time
  print(time)

       date     = yyyy*1000000 + mm*10000 + dd*100 + hh
       date!0   = "time"
       date@units = "yyyymmddhh"




 ;   yyyy     = stringtointeger( (/date_str( 0: 3)/) )
 ;   mm       = stringtointeger( (/date_str( 4: 5)/) )
 ;    dd       = stringtointeger( (/date_str( 6: 7)/) )
 ;     hh       = 12             ; center of 'mass' for the day
 ;      mn       = 0
;
;       tunits   = "hours since 1990-01-01 00:00:0.0"
;       time     = cd_inv_calendar(yyyy,mm,dd,hh,mn,0d0,tunits, 0)
 ;      time!0   = "time"
;
;       date     = yyyy*1000000 + mm*10000 + dd*100 
 ;      date!0   = "time"
 ;      date@units = "yyyymmdd"

       nline  = inttochar(10)

       globeAtt              = 1 
       globeAtt@title        = "TRMM: 0.25 Daily"
       globeAtt@ftp          = "https://disc.gsfc.nasa.gov/datasets?keywords=TRMM_3B42%20bin&page=1/daily_025deg"
       globeAtt@acronym      = "TRMM Technique"
       globeAtt@description  = "https://disc.gsfc.nasa.gov/datasets?keywords=TRMM_3B42%20bin&page=1"
       globeAtt@referenceon  = nline + \
                              "Joyce, R. J., J. E. Janowiak, P. A. Arkin, and P. Xie, 2004:       "+nline+\
                              "CMORPH: A method that produces global precipitation estimates      "+nline+\
                              "        from passive microwave and infrared data at high spatial   "+nline+\
                              "        and temporal resolution. J. Hydromet., 5, 487-503.         "+nline

       globeAtt@creation_date= systemfunc ("date" )
 

       ncDir   = "./"                        ; directory for netCDF output
       ncFil   = "znew"+ file_str + ".nc"                ; netCDF name output

 
       NCFILE = ncDir + ncFil
       system ("/bin/rm -f " +  NCFILE)
       ncdf   = addfile(NCFILE,"c")
       
       ;fileattdef( ncdf, None)      ;fileattdef( ncdf, globeAtt )        ; create the global [file] attributes

       dimNames = (/"time", "lat", "lon" /)
       dimSizes = (/ ntim ,  nlat,  nlon /)
       dimUnlim = (/ True , False, False /)
       filedimdef(ncdf, dimNames  , dimSizes,  dimUnlim )

       filevardef   (ncdf, "time"  , typeof(time), getvardims(time) )
       filevarattdef(ncdf, "time", time)

       filevardef   (ncdf, "lat", typeof(lat), getvardims(lat))
       filevarattdef(ncdf, "lat", lat)

       filevardef   (ncdf, "lon", typeof(lon), getvardims(lon))
       filevarattdef(ncdf, "lon", lon)
       filevardef    (ncdf, "precip", typeof(precip) , (/ "time", "lat", "lon" /) )
       filevarattdef (ncdf, "precip", precip )
       ncdf->time   = (/ time /)
       ncdf->lat    = (/ lat /)
       ncdf->lon    = (/ lon /)
      ; ncdf->date   = (/ date /)
      
        ncdf->precip = precip  ; trick to force 2D array into 3D reserved space 
        ;utc_date = cd_calendar(time,0)
        ;nc_year = toint(utc_date(:,0))
	;nc_month = toint(utc_date(:,1))
	;nc_day = toint(utc_date(:,2))
        
        ;nc_time = sprinti("%0.4i", nc_year) + "" + sprinti("%0.2i", nc_month) + "" + sprinti("%0.2i", nc_day)
       ;print(nc_time)
       ; nc_ntim = dimsizes(nc_time)
	;print(nc_ntim)

;	print(cd_string(time,""))

; Write new netCDF file that has a time dimension similar to CSV file
        
       ; ncInd = common_ind( nc_time, csv_time ) 
      ;  outFile = "fili(it).nc"
      ;  system("rm -f " + outFile)
      ;  fout = addfile(outFile, "c")
       ; fout->precip = precip
;
end do
end














