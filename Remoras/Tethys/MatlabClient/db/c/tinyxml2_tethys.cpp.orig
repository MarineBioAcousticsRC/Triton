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


#include "tinyxml2.h"

/*
 * uncomment to fix next compilation error on 32bit Windows:  
 *      error C2371: 'char16_t' : redefinition; different basic types
 */
// #ifdef _CHAR16T
// #define CHAR16_T
// #endif

#include <mex.h>
//#include <windows.h>

#include <string>
#include <sstream>
#include <tuple>
#include <vector>
#include <iostream>
#include <unordered_map>
#include <math.h>   // fabs

/*#include <b64/encode.h>
#include <b64/decode.h>
*/

/*
 * Assume 32 bit addressing for old Matlab
 * See MEX option "compatibleArrayDims" for MEX in Matlab >= 7.7.
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


// 
// //two strings
// void debugMsg(bool toMat, const char* fmt,const char *str1,const char *str2 )
// 	{
// 		char buffer[240];
// 		sprintf(buffer,fmt,str1,str2);
// 		OutputDebugStringA(buffer);
// 		if(toMat)
// 			mexPrintf(buffer);
// 	}
// //one string
// void debugMsg(bool toMat, const char* fmt,const char *str)
// 	{
// 		char buffer[240];
// 		sprintf(buffer,fmt,str);
// 		OutputDebugStringA(buffer);
// 		if(toMat)
// 			mexPrintf(buffer);
// 	}
// 
// //int, str
// void debugMsg(bool toMat, const char* fmt,int num,const char *str)
// 	{
// 		char buffer[240];
// 		sprintf(buffer,fmt,num,str);
// 		OutputDebugStringA(buffer);
// 		if(toMat)
// 			mexPrintf(buffer);
// 	}
// //int, str1,str2
// void debugMsg(bool toMat, const char* fmt,int num,const char *str1,const char *str2)
// 	{
// 		char buffer[240];
// 		sprintf(buffer,fmt,num,str1,str2);
// 		OutputDebugStringA(buffer);
// 		if(toMat)
// 			mexPrintf(buffer);
// 	}
// 

// string
mxArray *extractChar(const tinyxml2::XMLElement *element)
{
    mxArray *aString = mxCreateString(element->GetText());
	const char *theString = element->GetText();
	//debugMsg(matVerbose,"'%s',\n", theString);
    
    return aString;
}

//for attributes
mxArray *extractChar(const tinyxml2::XMLAttribute *attr)
{
    mxArray *aString = mxCreateString(attr->Value());
    
    return aString;
}

//double

mxArray *extractDouble(const tinyxml2::XMLElement *element)
{
	double value = 0;
	element->QueryDoubleText( &value);
	mxArray *aDouble = mxCreateDoubleScalar(value);
	return aDouble;
}

//datevector

mxArray *extractDatevec(const tinyxml2::XMLElement *element)
{
	//ASSUMES ISO8601
	//always 1x6: yr,mo,day,hr,min,sec.ms
	mwSize mrows = 1;
	mwSize ncols = 6;
	double *datevec_ptr;
	
	//create a 1x6 double matrix (vector)
    mxArray *dateVector = mxCreateDoubleMatrix(mrows,ncols,mxREAL);

	//get teh pointer to the new matrix
	datevec_ptr = mxGetPr(dateVector);

	//parse the date
	const char *date = element->GetText();
	//debugMsg(matVerbose,"'%s'--parsing\n", date);

	string dateStr = (string)date;
	//'2010-03-30T17:11:15.345Z' no timezone
	//'2010-03-30T17:11:15.345-05:00' with timezone
	//add the date to the vector
	datevec_ptr[0] = stod(dateStr.substr(0,4)); //yr
	datevec_ptr[1] = stod(dateStr.substr(5,2));//mo
	datevec_ptr[2] = stod(dateStr.substr(8,2));//day
	datevec_ptr[3] = stod(dateStr.substr(11,2));//hr
	datevec_ptr[4] = stod(dateStr.substr(14,2));//min
	//Get the remainder of string, check for timezone info
	string remain = dateStr.substr(17);
	size_t neg_tok =  remain.find("-");
	size_t pos_tok = remain.find("+");
	if(neg_tok != remain.npos)
	{//negative offset
		//add the two characters after token to datevec_ptr[3] (hr)
		double hr_offset = stod(remain.substr(neg_tok+1,2));
		datevec_ptr[3] = datevec_ptr[3] + hr_offset;
		//move over four chars, add teh rest to [4] (min
		double min_offset = stod(remain.substr(neg_tok+4,2));
		datevec_ptr[4] = datevec_ptr[4] + min_offset;
		//handle seconds [5]
		datevec_ptr[5] = stod(remain.substr(0,neg_tok));
	}else if (pos_tok != remain.npos)
	{//positive offset
		//add the two characters after token to datevec_ptr[3] (hr)
		double hr_offset = stod(remain.substr(pos_tok+1,2));
		datevec_ptr[3] = datevec_ptr[3] - hr_offset;
		//move over four chars, add teh rest to [4]  (min)
		double min_offset = stod(remain.substr(pos_tok+4,2));
		datevec_ptr[4] = datevec_ptr[4] - min_offset;
		//handle seconds [5]
		datevec_ptr[5] = stod(remain.substr(0,pos_tok));
	}else
	{//no tz info,check for Z and remove it if so
		size_t z_tok = remain.find("Z");
		if (z_tok != remain.npos)
		{//has it, rmove it
		remain.resize(remain.size()-1);//remove the Z
		}
		datevec_ptr[5] = stod(remain);
	}


    return dateVector;
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
		//we only need to make a bunch of fields here, for each attribute. so...
		//do (first attribute field, val) while next attribute
		do{
			while(attrElement){
				j++;
				const tinyxml2::XMLAttribute *attr = attrElement->FirstAttribute();
				while (attr){
					const char *attrName = attr-> Name();			
					
					mxArray *attrFieldValue = extractChar(attr); // just char for now, should probably cell it


					// add fieldname if it exists
					attrFieldNumber = mxGetFieldNumber(attrStruct, attrName);
					if(attrFieldNumber<0)
					{   // field does not exist; add 
						//debugMsg(matVerbose,"eS:adding field '%s' in '%s'\n", name, thisEleName);
						attrFieldNumber=mxAddField(attrStruct, attrName);
						if(attrFieldNumber<0)
							mexErrMsgIdAndTxt(MSGID_READ, "can't add field");

					}

					if(attrFieldValue)
					{
						//debugMsg(matVerbose,"eS:setting value at position %i, for field '%s' in '%s' \n",j-1,name,thisEleName);
						mxSetFieldByNumber(attrStruct, j-1, attrFieldNumber, attrFieldValue); 
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

			//TODO: cell//typemap
			mxArray *attrFieldValue = extractChar(attr);
			
			// add fieldname if it exists
			attrFieldNumber = mxGetFieldNumber(attrStruct, attrName);
			if(attrFieldNumber<0)
			{   // field does not exist; add 
				//debugMsg(matVerbose,"eS:adding field '%s' in '%s'\n", name, thisEleName);
				attrFieldNumber=mxAddField(attrStruct, attrName);
				if(attrFieldNumber<0)
					mexErrMsgIdAndTxt(MSGID_READ, "can't add field");

			}

			if(attrFieldValue)
			{
				//debugMsg(matVerbose,"eS:setting value at position %i, for field '%s' in '%s' \n",j-1,name,thisEleName);
				mxSetFieldByNumber(attrStruct, struct_index, attrFieldNumber, attrFieldValue); 
			}
			else
				mexWarnMsgIdAndTxt(MSGID_READ, "struct field %s (idx %d) is corrupted\n", attrName, struct_index);


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
