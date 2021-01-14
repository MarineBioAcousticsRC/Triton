function [tf1] = bp_load_TFfile(TFfile)

global REMORA PARAMS

%Get filename if TFfile is not numeric.
if ~isnumeric(TFfile)
    isNum = ~isnan(str2double(TFfile));
    if isNum
        TFfile = str2double(TFfile);
    end
end
if ischar(TFfile) && ~isempty(TFfile)
    fidtf = fopen(TFfile,'r');
    if fidtf ~=-1
        [transferFN,~] = fscanf(fidtf, '%f %f', [2,inf]);
        fclose(fidtf);
    else
        error('Unable to open transfer function file %s',TFfile)
    end
    
    tf1 = interp1(transferFN(1,1:60),transferFN(2,1:60),PARAMS.ltsa.f,'linear','extrap');
%For singular gain
elseif isnumeric(TFfile)
    tf1 = TFfile;
    
%If no transfer function is applied
elseif isempty(TFfile)
    %No tranfer function is applied
else
    error('Provide a transfer function file or a singular gain value')
end