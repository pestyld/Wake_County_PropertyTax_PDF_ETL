/****************************************************************************
 WAKE COUNTY PROPERTY TAX ANALYSIS               
*****************************************************************************
 03 - CLEAN UNSTRUCTURED TEXT
*****************************************************************************
 Clean the following files:
- a. wc_tax_data_1987_2013_raw.txt
- b. wc_tax_data_2014_curr_raw.txt

 Create the structured tables in a SAS library:
- a. wc_1987_2013
- b. wc_2014_current

 Create final table for VA Report by joining the temporary tables above.
- wc_final_property_taxes
*****************************************************************************
 REQUIREMENTS: 
	- Must run the 
		- workshop/utility/00_utility_macros.sas program prior
	    - 01_download_pdf_files.sas
		- 02_pdf_to_text.sas
****************************************************************************/

/********************* 
 SET PATH TO FOLDER
*********************/
%getcwd(path)



/*****************************************
 Create structured data for wc_1987_2013
a. Clean wc_tax_data_1987_2013_raw.txt
*****************************************/
%let inputFile="&path/data/wc_tax_data_1987_2013_raw.txt";

%let final_table_name=wc_1987_2013;

/* Dynamically find the first year and last year in the data */
%get_max_min_years(inputFile=&inputFile)

/* Run clean data program - Future create macro program */
/* Leave as is for debugging purposes during workshop */
%include "&path/utility/clean_text_file.sas";



/*****************************************
 Create structured data for wc_2014_curr
a. Clean wc_tax_data_2014_curr_raw.txt
*****************************************/
%let inputFile="&path/data/wc_tax_data_2014_curr_raw.txt";

%let final_table_name=wc_2014_curr;

/* Dynamically find the first year and last year in the data */
%get_max_min_years(inputFile=&inputFile)

%include "&path/utility/clean_text_file.sas";



/*************************************************************
 CREATE FINAL TABLE BY CONCATENATING THE TWO CLEANED TABLES
*************************************************************
This exmaple the Casuser caslib location has been mounted to the Compute server.
This means that CAS + Compute can access that path.

That might not always be the case. I'll show you both ways to save it for CAS.
*************************************************************/

/* Preview clean structured tables */
proc print data=wc_1987_2013;
run;
proc print data=wc_2014_curr;
run;


/* 
 This method assumes the Casuser caslib location has been mounted and available to the Compute server as well as CAS 
*/

/* Final table location - Save to a place the CAS server can access */
%let final_table_output =%sysget(HOME)/casuser ;
libname finaltbl "&final_table_output";

proc sql;
create table finaltbl.wc_final_property_taxes as
	select * from wc_1987_2013
	union
	select * from wc_2014_curr
	order by CountyName, Year;
quit;

title height=16pt "Preview of the Final Table";
proc print data=finaltbl.wc_final_property_taxes;
run;
title;


/* 
 This method assumes the Compute Server and CAS server don't have a mounted location they can both access
*/

/* Create the table in the WORK library (or any other Compute library) */
proc sql;
create table work.wc_final_property_taxes as
	select * from wc_1987_2013
	union
	select * from wc_2014_curr
	order by CountyName, Year;
quit;


/* Load the table in the SAS library to CAS and save as a sashdat file */
proc casutil;
	/* Load SAS library table as a CAS table */
	load data=work.wc_final_property_taxes
		 casout='wc_final_property_taxes_save' outcaslib='casuser' replace;

	/* Save as sashdat file */
	save casdata='wc_final_property_taxes_save' incaslib='casuser'
		 casout='wc_final_property_taxes.sashdat' outcaslib='casuser' replace;
quit;