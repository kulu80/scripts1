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
      
   

      for filename in   z3B42_Daily.*;

       do
   
         #cdo select,date="$i" "$filename" zday_jjaph1"$i"

         cdo selmon,7,8,9,10 "$filename" jaso_"$filename"
         #cdo selyear,2030/2060 "$filename" rcp85_mid"$filename" 
  
      done  

    echo "completed sucessfully  ..........."


