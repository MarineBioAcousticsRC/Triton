/*
 * This file has been modified to work with the Tethys Metadata Workbench
 * The original file header is below. Most of the remarks are irrelevant to Tethys.
 * Modifications were done by Sean Herbert of Scripps Inst. Oceanography.
 * Last change: 2015-10-14
 * 2016-03-25 - integrated attribute retrieval
 */



/*
 *   XML serializing/deserializing of MATLAB arrays
 *   author: Ladislav Dobrovsky   (dobrovsky@fme.vutbr.cz, ladislav.dobrovsky@gmail.com)
 *   
 *   last change: 2015-03-17
 *
 *
 *   2015-02-28     Peter van den Biggelaar    Handle structure similar to xml_load from Matlab Central
 *   2015-03-05     Ladislav Dobrovsky         Function handles load/save  (str2func, func2str) 
 *   2015-03-05     Peter van den Biggelaar    Support N-dimension arrays
 *   2015-03-06     Peter van den Biggelaar    Support complex doubles and sparse matrices
 *   2015-03-07     Peter van den Biggelaar    updated tinyxml2.h from version 0.9.4 to version 2.2.0 and add tinyxml2.cpp from https://github.com/leethomason/tinyxml2
 *   2015-03-08     Peter van den Biggelaar    0.9.0: Support int64 and uint64 classes
 *   2015-03-11     Peter van den Biggelaar    0.9.1: Support Inf and NaN
 *   2015-03-13     Peter van den Biggelaar    0.9.2: Add MsgId's; put comment after header;
 *                                             Print Inf and NaN on Unix similar as Windows       
 *   2015-03-18     Peter van den Biggelaar    0.10.0: Fix roundtrip issue with empty cell and struct elements
 *                                             Allow 'on' and 'off' for OPTIONS
 *                                             Allow name input for root element
 *   2015-03-28     Peter van den Biggelaar    0.10.1: Build with version 3.0.0 of tinyxml2.cpp from https://github.com/leethomason/tinyxml2
 *                                             Include function name when returning version number
 *   2015-04-03     Ladislav Dobrovsky         1.0.0: Refactoring
 *                                             [DISABLED, not working] base64 coding of binary data (optional)  
 */

#define MEXFUNCNAME "tinyxml2_tethys"

#define TIXML2_WRAP_MAJOR_VERSION  "1"
#define TIXML2_WRAP_MINOR_VERSION  "0"
#define TIXML2_WRAP_PATCH_VERSION  "0"


/*
 * Microsoft does not support POSIX's strtok_r
 * Annex K of the C11 specifciation provides strtok_s
 * which is functionally equivalent.  
 * We have to tell the compiler that we are interested in using annex k 
 */
#define __STDC_WANT_LIB_EXT1__ 1
#include <cstdio>
#include <cstring>

// Use appropriate function
#ifndef _WIN32
#define STRTOK_R strtok_r
#else
#define STRTOK_R strtok_s
#endif

#include <regex>


#include "tinyxml2.h"
#include "tinyxml2_tethys.h"

/*
 * uncomment to fix next compilation error on 32bit Windows:  
 *      error C2371: 'char16_t' : redefinition; different basic types
 */
// #ifdef _CHAR16T
// #define CHAR16_T
// #endif

#include <mex.h>
#include "matrix.h"

//#include <windows.h>

#include <string>
#include <sstream>
#include <tuple>
#include <vector>
#include <iostream>
#include <unordered_map>
#include <math.h>   // fabs
#include <stdlib.h> // atof and atoi

#define NULLCHAR '\0'

// Use custom Matlab allocator in these STL functions
namespace mxalloc {
  using string = std::basic_string<char, std::char_traits<char>,
				   mex_allocator<char>>;
  using smatch = 
    std::match_results<mxalloc::string::const_iterator,
		       mex_allocator<std::string::const_iterator>>;

  using sregex_iterator =
    std::regex_iterator<mxalloc::string::const_iterator,
			mxalloc::string,
			std::regex_traits<char>>;

  using dvector =
    std::vector<double, mex_allocator<double>>;
}

/*#include <b64/encode.h>
#include <b64/decode.h>
*/

/*
 * Assume 32 bit addressing for old Matlab
 * See MEX option "compatibleArrayDims" for MEX in Matlab >= 7.7.
 * 64 bit indexing was added for Matlab in version 2006b
 */
#ifndef MWSIZE_MAX
typedef int mwSize;
typedef int mwIndex;
#endif

// format modifier for scanning and printing size_t
#ifdef _WIN64
#define PR_SIZET "ll"
#else
#define PR_SIZET "l"
#endif

