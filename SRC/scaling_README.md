Repository for SFA Climate Task.

Steps to creation of library for temperature scaling:

You must change these lines:

Change line 8 to reflect correct input file of Hector input
Change line 32 to reflect correct input files of patterns
Change line 233 to reflect correct output file directory

You may want to change these lines:

Change lines 10-13 to reflect longer time series.  NCL starts time index at "0" not "1".  Hector produces output to 2300
Change lines 17-18 to reflect chosen scenario
Change lines 24-25 to reflect longer time series
Change lines 27-28 to reflect chosen time series

**Note:
If you have changed the 'units' in the pattern creation code, you will need to change the 'units' in this script.