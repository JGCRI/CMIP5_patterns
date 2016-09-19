Repository for SFA Climate Task.

Steps to creation of library for temperature:

You must change these lines:

	Change line 13 to name of editor of script
	Change line 14 to locale of editor
	Change line 24-25 to correct directory for future input files
	Change line 26 to correct directory for historical input files
	Change line 95 (folders only, not file) to correct directory for output files

You may want to change these lines:

	Change line 12 if different climate variable other than precipitation is wanted 
	Change line 15 if different temporal aggregation of pattern is wanted 
	Change lines 19-22 if different time spans for climatology and pattern are wanted 
	Change lines 28-30 if not CMIP files to reflect files in input directories 
	Change lines 60-61 & 70-71 if mm/month is not prefered. Do not comment out these lines. Original units are in mm -s, which are too small for the regression equation. 
	Change lines 103-105 if seasonal is wanted. Line 87 shows how to do this 
	Change line 127 if different different unit is used. Change "mm/month" only. 
	Change line 209 if seasonal is wanted.

To run the script:

1.  Make sure NCL is installed on local/remote machine
2.  Make sure output file is writable
3.  Type "ncl" and then the *.ncl script (ex. "ncl test.ncl"). The ".ncl" means this is the executeable script.

