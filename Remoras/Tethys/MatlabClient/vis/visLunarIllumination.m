function [BarH, presence_d, presence_m] = visLunarIllumination(illu, varargin)
% Parses an illumination query return and plots it on the given figure
% plot.
% Required arguments
%   illu: n x 2 cell array of datetime values in the first column, and
%   illumination percentages in the second column.
% Optional arguments
%   UTCOffset: integer of the offset from GMT
%   cGrad: color gradient of variable size

% Defaults
cGrad = [[1.0000, 0.6000, 0.2000]
 [1.0000, 0.5968, 0.1968]
 [1.0000, 0.5937, 0.1937]
 [1.0000, 0.5905, 0.1905]
 [1.0000, 0.5873, 0.1873]
 [1.0000, 0.5841, 0.1841]
 [1.0000, 0.5810, 0.1810]
 [1.0000, 0.5778, 0.1778]
 [1.0000, 0.5746, 0.1746]
 [1.0000, 0.5714, 0.1714]
 [1.0000, 0.5683, 0.1683]
 [1.0000, 0.5651, 0.1651]
 [1.0000, 0.5619, 0.1619]
 [1.0000, 0.5587, 0.1587]
 [1.0000, 0.5556, 0.1556]
 [1.0000, 0.5524, 0.1524]
 [1.0000, 0.5492, 0.1492]
 [1.0000, 0.5460, 0.1460]
 [1.0000, 0.5429, 0.1429]
 [1.0000, 0.5397, 0.1397]
 [1.0000, 0.5365, 0.1365]
 [1.0000, 0.5333, 0.1333]
 [1.0000, 0.5302, 0.1302]
 [1.0000, 0.5270, 0.1270]
 [1.0000, 0.5238, 0.1238]
 [1.0000, 0.5206, 0.1206]
 [1.0000, 0.5175, 0.1175]
 [1.0000, 0.5143, 0.1143]
 [1.0000, 0.5111, 0.1111]
 [1.0000, 0.5079, 0.1079]
 [1.0000, 0.5048, 0.1048]
 [1.0000, 0.5016, 0.1016]
 [1.0000, 0.4984, 0.0984]
 [1.0000, 0.4952, 0.0952]
 [1.0000, 0.4921, 0.0921]
 [1.0000, 0.4889, 0.0889]
 [1.0000, 0.4857, 0.0857]
 [1.0000, 0.4825, 0.0825]
 [1.0000, 0.4794, 0.0794]
 [1.0000, 0.4762, 0.0762]
 [1.0000, 0.4730, 0.0730]
 [1.0000, 0.4698, 0.0698]
 [1.0000, 0.4667, 0.0667]
 [1.0000, 0.4635, 0.0635]
 [1.0000, 0.4603, 0.0603]
 [1.0000, 0.4571, 0.0571]
 [1.0000, 0.4540, 0.0540]
 [1.0000, 0.4508, 0.0508]
 [1.0000, 0.4476, 0.0476]
 [1.0000, 0.4444, 0.0444]
 [1.0000, 0.4413, 0.0413]
 [1.0000, 0.4381, 0.0381]
 [1.0000, 0.4349, 0.0349]
 [1.0000, 0.4317, 0.0317]
 [1.0000, 0.4286, 0.0286]
 [1.0000, 0.4254, 0.0254]
 [1.0000, 0.4222, 0.0222]
 [1.0000, 0.4190, 0.0190]
 [1.0000, 0.4159, 0.0159]
 [1.0000, 0.4127, 0.0127]
 [1.0000, 0.4095, 0.0095]
 [1.0000, 0.4063, 0.0063]
 [1.0000, 0.4032, 0.0032]
 [1.0000, 0.4000, 0]];
UTCOffset = 0;

% Get varargin
vidx = 1;
while vidx < length(varargin)
    switch varargin{vidx}
        case 'UTCOffset'
            UTCOffset = varargin{vidx+1}; vidx=vidx+2;
            if ~isscalar(UTCOffset)
                error('UTCOffset must be scalar')
            end
        case 'cGrad'
            cGrad = varargin{vidx+1}; vidx=vidx+2;
        otherwise
            error('Bad argument %s', varargin{vidx+1});
    end
end

    [sizeGrad, dontcare] = size(cGrad);

    % Taken from dbDateToOffset. Don't want to merge noncontiguous
    % segments
    serdate = illu(:,1);  % pull out timestamp
    if isempty(serdate)  % empty input
        day = [];
        m = [];
        return
    end
    % shift to local time (if UTCOffset ~= 0)
    serdate = serdate + datenum(0, 0, 0, UTCOffset, 0, 0); 
    resolution_m = 30;

    resolution_d = resolution_m / (24 * 60);

    % offset to previous day
    onems_d = .001 / (24*3600);  % 1 ms in days

    % seperate into days and partial days
    day = floor(serdate);
    m = serdate - day;
    m = [m(:,1), m(:,1)+resolution_d];  % build span
    
    % Some spans may cross a 24 h boundary.  These need to be split
    crossDayP = find(m(:,2) > 1);
    
    presence_d = day;
    presence_m = m;
    
    lunarH = zeros(size(illu, 1) + sum(crossDayP), 1);
    
    % Draw rectangles
    axH = gca;
    illu_idx = 1;
    patch_idx = 0;
    for row = illu'
        BarH(1) = hggroup;
        set(BarH(1), 'Parent', axH);
        
        x = presence_m(illu_idx, 1);
        xt = min(presence_m(illu_idx, 2), 1);
        y = presence_d(illu_idx);
        
        patch_idx = patch_idx + 1;
        
        alpha = row(2)/100;
        alpha = .1 + alpha*.3;
        
        lunarH(patch_idx) = patch([x; xt; xt; x], ...
            [y; y; y+1; y+1], cGrad(floor(row(2) * sizeGrad / 101) + 1,:), ...
            'LineStyle', 'none', 'FaceAlpha', alpha);
        info.illu = row(2);
        set(lunarH(patch_idx), 'UserData', info, ...
            'ButtonDownFcn', @dbLunarIlluminationCB);
        
        if presence_m(illu_idx, 2) > 1
            % Current patch wraps past midnight, plot on next day
            x = 0;
            xt = presence_m(illu_idx, 2) - 1;
            patch_idx = patch_idx + 1;
            lunarH(patch_idx) = patch([x; xt; xt; x], ...
                [y+1; y+1; y+2; y+2], cGrad(floor(row(2) * sizeGrad/101)+1,:), ...
                'LineStyle', 'none', 'FaceAlpha', alpha);
            set(lunarH(patch_idx), 'UserData', info, ...
                'ButtonDownFcn', @dbLunarIlluminationCB);
        end
        illu_idx = illu_idx + 1;
            
                
    end
end