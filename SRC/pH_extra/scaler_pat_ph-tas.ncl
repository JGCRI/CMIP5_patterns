;**********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;**********************************
begin

  columns = asciiread("/pic/projects/GCAM/CMIP5-CLynch/HECTOR/1900-2300_degC.txt",(/400,4/),"float")

  rcp26 = columns(106:200,0)
  rcp45 = columns(106:200,1)
  rcp60 = columns(106:200,2)
  rcp85 = columns(106:200,3)

; Change based on scenario used to scale

  fscen = rcp45
  SCEN = "rcp45"

; Calc linear trend over 21C in Hector TGAV
; Scaler at 2050s = Hra1 
; Scaler at 2080s = Hra2 

  Hra1 = avg(rcp45(35:64))
  Hra2 = avg(rcp45(65:94))

  YEAR1 = "2050s"
  YEAR2 = "2080s"

;************  GET THAT DATA!! *********************

  diri = "/pic/projects/GCAM/CMIP5-CLynch/PH_extra/"

  fili = systemfunc("ls " + diri + "LSR_ph-tas_*")

  do k = 0,dimsizes(fili)-1
  in2 = fili(k)
  in1 = addfile(fili(k),"r")

; isolate the model name

  nitems = str_fields_count (in2, "/")
  name2  = str_get_field (in2, nitems, "/")
  model = str_get_field (name2, 4, "_")

  pattern = in1->pattern
  ci95 = in1->CI95
  climo = in1->climatology

  lat = in1->lat
  lon = in1->lon

;********** SCALE THAT PATTERN!! ************

  PS1 = pattern
  PS1 = pattern * Hra1
  PS1!0 = "lat"
  PS1!1 = "lon"
  PS1&lat = lat
  PS1&lon = lon
  PS1@title = "Scaled pattern at time_X"
  PS1@units = "mol H kg-1 chage at 2050s"
  PS1@source = model
  PS1@TIME_x = YEAR1
  PS1@Hector_scen = SCEN
  PS1@pattern = "ph-tas pattern"
  PS1@scaler = Hra1

; 95th confidence bounds
; UB = upper bound
; LB = lower bound

  UBPS1 = pattern
  UBPS1 = (pattern + ci95) * Hra1 
  UBPS1!0 = "lat"
  UBPS1!1 = "lon"
  UBPS1&lat = lat
  UBPS1&lon = lon
  UBPS1@title = "Scaled upper bound of 95th confidence interval of pattern at time_X"
  UBPS1@units = "mol H kg-1 chage at 2050s"
  UBPS1@source = model
  UBPS1@time_X = YEAR1
  UBPS1@Hector_scen = SCEN
  UBPS1@pattern = "95th confidence interval of ph-tas pattern"
  UBPS1@scaler = Hra1

  LBPS1 = pattern
  LBPS1 = (pattern - ci95) * Hra1 
  LBPS1!0 = "lat"
  LBPS1!1 = "lon"
  LBPS1&lat = lat
  LBPS1&lon = lon
  LBPS1@title = "Scaled lower bound of 95th confidence interval of pattern at time_X"
  LBPS1@units = "mol H kg-1 chage at 2050s"
  LBPS1@source = model
  LBPS1@time_X = YEAR1
  LBPS1@Hector_scen = SCEN
  LBPS1@pattern = "95th confidence interval of ph-tas pattern"
  LBPS1@scaler = Hra1
  
  PS2 = pattern
  PS2 = pattern * Hra2
  PS2!0 = "lat"
  PS2!1 = "lon"
  PS2&lat = lat
  PS2&lon = lon
  PS2@title = "Scaled pattern at time_X"
  PS2@units = "mol H kg-1 change at 2080s"
  PS2@source = model
  PS2@time_X = YEAR2
  PS2@Hector_scen = SCEN
  PS2@pattern = "ph-tas pattern"
  PS2@scaler = Hra2

  UBPS2 = pattern
  UBPS2 = (pattern + ci95) * Hra2 
  UBPS2!0 = "lat"
  UBPS2!1 = "lon"
  UBPS2&lat = lat
  UBPS2&lon = lon
  UBPS2@title = "Scaled upper bound of 95th confidence interval of pattern at time_X"
  UBPS2@units = "mol H kg-1 chage at 2080s"
  UBPS2@source = model
  UBPS2@time_X = YEAR2
  UBPS2@Hector_scen = SCEN
  UBPS2@pattern = "95th confidence interval of ph-tas pattern"
  UBPS2@scaler = Hra2

  LBPS2 = pattern
  LBPS2 = (pattern - ci95) * Hra2
  LBPS2!0 = "lat"
  LBPS2!1 = "lon"
  LBPS2&lat = lat
  LBPS2&lon = lon
  LBPS2@title = "Scaled lower bound of 95th confidence interval of pattern at time_X"
  LBPS2@units = "mol H kg-1 chage at 2080s"
  LBPS2@source = model
  LBPS2@time_X = YEAR2
  LBPS2@Hector_scen = SCEN
  LBPS2@pattern = "95th confidence interval of ph-tas pattern"
  LBPS2@scaler = Hra2

