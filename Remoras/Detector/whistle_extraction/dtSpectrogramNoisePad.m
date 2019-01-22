function [pad_s, pad_frames] = dtSpectrogramNoisePad(default_s, Advance_s, Method, varargin)
% [pad_s, pad_frames] = dtSpectrogramNoisePad(default_s, Method, OptArgs)
% Given the noise compensation technique, determine appropriate amount
% of padding needed to handle cornder cases.
% OptArgs are as in dtSpectrogramNoiseComp

switch(Method)
    case 'median'
        if numel(varargin) > 0
            region = varargin{1};  % median filter argument
            if numel(varargin) > 1
                avg_s = varargin{2};  % moving average size
            else
                avg_s = 0;  % default no moving average
            end
        else
            % default median filter, must match dtSpectrogramNoiseComp    
            region = [3 3];
            avg_s = 0;
        end
        
        pad_s = max(avg_s/2, (region(1)-1)/2*Advance_s);
        
    case 'MA'
        % add half of averaging interval on either side
        interval_s = varargin{1};
        pad_s = interval_s / 2;
        
    otherwise
        % pad one frame on each side
        pad_s = default_s;
end
pad_frames = ceil(pad_s / Advance_s);
