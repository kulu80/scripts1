#!/bin/bash
##-------------------------------------------------------
##-------------------------------------------------------

## Written by Bantwale D. Enyew (02/12/2018)

## -------------------------------------------------------
#---------------------------------------------------------

## This script will perform the following
## 1. Select /zoom  global data (trmm or cmorph) into WRF domain region
## 2. Extract griddes from the selected region of trmm/cmorph used
##    to interpolate wrf data to trmm/cmorph grid resolution
## 3. Select variables of interest from wrfout to save space and memory
##    for  further analysis.
## 4.  Interpolate the wrfout into trmm/cmorph resolution

## __________________________________________________________________
## __________________________________________________________________


# Working on #1.

      echo "Working on problem 1 ....."
      
   

      for filename in   pr_* ;

       do
   
         #cdo select,date="$i" "$filename" zday_jjaph1"$i"

          cdo setgridtype,lonlat "$filename" latlon_"$filename" 
         #ncks -O -H --msa -d Lon,0.,180. -d Lon,-180.,-1.0 "$filename"  r2curv_"$filename"
        #ncap2 -O -s 'where(Lon < 0) Lon=Lon+360' r2curv*.nc r22curv*.nc
  
      done  

    echo "completed sucessfully  ..........."


