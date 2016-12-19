Ocean pH scales well with global mean temperature.  It also scales well with global mean pH.  The listed .ncl files are the steps to pattern scaling using ocean pH.

Before creating a pattern, some monthly ocean pH netcdf files will need to be regridded from a ocean curvilinear grid to a rectilinear grid.  Of all monthly ocean pH models (of which there are ~12), these models will need to be regridded:

CESM1-BGC

CMCC-CESM

IPSL-CM5A-MR

MPI-ESM-LR

MPI-ESM-MR

NorESM1-ME


Once regridded, patterns can be created.

Then, patterns can be scaled by pH or TGAV anomalies from Hector.


Order of operation:

1. REGRID_ph.ncl

2.  pat_ph-ph.ncl or pat_ph-tas.ncl

3.  scaler_pat_ph-ph.ncl or scaler_pat_ph-tas.ncl

 
