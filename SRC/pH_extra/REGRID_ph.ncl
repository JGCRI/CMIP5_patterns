;**************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
;**************************************
begin
;****************************************

  diri = "/pic/projects/GCAM/CMIP5-CHartin/CMIP5_RCP85/ph/"
  diri2 = "/pic/projects/GCAM/CMIP5-CHartin/CMIP5_RCP85/tas/"
  diri3 = "/pic/projects/GCAM/CMIP5-CLynch/PH_extra/"
  diri4 = "/pic/projects/GCAM/CMIP5-CLynch/TAS_extra/"
  diri5 = "/pic/projects/GCAM/CMIP5-CHartin/CMIP5_HISTORICAL/ph/"


  ph1 = addfile(diri+"ph_Omon_CESM1-BGC_rcp85_r1i1p1_200601-210012.nc","r")
  ph3 = addfile(diri+"ph_Omon_CMCC-CESM_rcp85_r1i1p1_200601-210012.nc","r")
  ph9 = addfile(diri+"ph_Omon_IPSL-CM5A-MR_rcp85_r1i1p1_200601-210012.nc","r")
  ph10 = addfile(diri+"ph_Omon_MPI-ESM-LR_rcp85_r1i1p1_200601-210012.nc","r")
  ph11 = addfile(diri+"ph_Omon_MPI-ESM-MR_rcp85_r1i1p1_200601-210012.nc","r")
  ph12 = addfile(diri3+"ph_Omon_NorESM1-ME_rcp85_r1i1p1_200601-210012.nc","r")

  fp1 = addfile(diri2+"tas_Amon_CESM1-BGC_rcp85_r1i1p1_200601-210012.nc","r")
  fp3 = addfile(diri4+"tas_Amon_CMCC-CESM_rcp85_r1i1p1_200001-210012.nc","r")
  fp9 = addfile(diri2+"tas_Amon_IPSL-CM5A-MR_rcp85_r1i1p1_200601-210012.nc","r")
  fp10 = addfile(diri2+"tas_Amon_MPI-ESM-LR_rcp85_r1i1p1_200601-210012.nc","r")
  fp11 = addfile(diri2+"tas_Amon_MPI-ESM-MR_rcp85_r1i1p1_200601-210012.nc","r")
  fp12 = addfile(diri4+"tas_Amon_NorESM1-ME_rcp85_r1i1p1_200601-210012.nc","r")

  hh1 = addfile(diri5+"ph_Omon_CESM1-BGC_historical_r1i1p1_185001-200512.nc","r")
  hh3 = addfile(diri5+"ph_Omon_CMCC-CESM_historical_r1i1p1_185001-200512.nc","r")
  hh9 = addfile(diri5+"ph_Omon_IPSL-CM5A-MR_historical_r1i1p1_195001-200512.nc","r")
  hh10 = addfile(diri5+"ph_Omon_MPI-ESM-LR_historical_r1i1p1_185001-200512.nc","r")
  hh11 = addfile(diri3+"ph_Omon_MPI-ESM-MR_historical_r1i1p1_190001-200512.nc","r")
  hh12 = addfile(diri5+"ph_Omon_NorESM1-ME_historical_r1i1p1_185001-200512.nc","r")