#ifdef _WIN32
#define strcasecmp(x,y) _stricmp((x),(y))
#endif

using namespace tinyxml2;
using namespace std;



#define MSGID_INPUT         MEXFUNCNAME ":InputFail"
#define MSGID_READ          MEXFUNCNAME ":ReadFail"
#define MSGID_WRITE         MEXFUNCNAME ":WriteFail"
#define MSGID_CLASSID       MEXFUNCNAME ":ClassIdFail"
#define MSGID_CALLMATLAB    MEXFUNCNAME ":CallMatlabFail"
#define MSGID_DEVEL         MEXFUNCNAME ":RuntimeError_Devel"




#include "exportoptions.h"
#include "misc_utils.h"

mxArray * extractAny(const tinyxml2::XMLElement *element);
unordered_map<string,string> typeMap;
bool matVerbose = false;



/*
 * Extraction routines
 * Given an XMLELement or XMLAttribute, retrieve values.
 * In most cases, the code is identical, but XMLElement and XMLAttribute
 * do not share the same interface.  Consequently, we create small wrappers
 * that extract the relevant information then call a single processing function.
 */

// Retrieve strings from elements and attributes

mxArray *extractChar(const tinyxml2::XMLElement *element)
{
    mxArray *aString = mxCreateString(element->GetText());
	const char *theString = element->GetText();
    
    return aString;
}

mxArray *extractChar(const tinyxml2::XMLAttribute *attr)
{
    mxArray *aString = mxCreateString(attr->Value()); 
    return aString;
}

/*
 * count tokens
 * Given a string, count the number of tokens in it
 * Note that str will be modified 
 */
int countTokens(char* text, const char *delims) {

  char *ptr = nullptr;  // pointer into text
  char *start;	// start of current token 

  int tokens = 0;

  // Get first possible token
  start = STRTOK_R(text, delims, &ptr);

  // count tokens
  while (start != nullptr) {
    tokens++;
    start = STRTOK_R(nullptr, delims, &ptr);
  }
  
  return tokens; // return count
}

// double: 1 or more doubles
// Common function that operates on a string
mxArray *extractDouble(const char *str)
{
	char* text = reinterpret_cast<char*>(mxMalloc(strlen(str) + 1));
	strcpy(text, str);  // strtok won't take a const char */

	double value;  // a number in list of dobules
	char *ptr = nullptr;  // pointer into text
	char *start;	// start of current token 

	// Tokens separted by whitespace, comma or semicolon
	char *delims = " \t\n,;";
	int n = countTokens(text, delims);
	
	// Create the matrix
	mxArray *vector = mxCreateDoubleMatrix(1, n, mxREAL);

	// Populate the matrix
	double *dblptr = mxGetPr(vector);
	ptr = nullptr; 
	strcpy(text, str); // strtok modified text, get fresh copy
	start = STRTOK_R(text, delims, &ptr);
	for (int idx = 0; idx < n; idx++) {
	  // parse & store
	  if (TIXML_SSCANF(start, "%lf", &value) == 1) {
	    *dblptr = value;
	    dblptr++;
	  }
	  // prepare next entry
	  start = STRTOK_R(nullptr, delims, &ptr);  
	}
	
	return vector;
}

// element and attribute functions
mxArray* extractDouble(const tinyxml2::XMLElement* element) {
	const char* text = element->GetText();
	return extractDouble(text);
}

mxArray* extractDouble(const tinyxml2::XMLAttribute* attr)
{
	const char* text = attr->Value();
	return extractDouble(text);
}

#if !defined(MAX)
#define	MAX(A, B)	((A) > (B) ? (A) : (B))
#endif

/*
 * date2serial
 * Given a timestamp broken into components:
 * year, month, day, hours, minutes, and seconds,
 * convert it to a Matlab serial date.
 * Based on Mathworks's datenummx source code which was published
 * until MatlabR13.
 */

/* Cumulative days per month in a nonleap year. */
static double cum_dayspermonth[] = {0,31,59,90,120,151,181,212,243,273,304,334};

