#pragma once

class ExportOptions
{
public:
    char *doubleFloatingFormat; // if NULL use default "%lg"
    char *singleFloatingFormat; // if NULL use default "%g"
    bool storeSize;
    bool storeClass;
    bool storeIndexes;
    bool encodeBase64; // binary data encoded in base64, floating formats ignored

    ExportOptions(const mxArray *options_MA):
        // default option values
        singleFloatingFormat(NULL),   // use default in coversion function
        doubleFloatingFormat(NULL),   // use default in coversion function
        storeSize(true),
        storeClass(true), 
        storeIndexes(true),
        encodeBase64(false)/*,
        b64Encoder(NULL)*/
    {
        // mexPrintf("options_MA = %p\n", options_MA);
            
        if(!options_MA)
            return; // no options parameter given, using defaults
            
        if(mxIsChar(options_MA))
        {
            char * attribSwitch = mxArrayToString(options_MA);
            if(!strcmp(attribSwitch,"off"))
            {
                storeClass   = false;
                storeSize    = false;
                storeIndexes = false;
                encodeBase64 = false;
            }
            else if(!strcmp(attribSwitch,"on"))
            {
                // default
            }
            else
                mexErrMsgIdAndTxt(MSGID_INPUT, "options string must be 'on' or 'off'\n");

            mxFree(attribSwitch);
        }    
        else if(mxIsStruct(options_MA))
        {   
            mxArray *field = mxGetField(options_MA, 0, "fp_format_single");
            if(field)
            {
                if(!mxIsChar(field))
                {
                    mexErrMsgIdAndTxt(MSGID_INPUT, "option fp_format_single must be char string!\n");
                }
                singleFloatingFormat = mxArrayToString(field);
            }

            field = mxGetField(options_MA, 0, "fp_format_double");
            if(field)
            {
                if(!mxIsChar(field))
                {
                    mexErrMsgIdAndTxt(MSGID_INPUT, "option fp_format_double must be char string!\n");
                }
                doubleFloatingFormat = mxArrayToString(field);
            }

            field = mxGetField(options_MA, 0, "store_class");
            if(field)
            {
                if(mxIsLogical(field))
                    storeClass = mxIsLogicalScalarTrue(field);
                else
                {
                    if(!mxIsNumeric(field))
                        mexErrMsgIdAndTxt(MSGID_INPUT, "option store_class must be logical or numeric!\n");
                    storeClass = fabs(mxGetScalar(field)) > 1e-6;
                }
            }

            field = mxGetField(options_MA, 0, "store_size");
            if(field)
            {
                if(mxIsLogical(field))
                    storeSize = mxIsLogicalScalarTrue(field);
                else
                {
                    if(!mxIsNumeric(field))
                        mexErrMsgIdAndTxt(MSGID_INPUT, "option store_size must be logical or numeric!\n");
                    storeSize = fabs(mxGetScalar(field)) > 1e-6;
                }
            }

            field = mxGetField(options_MA, 0, "store_indexes");
            if(field)
            {
                if(mxIsLogical(field))
                    storeIndexes = mxIsLogicalScalarTrue(field);
                else
                {
                    if(!mxIsNumeric(field))
                        mexErrMsgIdAndTxt(MSGID_INPUT, "option store_indexes must be logical or numeric!\n");
                    storeIndexes = fabs(mxGetScalar(field)) > 1e-6;
                }
            }
            
            /*field = mxGetField(options_MA, 0, "base64");
            
            // mexPrintf("options_MA isStruct!\n");
            
            if(field)
            {
                if(mxIsLogical(field))
                    encodeBase64 = mxIsLogicalScalarTrue(field);
                else
                {
                    if(!mxIsNumeric(field))
                        mexErrMsgIdAndTxt(MSGID_INPUT, "option base64 must be logical or numeric!\n");
                    encodeBase64 = true;
                }
            }
            else
            {
                // mexPrintf("no base64 parameter\n\n\n");
            }*/
        }
        else
        {
            mexErrMsgIdAndTxt(MSGID_INPUT, "options parameter must be a struct or string\n");
        }
        
        /*if(encodeBase64 && !(storeSize && storeClass) )
        {
            mexErrMsgIdAndTxt(MSGID_INPUT, "options parameter base64 require store_class and store_size\n");
            b64Encoder = new base64::encoder();
        }*/
    }
    
    ~ExportOptions()
    {
        if(singleFloatingFormat)
            mxFree(singleFloatingFormat);
        if(doubleFloatingFormat)
            mxFree(doubleFloatingFormat);
        /*if(b64Encoder)
            delete b64Encoder;*/
    }

/*    void encode64(istream& istream_in, ostream& ostream_in)
    {
        b64Encoder->encode(istream_in, ostream_in);
    }
private:
    base64::encoder *b64Encoder;*/
};