; read in all data files
  pha1 = ph1->ph
  pha3 = ph3->ph
  pha9 = ph9->ph
  pha10 = ph10->ph
  pha11 = ph11->ph
  pha12 = ph12->ph
  phh1 = hh1->ph
  phh3 = hh3->ph
  phh9 = hh9->ph
  phh10 = hh10->ph
  phh11 = hh11->ph
  phh12 = hh12->ph

  tas1 = fp1->tas
  tas3 = fp3->tas
  tas9 = fp9->tas
  tas10 = fp10->tas
  tas11 = fp11->tas
  tas12 = fp12->tas

  pha1@lat2d = ph1->lat
  pha1@lon2d = ph1->lon
  pha3@lat2d = ph3->lat
  pha3@lon2d = ph3->lon
  pha9@lat2d = ph9->lat
  pha9@lon2d = ph9->lon
  pha10@lat2d = ph10->lat
  pha10@lon2d = ph10->lon
  pha11@lat2d = ph11->lat
  pha11@lon2d = ph11->lon
  pha12@lat2d = ph12->lat
  pha12@lon2d = ph12->lon
  phh1@lat2d = hh1->lat
  phh1@lon2d = hh1->lon
  phh3@lat2d = hh3->lat
  phh3@lon2d = hh3->lon
  phh9@lat2d = hh9->lat
  phh9@lon2d = hh9->lon
  phh10@lat2d = hh10->lat
  phh10@lon2d = hh10->lon
  phh11@lat2d = hh11->lat
  phh11@lon2d = hh11->lon
  phh12@lat2d = hh12->lat
  phh12@lon2d = hh12->lon

  lat1 = fp1->lat
  lon1 = fp1->lon
  lat3 = fp3->lat
  lon3 = fp3->lon
  lat9 = fp9->lat
  lon9 = fp9->lon
  lat10 = fp10->lat
  lon10 = fp10->lon
  lat11 = fp11->lat
  lon11 = fp11->lon
  lat12 = fp12->lat
  lon12 = fp12->lon

;  system("/bin/rm -f  destination_grid_file.nc")
;  system("/bin/rm -f weights_file.nc")
;  system("/bin/rm -f source_grid_file.nc")
;  system("/bin/rm -f PET0.RegridWeightGen.Log")

  Opt1                = True
  Opt1@Overwrite      = True
  Opt1@ForceOverwrite   = True
  Opt1@DstGridLat       = lat1
  Opt1@DstGridLon       = lon1

  rgts1 = ESMF_regrid(pha1,Opt1)
  rgts1!0 = "time"
  rgts1!1 = "lat"
  rgts1!2 = "lon"
  rgts1&lat = lat1
  rgts1&lon = lon1
  system("/bin/rm -f  destination_grid_file.nc")
  system("/bin/rm -f weights_file.nc")
  system("/bin/rm -f source_grid_file.nc")
  system("/bin/rm -f PET0.RegridWeightGen.Log")

  Opt3 = True
  Opt3@Overwrite      = True
  Opt3@ForceOverwrite   = True
  Opt3@DstGridLat       = lat3
  Opt3@DstGridLon       = lon3

  rgts3 = ESMF_regrid(pha3,Opt3)
  rgts3!0 = "time"
  rgts3!1 = "lat"
  rgts3!2 = "lon"
  rgts3&lat = lat3
  rgts3&lon = lon3
  system("/bin/rm -f  destination_grid_file.nc")
  system("/bin/rm -f weights_file.nc")
  system("/bin/rm -f source_grid_file.nc")
  system("/bin/rm -f PET0.RegridWeightGen.Log")

  Opt9 = True
  Opt9@Overwrite      = True
  Opt9@ForceOverwrite   = True
  Opt9@DstGridType = "rectilinear"
  Opt9@DstGridLat       = lat9
  Opt9@DstGridLon       = lon9

  rgts9 = ESMF_regrid(pha9,Opt9)
  rgts9!0 = "time"
  rgts9!1 = "lat"
  rgts9!2 = "lon"
  rgts9&lat = lat9
  rgts9&lon = lon9
  system("/bin/rm -f  destination_grid_file.nc")
  system("/bin/rm -f weights_file.nc")
  system("/bin/rm -f source_grid_file.nc")
  system("/bin/rm -f PET0.RegridWeightGen.Log")

  Opt10 = True
  Opt10@Overwrite      = True
  Opt10@ForceOverwrite   = True
  Opt10@DstGridLat       = lat10
  Opt10@DstGridLon       = lon10

  rgts10 = ESMF_regrid(pha10,Opt10)
  rgts10!0 = "time"
  rgts10!1 = "lat"
  rgts10!2 = "lon"
  rgts10&lat = lat10
  rgts10&lon = lon10
  system("/bin/rm -f  destination_grid_file.nc")
  system("/bin/rm -f weights_file.nc")
  system("/bin/rm -f source_grid_file.nc")
  system("/bin/rm -f PET0.RegridWeightGen.Log")

  Opt11 = True
  Opt11@Overwrite      = True
  Opt11@ForceOverwrite   = True
  Opt11@DstGridLat       = lat11
  Opt11@DstGridLon       = lon11
  rgts11 = ESMF_regrid(pha11,Opt11)
  rgts11!0 = "time"
  rgts11!1 = "lat"
  rgts11!2 = "lon"
  rgts11&lat = lat11
  rgts11&lon = lon11
  system("/bin/rm -f  destination_grid_file.nc")
  system("/bin/rm -f weights_file.nc")
  system("/bin/rm -f source_grid_file.nc")
  system("/bin/rm -f PET0.RegridWeightGen.Log")

  Opt12 = True
  Opt12@Overwrite      = True
  Opt12@ForceOverwrite   = True
  Opt12@DstGridLat       = lat12
  Opt12@DstGridLon       = lon12

  rgts12 = ESMF_regrid(pha12,Opt12)
  rgts12!0 = "time"
  rgts12!1 = "lat"
  rgts12!2 = "lon"
  rgts12&lat = lat12
  rgts12&lon = lon12
  system("/bin/rm -f  destination_grid_file.nc")
  system("/bin/rm -f weights_file.nc")
  system("/bin/rm -f source_grid_file.nc")
  system("/bin/rm -f PET0.RegridWeightGen.Log")