double date2serial(int year, int month, int day,
		   double hours=0, double minutes=0, double seconds=0)
{
  // Conversion factors
  const int months_per_year = 12;
  const double days_per_year = 365;
  const double s_per_min = 60;
  const double s_per_h = 3600; 
  const double s_per_day = 86400.0;
  // Leap year check (more complicated than this, see below)
  const double delta_leap_year = 4.0;
  
  double date;  // serial date
  
  // Ensure proper ranges
  if (month < 1)
    month = 1;
  else if (month > months_per_year) {
    // Too many months, bump up year & take mod month
    year = year + month/months_per_year;
    month = ((month-1) % months_per_year) + 1;
  }

  /* Add in offset for weird Gregorian calendar rules.
   * In addition to years divisibile by 4, 
   * years disisible by 100 are leap year nly if they are
   * also divisible by 400.  
   */
  
  // Number of leap days up to the start of the current year
  double leap_days = ceil(year / delta_leap_year) -
    ceil(year / 100.0) + ceil(year / 400.0);

  // Compute day/month/year
  date = days_per_year*year + leap_days + cum_dayspermonth[month-1] + day;

  // Have we passed a leap day in the current year?
  if (month > 2 &&
      ((year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0)))
    date += 1.0;  // correct for leap day

  // Add time offset into day
  double offset_s = hours * s_per_h + minutes * s_per_min + seconds;
  date = date + offset_s / s_per_day;

  return date;
}

/* Regular expression of an ISO8601 timestamp
 * Matches strings such as:
 *	2019-09-26T13:00:05.3982Z    GMT
 *	2019-09-26T13:00:06.3982+01  GMT+1, will be stored in GMT
 *	2019-09-26T13:00:07-08:00    GMT-8, will be stored in GMT
 *
 * Pattern groups are:
 * \1 year	\4 hour		\8 time zone Z or +/- HH or HH:MM
 * \2 month	\5 minute   \9 +|- timezeone offset \10 HH \11 MM
 * \3 day	\6 seconds (including fractional)
 *
 * Group \7 is fractional seconds and is probably not needed
 */
regex iso8601_re(R"([:space:]*(\d{4})-(\d{1,2})-(\d{1,2})T(\d{2}):(\d{2}):(\d{2}(.\d+)?)(Z|([+-])(\d{2})(:?(\d{2}))?)?)");
//([:space:] * (\d{ 4 }) - (\d{ 1,2 }) - (\d{ 1,2 })T(\d{ 2 }) :(\d{ 2 }) : (\d{ 2 }(.\d + ) ? )(Z | [+-]\d{ 2 }(: ? \d{ 2 }) ? ) ? )");

/*
 * Extract a list of ISO8601 dates and convert them to a vector of serial dates
 */

#define MAXLEN 512
mxArray* extractDateVec(const char* str) {

  char *text = reinterpret_cast<char *>(mxMalloc(strlen(str)+1));
  strcpy(text, str);  // strtok won't take a const char */

  // Tokens separted by whitespace, comma or semicolon
  char *delims = " \t\n,;";
  int n = countTokens(text, delims);
  strcpy(text, str); // strtok modified text, get fresh copy

  // timestamp variables
  int yr, mon, day;
  double hr, min, sec;
  double offset_hr, offset_min;

  // Create the matrix
  mxArray *vector = mxCreateDoubleMatrix(1, n, mxREAL);

  // Populate the matrix
  char field[MAXLEN];
  double *dblptr = mxGetPr(vector);
  char *ptr = nullptr; 
  char *start = STRTOK_R(text, delims, &ptr);
  for (int idx = 0; idx < n; idx++) {
    /* parse & store
     * parsing assumes fixed field positions for most fields
     */
    strncpy(field, start, 4);	// year
    field[4] = NULLCHAR;
    yr = atoi(field);

    strncpy(field, start+5, 2);	// month
    field[2] = NULLCHAR;
    mon = atoi(field);

    strncpy(field, start+8, 2); // day
    field[2] = NULLCHAR;
    day = atoi(field);

    strncpy(field, start+11, 2); // hr
    field[2] = NULLCHAR;
    hr = atof(field);

    strncpy(field, start+14, 2); // min
    field[2]= NULLCHAR;
    min = atof(field);

    // seconds is up to the +/-/Z timezone symbol
    int chars = 0;
    int posn = 17;
    char current = *(start+posn);
    while (current != NULL && current != 'Z' && current != '+' && current != '-') {
      chars++;
      posn++;
      current = *(start+posn);
    }
    strncpy(field, start+17, chars);
    field[chars] = NULLCHAR;
    sec = atof(field);
    
    if (current == '+' || current == '-') {
      // contains a timezone offset, parse it
      int sign = (current == '+') ? 1 : -1;
      // ISO 8601 supports ±HH:MM or ±HHMM
      posn++;  // move past ±

      // handle hours offset
      strncpy(field, start+posn, 2);
      field[2] = NULLCHAR;
      offset_hr = atof(field);
      posn += 2;

      // check for minute offset
      if (*(start+posn) == ':')
	posn++;
      if (*(start+posn) != NULLCHAR) {
	strncpy(field, start+posn, 2);
	field[2] = NULLCHAR;
	offset_min = atof(field);
      } else
	offset_min = 0;

      // Adjust time
      hr += sign * offset_hr;
      min += sign * offset_min;
    }	

    double value = date2serial(yr, mon, day, hr, min, sec);
    *dblptr = value;
    dblptr++;

    // prepare next entry
    start = STRTOK_R(nullptr, delims, &ptr);  
  }

  return vector;
}

