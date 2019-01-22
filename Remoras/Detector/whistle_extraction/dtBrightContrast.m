function dtBrightContrast(ImageH, Bright_dB, Contrast_Pct, thresh_dB, colorbarH)
% dtBrightContrast(ImageH, Bright_dB, Contrast_Pct)
% Change the brightness/contrast and threshold of the image.
%
% ImageH - Image handle
% Bright_dB - Brightness
% Contrast_Pct - Contrast
% thresh_dB (optional) - Set all values < threshold to 0

if nargin < 4
    thresh_dB = -Inf;
end

if nargin < 5
    colorbarH = [];
end

minv = Inf;
maxv = -Inf;
for hidx = 1: length(ImageH)
    
    % Get the original structure associated with image
    pwr_brt_cont = get(ImageH(hidx), 'UserData');
    if pwr_brt_cont.bright_dB ~= Bright_dB ||...
            pwr_brt_cont.contrast_Pct ~= Contrast_Pct || ...
            pwr_brt_cont.threshold_dB ~= thresh_dB;
        % Update the color data
        colorData = (Contrast_Pct/100) .* pwr_brt_cont.snr_dB + Bright_dB;
        if thresh_dB > 0
            colorData(pwr_brt_cont.snr_dB < thresh_dB) = 0;
        end
        set(ImageH(hidx), 'CData', colorData);
        % Update the structure associated with image
        pwr_brt_cont.threshold_dB = thresh_dB;
        pwr_brt_cont.bright_dB = Bright_dB;
        pwr_brt_cont.Contrast_Pct = Contrast_Pct;
        set(ImageH(hidx), 'UserData', pwr_brt_cont);
        minv = min(minv, min(min(colorData)));
        maxv = max(maxv, max(max(colorData)));
    end
end

if ~ isempty(colorbarH)
    if maxv - minv < 6
        minv = minv - 3;
        maxv = maxv + 3;
    end
    set(colorbarH, 'YLim', [minv, maxv]);
%     cb = findobj(colorbarH, 'Tag', 'TMW_COLORBAR');
%     set(cb, 'CData',linspace(minv, maxv, 100));
%     set(cb,'YData',[minv, maxv]);
    drawnow update
    1;
end
1;