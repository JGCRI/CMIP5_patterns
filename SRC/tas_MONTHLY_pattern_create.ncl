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
  TLocal = "TAS"
  editor = "CLynch"
  editor_locale = "JGCRI"
  time_increment = "Months"

; add time indexing HERE.  *H is for historical & *F is for future period

  yStrH = 1961
  yLstH = 1990
  yStrF = 2006
  yLstF = 2099

  months = (/"January","February","March","April","May","June","July","August","September","October","November","December"/)

  diri = "/Volumes/LaCie/CMIP5/rcp85/tas/"
  dirh = "/Volumes/LaCie/CMIP5/historical/tas/"

  fili = systemfunc("ls " + diri + "tas_Amon_*") 
  filh = systemfunc("ls " + dirh + "tas_Amon_*")
  
; read in all data files

  do k = 0,dimsizes(fili)-1
  his1 = addfile(filh(k),"r")
  in2 = fili(k)
  in1 = addfile(fili(k),"r")

; generate weights based on latitude
  lat = in1->lat
  lon = in1->lon
  nlat = dimsizes(lat)
  nlon = dimsizes(lon)

  rad = 4.*atan(1.)/180.
  clat = lat
  clat = sqrt(cos(rad*lat))

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

  tsh = his1->tas(iYYYY,:,:)
  tsh = tsh -273.15
  tsh@units = "Celsius"

  nyrs = dimsizes(iYYYY)/12
  mons = cd_calendar(time(iYYYY),-1)
  yyyy = mons/100
  mm = mons-yyyy*100   

  ind1 = new((/12,nyrs/),integer)
  do i=0,11
  ind1(i,:) = ind(mm.eq.i+1)
  end do

  tshm = new((/12,nyrs,nlat,nlon/),float)
  do i=0,11
  tshm(i,:,:,:) = tsh(ind1(i,:),:,:)
  end do
  tshm!0 = "month"
  tshm!1 = "year"
  tshm!2 = "lat"
  tshm!3 = "lon"
  tshm&lat = lat
  tshm&lon = lon

  delete([/time,yyyymm,iYYYY,nyrs,mons,yyyy,mm,ind1,tsh/])

  time = in1->time
  yyyymm = cd_calendar(time,-1)/100
  iYYYY = ind(yyyymm.ge.yStrF .and. yyyymm.le.yLstF)

  tsi = in1->tas(iYYYY,:,:)
  tsi = tsi -273.15
  tsi@units = "Celsius"

  nyrs = dimsizes(iYYYY)/12
  mons = cd_calendar(time(iYYYY),-1)
  yyyy = mons/100
  mm = mons-yyyy*100

  ind1 = new((/12,nyrs/),integer)
  do i=0,11
  ind1(i,:) = ind(mm.eq.i+1)
  end do

  tsim = new((/12,nyrs,nlat,nlon/),float)
  do i=0,11
  tsim(i,:,:,:) = tsi(ind1(i,:),:,:)
  end do
  tsim!0 = "month"
  tsim!1 = "year"
  tsim!2 = "lat"
  tsim!3 = "lon"
  tsim&lat = lat
  tsim&lon = lon

; set up output file to display model and experiment in file name

  out_template = "/Volumes/LaCie/CMIP5/outtest/PATTERN_tas_MONS_MODEL_EXPERIMENT.nc"
  outs = str_sub_str (out_template, "MODEL", model)
  outs = str_sub_str (outs, "EXPERIMENT", expt)

; get Tgav monthly timeseries
  Tgav = new((/12,nyrs/),float)
  do i=0,11
  Tgav(i,:) = wgt_areaave(tsim(i,:,:,:),clat,1.0,0)
  end do

; get historical climatology for base

  climo = new((/12,nlat,nlon/),float)
  do i=0,11
  climo(i,:,:) = dim_avg_n_Wrap(tshm(i,:,:,:),0)
  end do
  climo!0 = "month"
  climo!1 = "lat"
  climo!2 = "lon"
  climo&lat = lat
  climo&lon = lon
  climo@year_start = yStrH
  climo@year_end = yLstH
  climo@months = "start month = Jan; end month = Dec"

; reorder Tlocal and use Tgav to predict Tlocal in LSR method

  data = tsim(month|:,lat|:,lon|:,year|:)

  coef = new((/12,nlat,nlon/),float)
  do i=0,11
  coef(i,:,:) = regCoef(Tgav(i,:),data(i,:,:,:))
  end do
  coef!0 = "month"
  coef!1 = "lat"
  coef!2 = "lon"
  coef&lat = lat
  coef&lon = lon
  copy_VarCoords(data,coef)
  coef@units = "Degree C per TGAV in Degree C"
  coef@title = "LSR coefficient"
  coef@original_name = name 
  coef@realm = realm 
  coef@source = model
  coef@time_average = time_increment
  coef@months = "start month = Jan; end month = Dec"

;  calculate rsquared

  r2x = new((/12,nlat,nlon/),float)
  do i=0,11
  r2x(i,:,:) = (escorc(Tgav(i,:),data(i,:,:,:)))^2
  end do
  r2 = new((/12,nlat,nlon/),float)
  do i=0,11
  r2(i,:,:) = 1-(((1-r2x(i,:,:))*93)/92)
  end do
  r2!0 = "month"
  r2!1 = "lat"
  r2!2 = "lon"
  r2&lat = lat
  r2&lon = lon
  copy_VarCoords(data,r2)
  r2@units = "N/A"
  r2@title = "Adjusted Pearson correlation coefficient squared"
  r2@source = model
  r2@months = "start month = Jan; end month = Dec"

