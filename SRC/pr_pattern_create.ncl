;**************************************
; pattern library
;**************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;**************************************
begin
;****************************************
;define some terms, change based on pattern and person
  TLocal = "PR"
  editor = "CLynch"
  editor_locale = "JGCRI"
  time_increment = "Annual"

; add time indexing HERE.  *H is for historical & *F is for future period

  yStrH = 1961
  yLstH = 1990
  yStrF = 2006
  yLstF = 2099

  diri = "/Volumes/LaCie/CMIP5/rcp85/tas/"
  dirip = "/Volumes/LaCie/CMIP5/rcp85/precip/"
  dirh = "/Volumes/LaCie/CMIP5/historical/precip/"

  fili = systemfunc("ls " + diri + "tas_Amon_*") 
  filip = systemfunc("ls " + dirip + "pr_Amon_*") 
  filh = systemfunc("ls " + dirh + "pr_Amon_*")
  
; read in all data files

  do k = 0,dimsizes(fili)-1
  his1 = addfile(filh(k),"r")
  in2 = filip(k)
  in1 = addfile(fili(k),"r")
  inp1 = addfile(filip(k),"r")

; Remove directories, isolate the base file name.

  nitems = str_fields_count (in2, "/")
  name2  = str_get_field (in2, nitems, "/")

; Isolate selected parts of the file name.  Pattern:
; tas_Amon_[model]_[experiment]_[realization]_[years].nc

  model = str_get_field (name2, 3, "_")
  expt  = str_get_field (name2, 4, "_")
  name  = str_get_field (name2, 1, "_")
  realm  = str_get_field (name2, 2, "_")

; get specific time spans

  time = his1->time
  yyyymm = cd_calendar(time,-1)/100
  iYYYY = ind(yyyymm.ge.yStrH .and. yyyymm.le.yLstH)

  tsh = his1->pr(iYYYY,:,:)
  tsh = tsh *86400 *30.45
  tsh@units = "mm/month"

  delete([/time,yyyymm,iYYYY/])

  time = inp1->time
  yyyymm = cd_calendar(time,-1)/100
  iYYYY = ind(yyyymm.ge.yStrF .and. yyyymm.le.yLstF)

  tspi = inp1->pr(iYYYY,:,:)
  tspi = tspi *86400 *30.45
  tspi@units = "mm/month"

  delete([/time,yyyymm,iYYYY/])

  time = in1->time
  yyyymm = cd_calendar(time,-1)/100
  iYYYY = ind(yyyymm.ge.yStrF .and. yyyymm.le.yLstF)

  tsi = in1->tas(iYYYY,:,:)
  tsi = tsh -273.15
  tsi@units = "Celsius"

; generate weights based on latitude
  lat = in1->lat
  lon = in1->lon
  nlat = dimsizes(lat)
  nlon = dimsizes(lon)

  rad = 4.*atan(1.)/180.
  clat = lat
  clat = sqrt(cos(rad*lat))

; set up output file to display model and experiment in file name

  out_template = "/Volumes/LaCie/CMIP5/outtest/LSR_pr_ANN_MODEL_EXPERIMENT.nc"
  outs = str_sub_str (out_template, "MODEL", model)
  outs = str_sub_str (outs, "EXPERIMENT", expt)

; do annual calculation
; if you would like to do the annual total and not the monthly average, change "1" to "0"
; for seasonal change "*annual" to "*season" & "1" to "DJF" or JFM,MAM,JJA,etc.

  atsh = month_to_annual(tsh,1)
  atsi = month_to_annual(tsi,1)
  atspi = month_to_annual(tspi,1)

; get Tgav annual timeseries

  Tgav = wgt_areaave(atsi,clat,1.0,0)

; get historical climatology for base

  climo = dim_avg_n_Wrap(atsh,0)
  climo@year_start = yStrH
  climo@year_end = yLstH

; reorder Tlocal and use Tgav to predict Tlocal in LSR method

  data = atspi(lat|:,lon|:,year|:)

  coef = regCoef(Tgav,data)
  coef!0 = "lat"
  coef!1 = "lon"
  coef&lat = lat
  coef&lon = lon
  copy_VarCoords(data,coef)
  coef@units = "mm/month per TGAV"
  coef@title = "LSR coefficient"
  coef@original_name = name
  coef@realm = realm
  coef@source = model
  coef@time_average = time_increment