;****  historical ****
  delete([/Opt1,Opt3,Opt9,Opt10,Opt11,Opt12/])

  system("/bin/rm -f  destination_grid_file.nc")
  system("/bin/rm -f weights_file.nc")
  system("/bin/rm -f source_grid_file.nc")
  system("/bin/rm -f PET0.RegridWeightGen.Log")

  Opt1                = True

  Opt1@Overwrite      = True
  Opt1@ForceOverwrite   = True
  Opt1@DstGridLat       = lat1
  Opt1@DstGridLon       = lon1

  rgth1 = ESMF_regrid(phh1,Opt1)
  rgth1!0 = "time"
  rgth1!1 = "lat"
  rgth1!2 = "lon"
  rgth1&lat = lat1
  rgth1&lon = lon1
  system("/bin/rm -f  destination_grid_file.nc")
  system("/bin/rm -f weights_file.nc")
  system("/bin/rm -f source_grid_file.nc")
  system("/bin/rm -f PET0.RegridWeightGen.Log")

  Opt3 = True
  Opt3@Overwrite      = True
  Opt3@ForceOverwrite   = True
  Opt3@DstGridLat       = lat3
  Opt3@DstGridLon       = lon3

  rgth3 = ESMF_regrid(phh3,Opt3)
  rgth3!0 = "time"
  rgth3!1 = "lat"
  rgth3!2 = "lon"
  rgth3&lat = lat3
  rgth3&lon = lon3
  system("/bin/rm -f  destination_grid_file.nc")
  system("/bin/rm -f weights_file.nc")
  system("/bin/rm -f source_grid_file.nc")
  system("/bin/rm -f PET0.RegridWeightGen.Log")

  Opt9 = True
  Opt9@Overwrite      = True
  Opt9@ForceOverwrite   = True
  Opt9@DstGridType = "rectilinear"
  Opt9@DstGridLat       = lat9
  Opt9@DstGridLon       = lon9

  rgth9 = ESMF_regrid(phh9,Opt9)
  rgth9!0 = "time"
  rgth9!1 = "lat"
  rgth9!2 = "lon"
  rgth9&lat = lat9
  rgth9&lon = lon9
  system("/bin/rm -f  destination_grid_file.nc")
  system("/bin/rm -f weights_file.nc")
  system("/bin/rm -f source_grid_file.nc")
  system("/bin/rm -f PET0.RegridWeightGen.Log")

  Opt10 = True
  Opt10@Overwrite      = True
  Opt10@ForceOverwrite   = True
  Opt10@DstGridLat       = lat10
  Opt10@DstGridLon       = lon10

  rgth10 = ESMF_regrid(phh10,Opt10)
  rgth10!0 = "time"
  rgth10!1 = "lat"
  rgth10!2 = "lon"
  rgth10&lat = lat10
  rgth10&lon = lon10
  system("/bin/rm -f  destination_grid_file.nc")
  system("/bin/rm -f weights_file.nc")
  system("/bin/rm -f source_grid_file.nc")
  system("/bin/rm -f PET0.RegridWeightGen.Log")

  Opt11 = True
  Opt11@Overwrite      = True
  Opt11@ForceOverwrite   = True
  Opt11@DstGridLat       = lat11
  Opt11@DstGridLon       = lon11

  rgth11 = ESMF_regrid(phh11,Opt11)
  rgth11!0 = "time"
  rgth11!1 = "lat"
  rgth11!2 = "lon"
  rgth11&lat = lat11
  rgth11&lon = lon11
  system("/bin/rm -f  destination_grid_file.nc")
  system("/bin/rm -f weights_file.nc")
  system("/bin/rm -f source_grid_file.nc")
  system("/bin/rm -f PET0.RegridWeightGen.Log")

  Opt12 = True
  Opt12@Overwrite      = True
  Opt12@ForceOverwrite   = True
  Opt12@DstGridLat       = lat12
  Opt12@DstGridLon       = lon12

  rgth12 = ESMF_regrid(phh12,Opt12)
  rgth12!0 = "time"
  rgth12!1 = "lat"
  rgth12!2 = "lon"
  rgth12&lat = lat12
  rgth12&lon = lon12
  system("/bin/rm -f  destination_grid_file.nc")
  system("/bin/rm -f weights_file.nc")
  system("/bin/rm -f source_grid_file.nc")
  system("/bin/rm -f PET0.RegridWeightGen.Log")

