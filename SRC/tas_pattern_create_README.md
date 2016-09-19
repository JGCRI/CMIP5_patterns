Repository for SFA Climate Task.

Steps to creation of library for temperature:

You must change these lines:

    Change line 13 to name of editor of script
    Change line 14 to locale of editor
    Change line 24 to correct directory for future input files
    Change line 25 to correct directory for historical input files
    Change line 82 (folders only, not file) to correct directory for output files

You may want to change these lines:

    Change line 15 if different temporal aggregation of pattern is wanted
    Change lines 19-22 if different time spans for climatology and pattern are wanted
    Change lines 27-28 if not CMIP files to reflect files in input directories
    Change lines 57-58 & 67-68 if Kelvin is prefered. Comment out these lines with ";"
    Change lines 89-90 if seasonal is wanted. Line 87 shows how to do this
    Change line 112 if different different unit is used. Change "Degree C" only.
    Change line 199 if seasonal is wanted.

To run the script:

1.  Make sure NCL is installed on local/remote machine
2.  Make sure output file is writable
3.  Type "ncl" and then the *.ncl script (ex. "ncl test.ncl").  The ".ncl" means this is the executeable script.
