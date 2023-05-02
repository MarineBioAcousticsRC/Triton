#pragma once
#include <unordered_map>
#include <vector>


class Utils
{
public:

	enum TethysType
	{ 
		tySTRING, 
		tyDOUBLE, 
		tyDATE, 
		tyINTEGER 
	};

	static unordered_map<string,string> createMapFromCellArray(const mxArray *map)
		/*	Always takes in a n-by-2 cell array of strings. First column contains
			keys representing element names, second column takes a string describing its data type
		*/
		
	{
		size_t rows = mxGetM(map);
		unordered_map<string,string> theMap;

		//use mwIndex mxCalcSingleSubscript to reference the members
		mwSize nsubs; //always two dimensions
		mwIndex *subs;

		nsubs=mxGetNumberOfDimensions(map);
		
		/* Allocate memory for the subs array on the fly */
		subs=(mwIndex *)mxCalloc(nsubs,sizeof(mwIndex)); // remember to free this
		
		
		//loop through the cells.
		//column 1 contains keys,
		//column 2 values;
		
		for(int i=0;i<rows;i++)
		{
			//get the indices for the first pair (first column)
			//subs[0] is the row, subs[1] is the column. index starts at 0
			subs[1]=0;
			subs[0]=i;
			mwIndex key_idx = mxCalcSingleSubscript(map,nsubs,subs);

			//increment for the value
			subs[1]++;
			mwIndex val_idx = mxCalcSingleSubscript(map,nsubs,subs);
			
			//get the cell data
			mxArray *key_val = mxGetCell(map,key_idx);
			mxArray *val_val = mxGetCell(map,val_idx);
			string key = mxArrayToString(key_val);
			string val = mxArrayToString(val_val);
			theMap[key] = val;
			
		}
		

		mxFree(subs);
		return theMap;
	}


	static unordered_map<string,unordered_map<int,vector<const tinyxml2::XMLAttribute*>>> pullAttributes(const tinyxml2::XMLElement *firstChild)
	{
		const char *name = firstChild->Value();
		const tinyxml2::XMLElement *element = firstChild;

		unordered_map<string,unordered_map<int,vector<const tinyxml2::XMLAttribute*>>> attributeMaps;

		int child_idx = 0;
		bool attr_exist = false;

		//map to store the child index (key), and any associated attributes in a vector
		//when encountering a new name among siblings, it will be reset
		unordered_map<int,vector<const tinyxml2::XMLAttribute*>> attributeMap;

		while(element){
			const char *newName = element->Value();

			if(strcmp(name,newName)!=0){
				//we have encountered a new element name
				//add the previous attributes to the return vector
				if (!attributeMap.empty())
					attributeMaps[name] = attributeMap; //add to vector

				//reset for this set of elements
				name = newName;
				child_idx = 0;
				attributeMap.clear(); //reset map for next sibling
			} 


			//this vector is used to hold the attributes for each element
			vector<const tinyxml2::XMLAttribute*> elementAttributes;

			const tinyxml2::XMLAttribute *attribute = element->FirstAttribute();
			while(attribute){
				attr_exist = true;
				//attribute exists, add it to the vector
				elementAttributes.push_back(attribute);
				attribute = attribute->Next();
			}

			//attrvector is now populated for this element, add it to the map
			if(!elementAttributes.empty())
				attributeMap[child_idx] = elementAttributes;

			element = element->NextSiblingElement();
			child_idx++;
		}

		//final attribute set handled here (since while loop breaks)
		if (!attributeMap.empty())
			attributeMaps[name] = attributeMap; 

		if(!attr_exist)
			attributeMaps.clear(); //make it empty
		return attributeMaps;
	}

	static bool hasSameNameSib(const tinyxml2::XMLElement *element)
	{
		const char *elementName = element->Value();
		const tinyxml2::XMLElement *siblingElement = element->NextSiblingElement();
		if(siblingElement)
		{
			const char *siblingName = siblingElement->Value();
			return strcmp(elementName,siblingName)==0;
		}else //no siblings at all
			return false; 
	}

    static TethysType getDatatype(string name)
    {
		if (name.compare("char")==0)
			return tySTRING;
		else if (name.compare("double")==0)
			return tyDOUBLE;
		else if (name.compare("int")==0)
			return tyINTEGER;
		else if (name.compare("datetime")==0)
			return tyDATE;

        return tySTRING;
    }