; if absolute value at time X is wanted then
; add climo to pattern

  APS1 = climo
  APS1 = climo + PS1
  APS1!0 = "lat"
  APS1!1 = "lon"
  APS1&lat = lat
  APS1&lon = lon
  APS1@title = "PH at time_X"
  APS1@units = "mol H kg-1 at 2050s"
  APS1@source = model
  APS1@time_X = YEAR1
  APS1@Hector_scen = SCEN
  APS1@pattern = "ph-tas pattern"
  APS1@scaler = Hra1

  AUBPS1 = climo
  AUBPS1 = climo + UBPS1
  AUBPS1!0 = "lat"
  AUBPS1!1 = "lon"
  AUBPS1&lat = lat
  AUBPS1&lon = lon
  AUBPS1@title = "Upper bound of 95th confidence interval of PH at time_X"
  AUBPS1@units = "mol H kg-1 at 2050s"
  AUBPS1@source = model
  AUBPS1@time_X = YEAR1
  AUBPS1@Hector_scen = SCEN
  AUBPS1@pattern = "95th confidence interval of ph-tas pattern"
  AUBPS1@scaler = Hra1

  ALBPS1 = climo
  ALBPS1 = climo + LBPS1
  ALBPS1!0 = "lat"
  ALBPS1!1 = "lon"
  ALBPS1&lat = lat
  ALBPS1&lon = lon
  ALBPS1@title = "Lower bound of 95th confidence interval of PH at time_X"
  ALBPS1@units = "mol H kg-1 at 2050s"
  ALBPS1@source = model
  ALBPS1@time_X = YEAR1
  ALBPS1@Hector_scen = SCEN
  ALBPS1@pattern = "95th confidence interval of ph-tas pattern"
  ALBPS1@scaler = Hra1

  APS2 = climo
  APS2 = climo + PS2
  APS2!0 = "lat"
  APS2!1 = "lon"
  APS2&lat = lat
  APS2&lon = lon
  APS2@title = "PH at time_X"
  APS2@units = "mol H kg-1 at 2080s"
  APS2@source = model
  APS2@time_X = YEAR2
  APS2@Hector_scen = SCEN
  APS2@pattern = "ph-tas pattern"
  APS2@scaler = Hra2

  AUBPS2 = climo
  AUBPS2 = climo + UBPS2
  AUBPS2!0 = "lat"
  AUBPS2!1 = "lon"
  AUBPS2&lat = lat
  AUBPS2&lon = lon
  AUBPS2@title = "Upper bound of 95th confidence interval of PH at time_X"
  AUBPS2@units = "mol H kg-1 at 2080s"
  AUBPS2@source = model
  AUBPS2@time_X = YEAR2
  AUBPS2@Hector_scen = SCEN
  AUBPS2@pattern = "95th confidence interval of ph-tas pattern"
  AUBPS2@scaler = Hra2

  ALBPS2 = climo
  ALBPS2 = climo + LBPS2
  ALBPS2!0 = "lat"
  ALBPS2!1 = "lon"
  ALBPS2&lat = lat
  ALBPS2&lon = lon
  ALBPS2@title = "Lower bound of 95th confidence interval of PH at time_X"
  ALBPS2@units = "mol H kg-1 at 2080s"
  ALBPS2@source = model
  ALBPS2@time_X = YEAR2
  ALBPS2@Hector_scen = SCEN
  ALBPS2@pattern = "95th confidence interval of ph-tas pattern"
  ALBPS2@scaler = Hra2

;*********  OUTPUT NetCDF ********
; set up output file to display model and experiment in file name

  out_template = "/pic/projects/GCAM/CMIP5-CLynch/HECTOR/ph-tas_scaled_ANN_MODEL_SCEN.nc"
  outs = str_sub_str (out_template, "MODEL", model)
  outs = str_sub_str (outs, "SCEN",SCEN)

  system("/bin/rm -f " + outs)    ; remove file if exists
  out = addfile(outs,"c")

  out@title = "Hector Scaled ph-tas Pattern"
  out@creation_date = systemfunc("date")
  out@source_model = model

  out->PS1 = PS1
  out->UBPS1 = UBPS1
  out->LBPS1 = LBPS1
  out->PS2 = PS2
  out->UBPS2 = UBPS2
  out->LBPS2 = LBPS2
  out->APS1 = APS1
  out->AUBPS1 = AUBPS1
  out->ALBPS1 = ALBPS1
  out->APS2 = APS2
  out->AUBPS2 = AUBPS2
  out->ALBPS2 = ALBPS2

delete([/lat,lon,model,pattern,climo,ci95,PS1,UBPS1,LBPS1,PS2,UBPS2,LBPS2,APS1,APS2,AUBPS1,ALBPS1,AUBPS2,ALBPS2/])

end do

end

  

