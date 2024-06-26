/****************************************************************************
 WAKE COUNTY PROPERTY TAX ANALYSIS               
*****************************************************************************
 02 - PDF TO TEXT
*****************************************************************************
 REQUIREMENTS: 
	- Must run the 
		- workshop/utility/00_utility_macros.sas program prior
	    - 01_download_pdf_files.sas
****************************************************************************/


/************************************************
 3. LOAD PDF FILES INTO CAS AS A TABLE  
 - This will extract the text and place it in a single column.           
************************************************/
/* Read in all of the PDF files in from the caslib path as a single CAS table */
/* Each PDF will be one row of data in the CAS table                */


/* Set locations of PDF files */
%let caslibLocation = 'casuser';
%let subdirectoryLocation = 'wc_pdfs';


/* Load PDF files as text in a CAS table */
proc casutil;
    load casdata=&subdirectoryLocation         /* To read in all files use in subdirectory. For a single PDF file specify the name and extension */
         incaslib=&caslibLocation              /* The location of the PDF files to load */
         importoptions=(fileType="document",   /* Specify document import options   */
                        fileExtList = 'PDF', 
                        tikaConv=True)           
		 casout='wc_data' outcaslib='casuser'  /* Specify the output cas table info */
         replace;                          
quit;

/* Create a libref to the Caslib to use SAS procs on the CAS table */
libname casuser cas caslib = &caslibLocation;

/* Preview CAS table PDF conversion */
proc print data=casuser.wc_data;
run;



/*********************************************
 5. CREATE TXT FILES FROM THE CAS TABLES 
 - Macro found in utility/00_utility_macro.sas
 - Simply take the CAS table and create a .txt file with everything
*********************************************/
%pdf_to_txt(casTable=casuser.wc_data,
			pdfFile = "wc_property_2014-current.pdf",
			fileOut="&path/data/wc_tax_data_2014_curr_raw.txt")

%pdf_to_txt(casTable=casuser.wc_data,
			pdfFile = "wc_property_1987_2013.pdf",
			fileOut="&path/data/wc_tax_data_1987_2013_raw.txt")