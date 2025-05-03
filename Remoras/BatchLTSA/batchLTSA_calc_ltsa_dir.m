function batchLTSA_calc_ltsa_dir(data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate spectral averages and save to ltsa file
%
% called by batchLTSA_mk_ltsa_dir
% copied from A.Allen 1.93.20190212
% adapted to BatchLTSA Remora by S. Fregosi 2021 08 09
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
        data = [data;dz];
    catch
        data = [data,dz'];
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
[ltsa, freq] = pwelch(data, window, noverlap, PARAMS.ltsa.nfft, PARAMS.ltsa.fs);   % pwelch is supported psd'er
ltsa = 10*log10(ltsa); % counts^2/Hz
1;
% write data
fwrite(PARAMS.ltsa.fod, ltsa, 'int8');
end