mxArray* extractDatevec(const tinyxml2::XMLElement* element) {
	const char* tmptext = element->GetText();
	return extractDateVec(tmptext);
}

mxArray* extractDatevec(const tinyxml2::XMLAttribute* attrib) {
	const char* tmptext = attrib->Value();
	return extractDateVec(tmptext);
}
/*
 * Extract a list of ISO8601 dates and convert them to a vector of serial dates
 * CAVEAT:  This is designed to be a more flexible version of extractDatevec.
 * It is not currently used as the STL uses the C++ memory allocator which 
 * is causing Matlab to crash.  We have tried usign a custom allocator, but 
 * we are still seeing iterators cause crashes and are not using this code
 * for now.
 */

mxArray *extractDatevecRE(const string data)
{
  // Count the number of matched paterns we get
  int n = 0;
  /*
  for (mxalloc::sregex_iterator it {data.begin(), data.end(), iso8601_re};
       it!=sregex_iterator{}; it++) {
    mxalloc::smatch m = *it;  // extract the match
    if (! m[0].str().empty()) // matched pattern?
      n++;
  }
  */
  // Create & populate the array
  mxArray *dates = mxCreateDoubleMatrix(1, n, mxREAL);
  /*
  // timestamp variables
  int yr;
  int mon;
  int day;
  double hr;
  double min;
  double sec;

  double *dptr = mxGetPr(dates);
  for (sregex_iterator it {data.begin(), data.end(), iso8601_re};
       it!=sregex_iterator{}; it++) {
    mxalloc::smatch m = *it;  // extract the match
    if (! m[0].str().empty()) {
      yr = stoi(m[1].str());
      mon = stoi(m[2].str());
      day = stoi(m[3].str());
	  hr = stod(m[4].str());
	  min = stod(m[5].str());
	  sec = stod(m[6].str());
	  string tzoffset = m[9].str();
	  if (! tzoffset.empty()) {
		  // User specified a timezone offset
		  int sign = tzoffset.compare("+") ? 1 : -1;
		  hr = hr + sign * stod(m[10].str());
		  sec = sec + sign * stod(m[11].str());
	  }
	  double timestamp = date2serial(yr, mon, day, hr, min, sec);
	  *dptr = timestamp;
	  dptr++;
    }
  }
  */
  return dates;
}

mxArray* extractDatevecRE(const tinyxml2::XMLElement* element) {
	string data(element->GetText());
	return extractDatevecRE(data);
}

mxArray* extractDatevecRE(const tinyxml2::XMLAttribute* attrib) {
	string data(attrib->Value());
	return extractDatevecRE(data);
}

//cells
mxArray *extractCell(const XMLElement *element)
{

	const char *thisEleName= element->Value();
	const char *siblingName = " "; // spaces never allowed in XML. crashes if set to NULL in strcmp
	const char *name=NULL;
	
	int numel=0;

	//determine length by counting siblings with the same name
	const tinyxml2::XMLElement *cellElement = element;
	do {
		numel++;
		name = cellElement->Value();
		const tinyxml2::XMLElement *siblingElement = cellElement->NextSiblingElement();
		if(siblingElement)
		{
			siblingName=siblingElement->Value();
			cellElement = siblingElement;
		}else
			siblingName = " ";//break
	} while(strcmp(siblingName,name)==0);

	int rows =1; // one row
	int members = numel;

    mxArray *theCell = mxCreateCellMatrix(rows, members);

	string classStr;

	int idx=0;
	if(members)
	{
		do{
			idx++;
			//get the type from the unordered map
			try
			{
				string name = (string) thisEleName;
				classStr = typeMap.at(name); //global map
			}
			catch(const out_of_range noKey)
			{ //default to string
				classStr = "char";
			}

			Utils::TethysType dataType = Utils::getDatatype(classStr);
			mxArray *cellValue;
			switch(dataType)
			{
			case Utils::tySTRING:		
				cellValue = extractChar(element);
				break;
			case Utils::tyDOUBLE:		
				cellValue = extractDouble(element);
				break;
			case Utils::tyDATE:
				cellValue = extractDatevec(element);
				break;
			}

			mxSetCell(theCell, idx-1, cellValue);
			element = element->NextSiblingElement();//should only go for as long as they share names
		}while(idx<members);

	}

	return theCell;	
}