;  calculate rsquared

  r2x = (escorc(Tgav,data))^2
  r2 = 1-(((1-r2x)*93)/92)
  r2!0 = "lat"
  r2!1 = "lon"
  r2&lat = lat
  r2&lon = lon
  copy_VarCoords(data,r2)
  r2@units = "N/A"
  r2@title = "Adjusted Pearson correlation coefficient squared"
  r2@source = model

; calculate 95% confidence interval from LSR error term
; tvalue for 95-2 df at the 95% level = 1.985 (2-tail)
; error term is rstd in regCoef function

  rstdx = new((/nlat,nlon/),float)
  rstdx = (/onedtond(coef@rstd,(/nlat,nlon/))/)
  rstdx!0 = "lat"
  rstdx!1 = "lon"
  rstdx&lat = lat
  rstdx&lon = lon
  rstdx@title = "Standardized error term from LSR equation"
  rstdx@source = model
  rstdx@units = "N/A"

  ci95 = rstdx
  ci95 = rstdx *1.985
  copy_VarCoords(data,ci95)
  ci95@title = "95th %ile confidence interval"
  ci95@units = "mm per TGAV"
  ci95@Tvalue = "95th significance level t-value(2-tail) for df = 95-2 = 1.985"
  ci95@method = "multiplied the LSR error term by Tvalue"
  ci95@long_name = "rstdx from LSR * 95th significance level t-value for df = 95-2"
  ci95@source = model
  ci95@time_average = time_increment

  delete(coef@nptxy)
  delete(coef@rstd)
  delete(coef@yintercept)
  delete(coef@tval)

; regrid to T85 and set lat/lon attributes

  newlat = flt2dble(fspan(-90,90,192))
  newlat@units = "degrees_north"
  newlat@standard_name = "latitude" ;
  newlat@long_name = "latitude" ;
  newlat@axis = "Y" ;
  newlat@units = "degrees_north" ;
  newlat@bounds = "lat_bnds" ;

  newlon = flt2dble(fspan(0,360,288))
  newlon@units = "degrees_east"
  newlon@standard_name = "longitude" ;
  newlon@long_name = "longitude" ;
  newlon@axis = "X" ;
  newlon@units = "degrees_east" ;
  newlon@bounds = "lon_bnds" ;

  rgclimo = linint2_Wrap(climo&lon,climo&lat,climo,True,newlon,newlat,0)
  rgcoef = linint2_Wrap(coef&lon,coef&lat,coef,True,newlon,newlat,0)
  rgr2 = linint2_Wrap(r2&lon,r2&lat,r2,True,newlon,newlat,0)
  rgrstdx = linint2_Wrap(rstdx&lon,rstdx&lat,rstdx,True,newlon,newlat,0)
  rgci95 = linint2_Wrap(ci95&lon,ci95&lat,ci95,True,newlon,newlat,0)

; define metadata of output

  system("/bin/rm -f " + outs)    ; remove file if exists
  out = addfile(outs,"c") 

  out@title = "LSR pattern scaling"
  out@creation_date = systemfunc("date")
  out@methods = "PRlocal regressed onto TGAV via least squared regression"
  out@TGAV = "Globally averaged & weighted by latitude annual PR"
  out@time_increment = time_increment
  out@source_model = model
  out@original_variable = name
  out@NCL_function1 = "month_to_annual (annual mean from monthly data)"
  out@NCL_function2 = "wgt_areaave (weighted area average)"
  out@NCL_function3 = "regCoef (LSR regression)"
  out@Lat_weights = "sqrt(cos(rad*lat))"
  out@regridding = "output was regridded to T85 (/192,288/)"
  out@editor = editor
  out@editor_locale = editor_locale
  out@forcing = expt

  global_attnames = getvaratts(data)

  do i=0,dimsizes(global_attnames)-1
      out@$global_attnames(i)$ = data@$global_attnames(i)$
  end do

  delete(out@NCL)
  delete(out@long_name)
  delete(out@standard_name)
  delete(out@original_name)
  delete(out@coordinates)

  out->pattern = rgcoef
  out->CI95 = rgci95
  out->r2 = rgr2
  out->error = rgrstdx
  out->climatology = rgclimo

  delete([/name,out_template,outs,out,nitems,name2,model,expt,time,yyyymm,iYYYY,tsh,tspi,tsi,atsh,atspi,atsi,Tgav,climo,data,global_attnames,coef,lat,lon,clat,nlat,nlon,rstdx,ci95,r2x,r2,rgclimo,rgcoef,rgr2,rgrstdx,rgci95/])

  end do


end
