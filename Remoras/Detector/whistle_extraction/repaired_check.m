function repaired_check(directory)
% repaired_check(directory)
% An early version of the tonal annotation tool occasionally
% produced tonals where the same sample was repeated twice.
%
% Verify that tonals have been repaired correctly
%
% Usage:  Specify parent directory.  This directory and its children
% are searched for .bin-unrepaired files.  Each file is loaded and compared
% to the .bin file that should have been repaired.  Any problems are 
% reported.

orig = utFindFiles({'*.bin-unrepaired'}, {directory}, 1);
for fidx = 1:length(orig)
    fprintf('%s\n', orig{fidx});
    problems = dtTonalsLoad(orig{fidx});
    fixedfile = strrep(orig{fidx}, '-unrepaired', '');
    fixed = dtTonalsLoad(fixedfile);
    
    if problems.size() ~= fixed.size()
        fprintf('%s does not have the same number of tonals\n', fixedfile);
    else

        pit = problems.iterator();
        fit = fixed.iterator();
        idx = 0;
        
        while pit.hasNext()
            p = pit.next();
            f = fit.next();
            
            ptime = p.get_time();
            pfreq = p.get_freq();
            ftime = f.get_time();
            ffreq = f.get_freq();

            % Repair tonal if needed, removing duplicates
            [t2, tindices] = unique(ptime, 'first');
            if length(ptime) ~= length(t2)
                % repair it
                ptime = t2;
                pfreq = pfreq(tindices);
            end

            if length(ptime) ~= length(ftime)
                fprintf('Length mismatch tonal %d\n', idx);
            else
                badtime = ptime ~= ftime;
                badfreq = pfreq ~= ffreq;
                if sum(badtime) > 0 || sum(badfreq) > 0
                    fprintf('bad time or frequency tonal %d\n', idx);
                    keyboard
                end
            end
            idx = idx + 1;
        end
    end
end
    