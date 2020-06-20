function ltsa_delimiter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ltsa_delimiter.m
%
% Diplays the delimiter between duty cycles in an ltsa in the ltsa window
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS HANDLES

ntBin = length(PARAMS.ltsa.t);  % number of time bins in LTSA display
tbinsz = PARAMS.ltsa.tave / (60*60); % time bin size in [hr]
cx = PARAMS.ltsa.tseg.hr;   % last time bin displayed on LTSA plot [hr]
[rawIndexEnd,tBinEnd] = getIndexBin(cx);    % get raw file index and time bin index for last bin
tBin_dnum = zeros(ntBin,1);     % allocate vector for tBin times
k = 0;  % counter of time bins
for ri = PARAMS.ltsa.plotStartRawIndex:rawIndexEnd % loop over raw file indexes
    if ri == PARAMS.ltsa.plotStartRawIndex
        tbi = PARAMS.ltsa.plotStartBin; % use for first Raw File Index
    else
        tbi = 1;
    end
    if ri == rawIndexEnd
        tbe = tBinEnd;
    else
        tbe = PARAMS.ltsa.nave(ri);  % use for last Raw file index
    end
    for tb = tbi:tbe  % loop over time bins in this Raw File
        k = k+1;
        % time bins in days (add one tBin to have 1st bin at zero
         tBin_dnum(k) = PARAMS.ltsa.dnumStart(ri) + (tb - 0.5) * tbinsz /24;
    end
end
dt = floor(diff(tBin_dnum) * 24 * 60 *60);   % get time difference
I = []; I = find(dt > PARAMS.ltsa.tave);    % find time bins > tave
% plot delimiter lines
yA = [min(PARAMS.ltsa.f),max(PARAMS.ltsa.f)];   % LTSA plot y limits
xoff = tbinsz/2;    % move delimiter to edge of timebin
if ~isempty(I)
    for d = 1:length(I)
        xA = [PARAMS.ltsa.t(I(d))+xoff,PARAMS.ltsa.t(I(d))+xoff];
        % We specify the handle in the drawing command as it is much
        % faster than using axes to change the default plot target
        line(HANDLES.subplt.ltsa, xA,yA,'Color','w','LineWidth',2,'LineStyle','--');
    end
else
%     disp_msg('no LTSA delimiter, data continuous')
end
return


% for the following: huh???  WTF??
% axes(HANDLES.subplt.ltsa)
%
% xlim = get(get(HANDLES.fig.main,'CurrentAxes'),'XLim');
% sec = floor((xlim(2)-xlim(1))/0.0173);
% set = xlim(1);
% v = zeros(1,sec);
% x = zeros(2,sec/2);
% i = 0;
%
% for k=1:sec
%     [rawIndex,tBin] = getIndexBin(set);
%     tbinsz = PARAMS.ltsa.tave / (60*60);
%     ctime_dnum = PARAMS.ltsa.dnumStart(rawIndex) + (tBin - 0.5) * tbinsz /24;
%
%     v(k) = ctime_dnum;
%         if k > 1 && (v(k)- v(k-1)) > .0015
%             i = i+1;
%             x(1,i) = set - 0.0180;
%             x(2,i) = set;
%         end
%     set = set + 0.0180;
%     end
%
%     length = i;
%
%     yA = [min(PARAMS.ltsa.f),max(PARAMS.ltsa.f)];
%
%     for k = 1:length
%     x1A = [x(1,k),x(1,k)];
%     x2A = [x(2,k),x(2,k)];
%     L = (x2A + x1A)/2;
%     line(L,yA,'Color','w','LineWidth',2,'LineStyle','--');
%
% end