;********  output ********
  diro = "/pic/projects/GCAM/CMIP5-CLynch/PH_extra/"
  filo = (/"rgph_Omon_CESM1-BGC_historical_r1i1p1_185001-200512.nc"/)
  system("/bin/rm -f " + filo)
  out = addfile(diro+filo,"c")
  global_attnames = getvaratts(rgth1)
  do i=0,dimsizes(global_attnames)-1
      out@$global_attnames(i)$ = rgts1@$global_attnames(i)$
  end do
  out@title = "PH-TAS regrid"
  out->ph = rgth1
  delete(global_attnames)

  filo = (/"rgph_Omon_CMCC-CESM_historical_r1i1p1_185001-200512.nc"/)
  system("/bin/rm -f " + filo)
  out = addfile(diro+filo,"c")
  global_attnames = getvaratts(rgth3)
  do i=0,dimsizes(global_attnames)-1
      out@$global_attnames(i)$ = rgts3@$global_attnames(i)$
  end do
  out@title = "PH-TAS regrid"
  out->ph = rgth3
  delete(global_attnames)

  filo = (/"rgph_Omon_IPSL-CM5A-MR_historical_r1i1p1_195001-200512.nc"/)
  system("/bin/rm -f " + filo)
  out = addfile(diro+filo,"c")
  global_attnames = getvaratts(rgth9)
  do i=0,dimsizes(global_attnames)-1
      out@$global_attnames(i)$ = rgts9@$global_attnames(i)$
  end do
  out@title = "PH-TAS regrid"
  out->ph = rgth9
  delete(global_attnames)

  filo = (/"rgph_Omon_MPI-ESM-LR_historical_r1i1p1_185001-200512.nc"/)
  system("/bin/rm -f " + filo)
  out = addfile(diro+filo,"c")
  global_attnames = getvaratts(rgth10)
  do i=0,dimsizes(global_attnames)-1
      out@$global_attnames(i)$ = rgts10@$global_attnames(i)$
  end do
  out@title = "PH-TAS regrid"
  out->ph = rgth10
  delete(global_attnames)

  filo = (/"rgph_Omon_MPI-ESM-MR_historical_r1i1p1_190001-200512.nc"/)
  system("/bin/rm -f " + filo)
  out = addfile(diro+filo,"c")
  global_attnames = getvaratts(rgth11)
  do i=0,dimsizes(global_attnames)-1
      out@$global_attnames(i)$ = rgts11@$global_attnames(i)$
  end do
  out@title = "PH-TAS regrid"
  out->ph = rgth11
  delete(global_attnames)

  filo = (/"rgph_Omon_NorESM1-ME_historical_r1i1p1_185001-200512.nc"/)
  system("/bin/rm -f " + filo)
  out = addfile(diro+filo,"c")
  global_attnames = getvaratts(rgth12)
  do i=0,dimsizes(global_attnames)-1
      out@$global_attnames(i)$ = rgts12@$global_attnames(i)$
  end do
  out@title = "PH-TAS regrid"
  out->ph = rgth12
  delete(global_attnames)

  filo = (/"rgph_Omon_CESM1-BGC_rcp85_r1i1p1_200601-210012.nc"/)
  system("/bin/rm -f " + filo)
  out = addfile(diro+filo,"c")
  global_attnames = getvaratts(rgts1)
  do i=0,dimsizes(global_attnames)-1
      out@$global_attnames(i)$ = rgts1@$global_attnames(i)$
  end do
  out@title = "PH-TAS regrid"
  out->ph = rgts1
  delete(global_attnames)

  filo = (/"rgph_Omon_CMCC-CESM_rcp85_r1i1p1_200601-210012.nc"/)
  system("/bin/rm -f " + filo)
  out = addfile(diro+filo,"c")
  global_attnames = getvaratts(rgts3)
  do i=0,dimsizes(global_attnames)-1
      out@$global_attnames(i)$ = rgts3@$global_attnames(i)$
  end do
  out@title = "PH-TAS regrid"
  out->ph = rgts3
  delete(global_attnames)

  filo = (/"rgph_Omon_IPSL-CM5A-MR_rcp85_r1i1p1_200601-210012.nc"/)
  system("/bin/rm -f " + filo)
  out = addfile(diro+filo,"c")
  global_attnames = getvaratts(rgts9)
  do i=0,dimsizes(global_attnames)-1
      out@$global_attnames(i)$ = rgts9@$global_attnames(i)$
  end do
  out@title = "PH-TAS regrid"
  out->ph = rgts9
  delete(global_attnames)

  filo = (/"rgph_Omon_MPI-ESM-LR_rcp85_r1i1p1_200601-210012.nc"/)
  system("/bin/rm -f " + filo)
  out = addfile(diro+filo,"c")
  global_attnames = getvaratts(rgts10)
  do i=0,dimsizes(global_attnames)-1
      out@$global_attnames(i)$ = rgts10@$global_attnames(i)$
  end do
  out@title = "PH-TAS regrid"
  out->ph = rgts10
  delete(global_attnames)

  filo = (/"rgph_Omon_MPI-ESM-MR_rcp85_r1i1p1_200601-210012.nc"/)
  system("/bin/rm -f " + filo)
  out = addfile(diro+filo,"c")
  global_attnames = getvaratts(rgts11)
  do i=0,dimsizes(global_attnames)-1
      out@$global_attnames(i)$ = rgts11@$global_attnames(i)$
  end do
  out@title = "PH-TAS regrid"
  out->ph = rgts11
  delete(global_attnames)

  filo = (/"rgph_Omon_NorESM1-ME_rcp85_r1i1p1_200601-210012.nc"/)
  system("/bin/rm -f " + filo)
  out = addfile(diro+filo,"c")
  global_attnames = getvaratts(rgts12)
  do i=0,dimsizes(global_attnames)-1
      out@$global_attnames(i)$ = rgts12@$global_attnames(i)$
  end do
  out@title = "PH-TAS regrid"
  out->ph = rgts12
  delete(global_attnames)

end