//REDO, extractAttrStruct, and pass in the element. Count siblings, for dimensions of attribute struct,
//then loop through each attribute adding them as fields. check if it exists before adding.
//increment the array idx (j) for each sibling element.
mxArray *extractAttrStruct(const tinyxml2::XMLElement *attrElement)
{
	mwSize ndim=0;
	size_t numel=0;
	mwSize *dims = Utils::getDimensions(&ndim, &numel);

	

	//maybe a less repetitive way to do this besides counting AGAIN?
	//trying to create struct X_attr(N) for each sibling element
	//that way things like:
	// <Call Count = 1>
	// <Call>
	// <Call Count = 2>
	// can still be parsed, with Call_attr(1) == Count : '1', Call_attr(2) == empty, Call_attr(3) == Count : '2', etc.

	const char *siblingName = " "; // spaces illegal for XML, used to break out of 'while'. crashes if set to NULL in strcmp
	const char *childName = " ";
	const char *name = NULL;
	
	numel = 0;
	//use this var to count
	const tinyxml2::XMLElement *countElement = attrElement;
	do {
		numel++;
		name = countElement->Value();
		const tinyxml2::XMLElement *siblingElement = countElement->NextSiblingElement();
		if(siblingElement)
		{
			siblingName=siblingElement->Value();
			countElement = siblingElement;
		}else
			siblingName = " ";
	} while(strcmp(siblingName,name)==0);

	int members = (int)numel;
	dims[0] = 1;                // linear, single row struct
	dims[1] = members;    // columns: struct(1), struct(2), etc
	
	
	mxArray *attrStruct = mxCreateStructArray(ndim, dims, 0, 0);
	mxFree(dims);
	if(!attrStruct)
		mexErrMsgIdAndTxt(MSGID_READ, "creating structure array failed.");

	if(members)
	{
		int attrFieldNumber = 0;
		int j = 0; // counter for the do-while
		string classStr;
		//we only need to make a bunch of fields here, for each attribute. so...
		//do (first attribute field, val) while next attribute
		do{
			while(attrElement){
				j++;
				const tinyxml2::XMLAttribute *attr = attrElement->FirstAttribute();
				while (attr){
					const char *attrName = attr-> Name();			

					// get the type from the unordered map
					try {
					  string name = (string) attrName;
					  classStr = typeMap.at(name); //global map
					} catch (const out_of_range noKey) {
					  classStr = "char";  // default to string
					}


					Utils::TethysType dataType = Utils::getDatatype(classStr);
					mxArray *cellValue;
					switch(dataType){
					  case Utils::tySTRING:		
					    cellValue = extractChar(attrElement);
					    break;
					  case Utils::tyDOUBLE:		
					    cellValue = extractDouble(attrElement);
					    break;
					  case Utils::tyDATE:
					    cellValue = extractDatevec(attrElement);
					    break;
					}
					
					// add fieldname if it does not exist, otherwise access it
					attrFieldNumber = mxGetFieldNumber(attrStruct, attrName);
					if(attrFieldNumber<0)
					{   // field does not exist; add 
						//debugMsg(matVerbose,"eS:adding field '%s' in '%s'\n", name, thisEleName);
						attrFieldNumber=mxAddField(attrStruct, attrName);
						if(attrFieldNumber<0)
							mexErrMsgIdAndTxt(MSGID_READ, "can't add field");

					}

					if(cellValue)
					{
						//debugMsg(matVerbose,"eS:setting value at position %i, for field '%s' in '%s' \n",j-1,name,thisEleName);
						mxSetFieldByNumber(attrStruct, j-1, attrFieldNumber, cellValue); 
					}
					else
						mexWarnMsgIdAndTxt(MSGID_READ, "struct field %s (idx %d) is corrupted\n", attrName, j);

					attr = attr->Next();
				}

				attrElement = attrElement->NextSiblingElement();
			}

		}while(j<members);
	}

	return attrStruct;
}


