;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; is_in_common.ncl
; Carl Schreck (cjschrec@ncsu.edu)
; January 2015
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Description: Take two arrays and return a logical array, same size as the 
; first array, of values that occur in both arrays
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
undef ( "is_in_common" )
function is_in_common( \\
  x[*] , \\
  y[*] \\
)
local None
begin

  retVal = new( dimsizes(x), logical )
  do i = 0, dimsizes(x)-1
    retVal(i) = any( x(i).eq.y )
  end do

  return(retVal)

end; is_in_common

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Description: Take two arrays and return the indices, relative to the first
; array, of values that occur in both arrays
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
undef ( "common_ind" )
function common_ind( \\
  x[*] , \\
  y[*] \\
)
local None
begin

  keepX = is_in_common( x, y )

  retVal = ind(keepX)
  return(retVal)

end; common_ind


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Description: Return a list of values that are common to two arrays
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
undef ( "common_values" )
function common_values( \\
  x[*] , \\
  y[*] \\
)
local None
begin

  xInd = common_ind( x, y )
  if( all( ismissing(xInd) ) ) then
    if( isatt( x, "_FillValue" ) ) then
      retVal = x@_FillValue
    else
      retVal = default_fillvalue( typeof(x) )
      retVal@_FillValue = retVal
    end if  
  else
    retVal = x(xInd)
    copy_VarAtts( y, retVal )
  end if

  return(retVal)

end; common_values


