%==========================================================================
function WriteTimeLabels(out_fid, saveList, label, ...
    gap, CumTime, RawStart, writeAbsoluteTime);

if nargin < 9
    writeAbsoluteTime = 0;
end

if size(saveList, 1) > 0
    for m = 1:size(saveList, 1)
        callStart = saveList(m, 1) - gap;
        %         callEnd = saveList(m, 2) - gap;
        %fragments = cell(0, 1);
        %         fragmentCount = 1;  % atleast one fragment will be there
        %         contourIdxs = find(tt(:, 1) >= saveList(m,1) & tt(:, 1) <= saveList(m,2));

        offset = saveList(m,:) - gap;
        if writeAbsoluteTime ~= 0
            %abstime(1) = datenum([0 0 0 0 0 saveList(m,1)-(CumTime + gap)]) + CurrentRawStart;
            abstime(1) = datenum([0 0 0 0 0 saveList(m, 1)]) + RawStart;
            %abstime(2) = datenum([0 0 0 0 0 saveList(m,2)-(CumTime + gap)]) + CurrentRawStart;
            abstime(2) = datenum([0 0 0 0 0 saveList(m, 2)]) + RawStart;
        end

        %         %Shyam : a hack
        %         [u_tt, u_tt_i] = unique(tt(contourIdxs, 1));
        %         contourIdxs = contourIdxs(u_tt_i);
        %         % -- end hack

        %         %fragInfo = sprintf('%.6f %.4f', (tt(contourIdxs(1), 1) - callStart), fx(contourIdxs(1)));
        %         fragInfo = sprintf('%.6f %.4f', (tt(contourIdxs(1), 1) - saveList(m, 1)), fx(contourIdxs(1)));
        %         %currentFragment = fx(contourIdxs(1));
        %         for n = contourIdxs(2:end)'
        %             if tt(n, 2) > 0
        %                 %fragments{fragmentCount} = currentFragment;
        %                 fragmentCount = fragmentCount + 1;
        %                 %fragInfo = sprintf('%s\n%.6f', fragInfo, (tt(n, 1) - callStart));
        %                 fragInfo = sprintf('%s\n%.6f', fragInfo, (tt(n, 1) - saveList(m, 1)));
        %                 %currentFragment = [];
        %             end
        %             fragInfo = sprintf('%s %.4f', fragInfo, fx(n));
        %             %currentFragment = [currentFragment, fx(n)];
        %         end
        %fragments{fragmentCount} = currentFragment;

        fprintf(out_fid, '%s %d ', label);
        if writeAbsoluteTime == 0
            fprintf(out_fid, '%.6f %.6f\n', offset(1));
        else
            tmp = datevec(abstime(1));
            fraction(1) = floor((tmp(6) - floor(tmp(6))) * 1000);
            tmp = datevec(abstime(2));
            fraction(2) = floor((tmp(6) - floor(tmp(6))) * 1000);
            fprintf(out_fid, '%s.%d  %s.%d\n', datestr(abstime(1), 31), fraction(1), datestr(abstime(2), 31), fraction(2));
        end
    end
end


