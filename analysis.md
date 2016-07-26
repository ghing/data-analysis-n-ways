Lead data analysis
==================

About the data
--------------

Each row represents a lead level (in parts per billion) test result for one test, at one location, in an Illinois water system.

Fields:

* `PWSID`: Water system ID
* `PWSNAME`: Water system name
* `COLLECTION_DATE`: Date the test was taken
* `RESULT`: amount of lead (in parts per billion)

Load the data
-------------

Load the water test data from [this CSV file](https://raw.githubusercontent.com/ghing/data-analysis-n-ways/master/data/il_lead_2004-2015_20160526.csv) and the water system data from [this CSV file](https://raw.githubusercontent.com/ghing/data-analysis-n-ways/master/data/illinois_water_systems.csv).

Check the data integrity
------------------------

* Are all the dates (`COLLECTION_DATE`) valid?
* Are all the results (`RESULT`) values valid numbers?
* Are the water system names (`PWSNAME`) and IDS (`PWSID`) consistent for all records?

Summary statistics
------------------

How many records are there in the data set?

How many water systems are there in the data?

What's the earliest test date?

What's the last test date?

What's the lowest lead level? In which system?

What's the highest lead level? In which system?

Find systems with test results above the EPA standard
-----------------------------------------------------

Which water systems had at least one result above the EPA standard of 15 parts per billion?  In which years? What percentage of water systems had a test over the threshold?

Find systems with very high lead levels
---------------------------------------

Which water systems had at least one result above the EPA standard of 40 parts per billion? In which years? What percentage of water systems had a test over the threshold?

Calculate 90th percentile
-------------------------

Group each water systems tests by water system and calendar year.  Then, calculate the 90th percentile value for each water system, for each year.

Which water systems exceeded the EPA standard
---------------------------------------------

Which water systems had a 90th percentile value above 15 parts per billion? In which years? How many systems exceeded the standard in one year? In two years? In three years ...?

How many systems exceeded the standard in the Chicago area?
-----------------------------------------------------------

For this analysis, consider the Chicago area as the following counties:

* Cook
* DuPage
* Kane
* Lake
* McHenry
* Will

Is there a spatial trend to water systems?
------------------------------------------

Plot the coordinates of the water system's contact address for systems that have exceeded the EPA standard of a 90th percentile value over 15 parts per billion? Does any part of the state seem to have a disproportionate number of water systems exceeding the standard?