    static const char * getFormatingString(mxClassID classID, const char *className, const char *singleFloatingFormat, const char *doubleFloatingFormat)
    {
        static char errorBuf[512];

        switch(classID)
        {
            case mxDOUBLE_CLASS: return doubleFloatingFormat ? doubleFloatingFormat : "%lg";
            case mxSINGLE_CLASS: return singleFloatingFormat ? singleFloatingFormat : "%g";
            case mxLOGICAL_CLASS:
                switch(sizeof(mxLogical))
                {
                    case sizeof(int):
                        return "%d";
                    case sizeof(char):
                        return "%hhd";
                    case sizeof(short):
                        return "%hd";
                }
            case mxINT8_CLASS: return "%hhd";
            case mxUINT8_CLASS: return "%hhu";
            case mxINT16_CLASS: return "%hd";
            case mxUINT16_CLASS: return "%hu";
            case mxINT32_CLASS: return "%d";
            case mxUINT32_CLASS: return "%u";
            case mxINT64_CLASS: return "%" FMT64 "d";
            case mxUINT64_CLASS: return "%" FMT64 "u";

            default:
                sprintf(errorBuf, "[ERROR: can't get format string for class %s]", className);
                return errorBuf;
        }
    }

    static mwSize * getDimensions(mwSize *ndim, size_t *numel)
    /*
     * Get number of dimensions and size per dimension from "size" attribute in element.
     *
     * Return pointer to an array with the size of each dimension.          
     * Space for dims will be allocated and needs to be freed with mxFree
     * when not needed anymore.
     *
     * 
     * *ndim         : number of dimensions
     *                 will be at least 2 
	 * *numel        : number of elements
	 *
	 * space will be allocated and
	 * ndim=2, numel=1 and size in each dimension equals 1.
	 */
	{
		*ndim = 0;
		*numel = 1;
		mwSize *dimSize = (mwSize *)mxMalloc(2*sizeof(mwSize));


		// if no dimension size is specified return size 1x1
		dimSize[0] = 1;
		dimSize[1] = 1;
		*ndim = 2;


		return dimSize;
	}


    static char * createSizeStr(mwSize ndim, const mwSize *dims)
    /*
     * Create size string
     *
     * Return pointer to string with size numbers        
     * Space for string will be allocated and needs to be freed with mxFree
     * when not needed anymore.
     *
     * ndim        : number of dimensions
     * dims        : size in each dimension
     */{
    #ifdef MX_COMPAT_32
            char *sizeStr = (char *)mxMalloc((ndim*11)*sizeof(char));  // max number of characters for mwSize equals 10 + space
            int pos = 0;
            for(mwSize n=0; n+1<ndim; n++)
            {
                pos += sprintf(sizeStr+pos, "%d ", dims[n]);           
            }
            sprintf(sizeStr+pos, "%d", dims[ndim-1]);   // last size without a space
    #else
            char *sizeStr = (char *)mxMalloc((ndim*16)*sizeof(char));  // max number of characters for mwSize equals 15 + space
            int pos = 0;
            for(mwSize n=0; n+1<ndim; n++)
            {
                pos += sprintf(sizeStr+pos, "%" PR_SIZET "u ", dims[n]);           
            }
            sprintf(sizeStr+pos, "%" PR_SIZET "u", dims[ndim-1]);   // last size without a space
    #endif
            return sizeStr;
    }
    
    
    
    Utils()
    {
        if(instanceCount)
        {
            mexErrMsgIdAndTxt(MSGID_DEVEL, "Utils can be instatiated only once!");
        }
            
        Utils::instanceCount++;
    };
    
    ~Utils()
    {
        /*if(b64Decoder)
        {
            delete b64Decoder;
        }*/
    }
    
    void decode64(istream& istream_in, ostream& ostream_in)
    {
        /*if(!b64Decoder)
        {
            b64Decoder = new base64::decoder();
        }
        b64Decoder->decode(istream_in, ostream_in);
        */
    }
    
private:
    static unsigned instanceCount;
//    base64::decoder *b64Decoder;
};

unsigned Utils::instanceCount = 0;

Utils gUtils;