mxArray *createAttrStruct(unordered_map<int,vector<const tinyxml2::XMLAttribute*>> attributes, int count){
	//creates a struct array from an input map which holds the attributes for each element, indexed by the key
	//count represents the number of siblings with the same name, which translates into the size of the struct


	mwSize ndim=0;
	size_t numel=0;
	mwSize *dims = Utils::getDimensions(&ndim, &numel);

	dims[0] = 1;                // linear, single row struct
	dims[1] = count;    // columns: struct(1), struct(2), etc

	mxArray *attrStruct = mxCreateStructArray(ndim, dims, 0, 0);
	mxFree(dims);


	//loop through attributes map
	//getting the index as the key and a vector of attributes as the value
#ifdef _WIN32
	for each (auto key_val in attributes){
#else
	for (auto key_val : attributes){
#endif
		int struct_index = key_val.first;

		vector<const tinyxml2::XMLAttribute*> val_vector = key_val.second;
#ifdef _WIN32
	for each (auto attr in val_vector){
#else
	for (auto attr : val_vector){
#endif

			int attrFieldNumber = 0;
			const char *attrName = attr-> Name();
			string classStr;

			// get the type from the unordered map
			try {
				string name = (string)attrName;
				classStr = typeMap.at(name); //global map (ugh!)
			}
			catch (const out_of_range noKey) {
				classStr = "char";  // default to string
			}

			Utils::TethysType dataType = Utils::getDatatype(classStr);
			mxArray* cellValue;
			switch (dataType) {
			case Utils::tySTRING:
				cellValue = extractChar(attr);
				break;
			case Utils::tyDOUBLE:
				cellValue = extractDouble(attr);
				break;
			case Utils::tyDATE:
				cellValue = extractDatevec(attr);
				break;
			}
			
			// add fieldname if it exists
			attrFieldNumber = mxGetFieldNumber(attrStruct, attrName);
			if(attrFieldNumber<0)
			{   // field does not exist; add 
				//debugMsg(matVerbose,"eS:adding field '%s' in '%s'\n", name, thisEleName);
				attrFieldNumber=mxAddField(attrStruct, attrName);
				if(attrFieldNumber<0)
					mexErrMsgIdAndTxt(MSGID_READ, "can't add field");

			}

			if (cellValue) {
				//debugMsg(matVerbose,"eS:setting value at position %i, for field '%s' in '%s' \n",j-1,name,thisEleName);
				mxSetFieldByNumber(attrStruct, struct_index, attrFieldNumber, cellValue);
			} else {
				mexWarnMsgIdAndTxt(MSGID_READ, "struct field %s (idx %d) is corrupted\n", attrName, struct_index);
			}

		}
	}

	return attrStruct;
}


mxArray *extractStruct(const tinyxml2::XMLElement *structElement)
{
    mwSize ndim=0;
	size_t numel=0;
	mwSize *dims = Utils::getDimensions(&ndim, &numel);

	const char *thisEleName= structElement->Value();


	// determine struct size by counting siblings with same name
	//assumes all siblings are grouped by name in the XML
	numel=0;
	

	const char *siblingName = " "; // spaces illegal for XML, used to break out of 'while'. crashes if set to NULL in strcmp
	const char *childName = " ";
	const char *name = NULL;
	

	//use this var to count siblings
	const tinyxml2::XMLElement *countElement = structElement;


	//count siblings of same name to know the size of this struct
	//two sibling <Detection> elements, with children, 
	//will result in Detection(1).field, Detection(2).field

	do {
		numel++;
		name = countElement->Value();

		//check for attributes
		//const tinyxml2::XMLAttribute *attribute = countElement->FirstAttribute();
		//if(attribute)
		//	has_attr = true;


		const tinyxml2::XMLElement *siblingElement = countElement->NextSiblingElement();
		if(siblingElement)
		{
			siblingName=siblingElement->Value();
			countElement = siblingElement;
		}else
			siblingName = " ";
	} while(strcmp(siblingName,name)==0);

	int members = (int)numel;
	dims[0] = 1;                // linear, single row struct
	dims[1] = members;    // columns: struct(1), struct(2), etc
	


	//debugMsg(matVerbose,"eS:setting size to 1x%i for '%s'\n",members,thisEleName);
	mxArray *theStruct = mxCreateStructArray(ndim, dims, 0, 0);
	mxFree(dims);
	if(!theStruct)
		mexErrMsgIdAndTxt(MSGID_READ, "creating structure array failed.");

	if(members)
	{
		int fieldNumber = 0;
		int attrStructFieldNumber = 0;
		int j = 0; // counter for the do-while
		do{
			j++;
			const tinyxml2::XMLElement *childElement=structElement->FirstChildElement();
			//Add all children with the same name to the struct field
			//assumes they are grouped together
			while(childElement)
			{
				const char *name = childElement->Value();

				// add fieldname if it exists
				fieldNumber = mxGetFieldNumber(theStruct, name);
				if(fieldNumber<0)
				{   // field does not exist; add 
					//debugMsg(matVerbose,"eS:adding field '%s' in '%s'\n", name, thisEleName);
					fieldNumber=mxAddField(theStruct, name);
					if(fieldNumber<0)
						mexErrMsgIdAndTxt(MSGID_READ, "can't add field");
				}
				else
				{
					//field exists
					//debugMsg(matVerbose,"eS:field '%s' exists in '%s' \n",name,thisEleName);
				}

				// set field value
				//debugMsg(matVerbose,"eS:extracting fieldValue for '%s'\n",name);
				mxArray *fieldValue = extractAny(childElement);

				if(false)
				{
					//const tinyxml2::XMLAttribute *attrdos = attr->Next();
					string attrFieldStr = name;
					attrFieldStr += "_attr";
					const char *cAttrStr = attrFieldStr.c_str();
					attrStructFieldNumber = mxAddField(theStruct,cAttrStr);
					//mxSetFieldByNumber(theStruct,j-1,attrFieldNumber,attr_val);
					//has an attribute, create a struct for all attributes
					//attrStruct = extractAttrStruct(childElement);
				}

				if(fieldValue)
				{
					//debugMsg(matVerbose,"eS:setting value at position %i, for field '%s' in '%s' \n",j-1,name,thisEleName);
					mxSetFieldByNumber(theStruct, j-1, fieldNumber, fieldValue); 
				}
				else
					mexWarnMsgIdAndTxt(MSGID_READ, "struct field %s (idx %d) is corrupted\n", name, j);

				//loop thru kids until a new name is found
				//set_size keeps track of how many same-named siblings exist
				int set_size = 0;
				do{
					set_size++;
					childElement = childElement->NextSiblingElement();
					if(childElement)
					{
						childName = childElement->Value();
						//debugMsg(matVerbose,"eS:sibling '%s' found for child '%s'\n",childName,name);
					}
					else
					{
						//debugMsg(matVerbose,"eS:no more siblings for child '%s'\n",name);
						childName=" ";//break
					}
				}while(strcmp(childName,name)==0);

				//check if childElement has an attribute
				//if so, create a field called name_attr
				//value will be another struct....fieldname: attr_value
				//attr names are unique

				unordered_map<string,unordered_map<int,vector<const tinyxml2::XMLAttribute*>>> attrMap = Utils::pullAttributes(structElement->FirstChildElement());
				if (attrMap.count(name)>0){
					//attribute exists for this set

					mxArray *attrStruct = NULL; //init

					//create _attr field for the struct
					string attrFieldStr = name;
					attrFieldStr += "_attr";
					const char *cAttrStr = attrFieldStr.c_str();
					attrStructFieldNumber = mxAddField(theStruct,cAttrStr);

					unordered_map<int,vector<const tinyxml2::XMLAttribute*>> elementAttributes = attrMap[name];
					attrStruct = createAttrStruct(elementAttributes,set_size);

					//if attributes, add that
					if(attrStruct)
						//debugMsg(matVerbose,"eS:setting value at position %i, for field '%s' in '%s' \n",j-1,name,thisEleName);
						mxSetFieldByNumber(theStruct, j-1, attrStructFieldNumber, attrStruct); 
					
				}


			}

			structElement = structElement->NextSiblingElement();
		}while(j<members);
	}

	//debugMsg(matVerbose,"eS:returning theStruct for '%s'\n",thisEleName);
	return theStruct;
}


mxArray *extractAny(const tinyxml2::XMLElement *element)
{
	string classStr;
	const char* name = element->Value();




	// have children elements -> struct
	if(element->FirstChildElement())
	{   
		classStr="struct";
		//debugMsg(matVerbose,"eA:creating struct for '%s'\n",name);
		return extractStruct(element);
	}
	else //make it a cell
	{ 
		classStr="cell";
		//debugMsg(matVerbose,"eA:creating cell array for '%s':",name);
		return extractCell(element);

	}

	/*
	else //it is a lone leaf so do not array it
	{
		try
		{
			classStr = typeMap.at((string)name); //global map
		}
		catch(const out_of_range noKey)
		{ //default to string
			classStr = "char";
		}
		//debugMsg(matVerbose,"eA:creating '%s' leaf for '%s'\n",classStr.c_str(),name);
		mxClassID classID = Utils::getClassByName(classStr);

		switch(classID)
		{
		case mxDOUBLE_CLASS:   return extractDouble(element);
		case mxCHAR_CLASS:	   return extractChar(element);
		default:
			{
				mexErrMsgIdAndTxt(MSGID_CLASSID, "unrecognized or unsupported class: %s", classStr);
			}
		}
	}
	*/


	return NULL;  
}

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
	if(nlhs>1)
		mexErrMsgIdAndTxt(MSGID_INPUT, "Too many output arguments\n");
	if(nrhs<1)
		mexErrMsgIdAndTxt(MSGID_INPUT, "Not enough input arguments: " MEXFUNCNAME "(mode, ...)\n");

	const mxArray *mode_MA = prhs[0];
	if(!mxIsChar(mode_MA))
		mexErrMsgIdAndTxt(MSGID_INPUT, "mode must be a string\n");

	char * modeString = mxArrayToString(mode_MA);
	if(!modeString)
		mexErrMsgIdAndTxt(MSGID_INPUT, "mode string error\n");



	if(!strcmp(modeString, "load"))
	{
		if(nrhs<3)
			mexErrMsgIdAndTxt(MSGID_INPUT, "Not enough input arguments: " MEXFUNCNAME "('load', filename)\n");
		if(nrhs>3)
			mexErrMsgIdAndTxt(MSGID_INPUT, "Too many input arguments\n");

		const mxArray *filename_MA = prhs[1];
		if(!mxIsChar(filename_MA))
			mexErrMsgIdAndTxt(MSGID_INPUT, "filename must be a string\n");
		char * filename = mxArrayToString(filename_MA);
		if(!filename)
			mexErrMsgIdAndTxt(MSGID_INPUT, "filename string error\n");

		tinyxml2::XMLDocument doc;

		if (doc.LoadFile(filename) != XML_NO_ERROR)
		{
			mexErrMsgIdAndTxt(MSGID_READ, "failed reading file \"%s\" ; %s", doc.GetErrorStr1(), doc.GetErrorStr2());
		}

		const tinyxml2::XMLElement *root = doc.FirstChildElement();
		const char *rootName = root->Value();
		//mapping
		const mxArray *mapCells = prhs[2];
		if(!mxIsCell(mapCells))
			mexErrMsgIdAndTxt(MSGID_INPUT,"Type map must be two column cell array");
		typeMap = Utils::createMapFromCellArray(mapCells);
        
        if(!root && nlhs==0)
            mexWarnMsgIdAndTxt(MSGID_READ, "no XML elements found in %s\n", filename);
        
		//debugMsg(matVerbose,"Starting '%s'\n",rootName);
        plhs[0] = extractAny(root);
		//debugMsg(matVerbose,"Struct '%s' finalized\n",rootName);
        
        mxFree(filename);
    }

	else if(!strcmp(modeString, "parse"))
    {
        if(nrhs<3)
            mexErrMsgIdAndTxt(MSGID_INPUT, "Not enough input arguments: " MEXFUNCNAME "('parse', XMLstring)\n");
        if(nrhs>3)
            mexErrMsgIdAndTxt(MSGID_INPUT, "Too many input arguments\n");
        
        const mxArray *XMLstring_MA = prhs[1];
        if(!mxIsChar(XMLstring_MA))
            mexErrMsgIdAndTxt(MSGID_INPUT, "XMLstring must be a string\n");
        char * XMLstring = mxArrayToString(XMLstring_MA);    
        if(!XMLstring)
            mexErrMsgIdAndTxt(MSGID_INPUT, "XMLstring error\n");        
        
        tinyxml2::XMLDocument doc;
        
        if (doc.Parse(XMLstring) != XML_NO_ERROR)
        {
            mexErrMsgIdAndTxt(MSGID_READ, "failed parsing XMLstring \"%s\" ; %s", doc.GetErrorStr1(), doc.GetErrorStr2());
        }
        
        const tinyxml2::XMLElement *root = doc.FirstChildElement();
		const char *rootName = root->Value();

		//mapping
		const mxArray *mapCells = prhs[2];
		if(!mxIsCell(mapCells))
			mexErrMsgIdAndTxt(MSGID_INPUT,"Type map must be two column cell array");
		typeMap = Utils::createMapFromCellArray(mapCells);
        
        if(!root && nlhs==0)
            mexWarnMsgIdAndTxt(MSGID_READ, "no XML elements found in XMLstring\n");
        
        //debugMsg(matVerbose,"Starting '%s'\n",rootName);
        plhs[0] = extractAny(root);
		//debugMsg(matVerbose,"Struct '%s' finalized\n",rootName);
        
        mxFree(XMLstring);
    }
    
    else
        mexErrMsgIdAndTxt(MSGID_INPUT, "unknown mode: %s\n", modeString);
    
    mxFree(modeString);
}