; calculate 95% confidence interval from LSR error term
; tvalue for 95-2 df at the 95% level = 1.985 (2-tail)
; error term is rstd in regCoef function

  coef1 = regCoef(Tgav(0,:),data(0,:,:,:))
  coef2 = regCoef(Tgav(1,:),data(1,:,:,:))
  coef3 = regCoef(Tgav(2,:),data(2,:,:,:))
  coef4 = regCoef(Tgav(3,:),data(3,:,:,:))
  coef5 = regCoef(Tgav(4,:),data(4,:,:,:))
  coef6 = regCoef(Tgav(5,:),data(5,:,:,:))
  coef7 = regCoef(Tgav(6,:),data(6,:,:,:))
  coef8 = regCoef(Tgav(7,:),data(7,:,:,:))
  coef9 = regCoef(Tgav(8,:),data(8,:,:,:))
  coef10 = regCoef(Tgav(9,:),data(9,:,:,:))
  coef11 = regCoef(Tgav(10,:),data(10,:,:,:))
  coef12 = regCoef(Tgav(11,:),data(11,:,:,:))

  rstdx = new((/12,nlat,nlon/),float)
  rstdx(0,:,:) = (/onedtond(coef1@rstd,(/nlat,nlon/))/)
  rstdx(1,:,:) = (/onedtond(coef2@rstd,(/nlat,nlon/))/)
  rstdx(2,:,:) = (/onedtond(coef3@rstd,(/nlat,nlon/))/)
  rstdx(3,:,:) = (/onedtond(coef4@rstd,(/nlat,nlon/))/)
  rstdx(4,:,:) = (/onedtond(coef5@rstd,(/nlat,nlon/))/)
  rstdx(5,:,:) = (/onedtond(coef6@rstd,(/nlat,nlon/))/)
  rstdx(6,:,:) = (/onedtond(coef7@rstd,(/nlat,nlon/))/)
  rstdx(7,:,:) = (/onedtond(coef8@rstd,(/nlat,nlon/))/)
  rstdx(8,:,:) = (/onedtond(coef9@rstd,(/nlat,nlon/))/)
  rstdx(9,:,:) = (/onedtond(coef10@rstd,(/nlat,nlon/))/)
  rstdx(10,:,:) = (/onedtond(coef11@rstd,(/nlat,nlon/))/)
  rstdx(11,:,:) = (/onedtond(coef12@rstd,(/nlat,nlon/))/)
  rstdx!0 = "month"
  rstdx!1 = "lat"
  rstdx!2 = "lon"
  rstdx&lat = lat
  rstdx&lon = lon
  rstdx@title = "Standardized error term from LSR equation"
  rstdx@source = model
  rstdx@units = "N/A"
  rstdx@months = "start month = Jan; end month = Dec"

  delete([/coef1,coef2,coef3,coef4,coef5,coef6,coef7,coef8,coef9,coef10,coef11,coef12/])

  ci95 = new((/12,nlat,nlon/),float)
  ci95 = rstdx
  do i=0,11
  ci95(i,:,:) = rstdx(i,:,:) *1.985
  end do
  ci95!0 = "month"
  ci95!1 = "lat"
  ci95!2 = "lon"
  ci95&lat = lat
  ci95&lon = lon
  copy_VarCoords(data,ci95)
  ci95@title = "95th %ile confidence interval"
  ci95@units = "Degree C per TGAV in Degree C"
  ci95@Tvalue = "95th significance level t-value(2-tail) for df = 95-2 = 1.985"
  ci95@method = "multiplied the LSR error term by Tvalue"
  ci95@long_name = "rstdx from LSR * 95th significance level t-value for df = 95-2"
  ci95@source = model
  ci95@time_average = time_increment
  ci95@months = "start month = Jan; end month = Dec"

  delete(coef@nptxy)
  delete(coef@rstd)
  delete(coef@yintercept)
  delete(coef@tval)

; define metadata of output

  system("/bin/rm -f " + outs)    ; remove file if exists
  out = addfile(outs,"c")

  out@title = "LSR pattern scaling"
  out@creation_date = systemfunc("date")
  out@methods = "Tlocal regressed onto TGAV via least squared regression"
  out@TGAV = "Globally averaged & weighted by latitude monthly TAS"
  out@time_increment = time_increment
  out@source_model = model
  out@original_variable = name
  out@realm = realm
  out@NCL_function1 = "wgt_areaave (weighted area average)"
  out@NCL_function2 = "regCoef (LSR regression)"
  out@Lat_weights = "sqrt(cos(rad*lat))"
  out@editor = editor
  out@editor_locale = editor_locale
  out@forcing = expt
  out@months = "start month = Jan; end month = Dec"

  global_attnames = getvaratts(data)

  do i=0,dimsizes(global_attnames)-1
      out@$global_attnames(i)$ = data@$global_attnames(i)$
  end do

  delete(out@NCL)
  delete(out@long_name)
  delete(out@standard_name)
  delete(out@original_name)
  delete(out@coordinates)

  out->pattern = coef
  out->CI95 = ci95
  out->r2 = r2
  out->error = rstdx
  out->climatology = climo

  delete([/name,out_template,outs,out,nitems,name2,model,expt,mons,yyyy,mm,ind1,nyrs,time,yyyymm,iYYYY,tshm,tsim,tsi,Tgav,climo,data,global_attnames,coef,lat,lon,clat,nlat,nlon,rstdx,ci95,r2x,r2/])

  end do


end
