function batchLTSA_calc_ltsa_dir(data)
% BATCHLTSA_CALC_LTSA_DIR   Calculate and write spectral averages to LTSA file
%
%   Syntax:
%       BATCHLTSA_CALC_LTSA_DIR(data)
%
%   Description:
%       Compute the spectral averages for an input 'slice' of data and
%       write to an opened LTSA file. This is called by
%       BATCHLTSA_MK_LTSA_DIR. 
%
%       This was modified from Ann Allen 1.93.20190212. 
%
%   Inputs:
%       calls global PARAMS
%       data   [double] acoustic data samples for a given time average to
%              be used to compute the spectral average
%
%	Outputs:
%       updates global PARAMS, write to .ltsa file
%
%   Examples:
%
%   See also BATCHLTSA_MK_LTSA_DIR
%
%   Authors:
%       S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%   Updated:   04 May 2025
%
%   Created with MATLAB ver.: 24.2.0.2740171 (R2024b) Update 1
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global PARAMS

window = PARAMS.ltsa.window;
noverlap = PARAMS.ltsa.noverlap;

% if not enough data samples, pad with zeroes
%             if nsamp < PARAMS.ltsa.nfft
dsz = length(data);
% for debugging
%             disp(['File# Raw# Ave# DataSize: ',num2str(k),'  ',num2str(r),'  ',num2str(n),'  ',num2str(dsz)])
if dsz < PARAMS.ltsa.nfft
    %                 dz = zeros(PARAMS.ltsa.nfft-nsamp,1);
    dz = zeros(PARAMS.ltsa.nfft-dsz,1);
    try
        data = [data; dz];
    catch
        data = [data, dz'];
    end
    
    if ~isfield(PARAMS.ltsa, 'multidir')
        k = PARAMS.ltsa.currxwav;
        r = PARAMS.ltsa.rfNum;
        n = PARAMS.ltsa.currNave;
        disp_msg(['File# Raw# Ave# DataSize: ',num2str(k),'  ',num2str(r),'  ',num2str(n),'  ',num2str(dsz)])
        %                 disp_msg('Paused ... press any key to continue')
        % pause
    end
end

% disp_msg(['File# Raw# Ave# DataSize: ',num2str(k),'  ',num2str(r),'  ',num2str(n),'  ',num2str(dsz)])

% calculate spectra
[ltsa, ~] = pwelch(data, window, noverlap, PARAMS.ltsa.nfft, PARAMS.ltsa.fs);   % pwelch is supported psd'er
ltsa = 10*log10(ltsa); % counts^2/Hz
1;

% write data
fwrite(PARAMS.ltsa.fod, ltsa, 'int8');

end

