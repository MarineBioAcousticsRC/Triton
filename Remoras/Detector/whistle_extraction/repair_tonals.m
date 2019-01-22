function repair_tonals(directory)
% repair_tonals(directory)
% An early version of the tonal annotation tool occasionally
% produced tonals where the same sample was repeated twice.
% This repairs detection files that have this error.
%
% Usage:  Specify parent directory.  This directory and its children
% are searched for .bin files.  Each file is examined and if necessary
% repaired.  The old .bin file is renamed to .bin-unrepaired
% and a new file will take its place.

bins = utFindFiles({'*.bin'}, {directory}, 1);
Nfiles = 0;
for fidx = 1:length(bins)
    tonal_list = dtTonalsLoad(bins{fidx});
    it = tonal_list.iterator();
    problems = 0;
    N = 0;
    new_list = java.util.LinkedList();
    while it.hasNext()
        N = N + 1;
        tonal = it.next();
        t = tonal.get_time();
        f = tonal.get_freq();
       
        [t2, tindices] = unique(t, 'first');
        if length(t) ~= length(t2)
            problems = problems + 1;  % keep count of problematic tonals
            % repair it
            t = t2;
            f = f(tindices);
            new_tonal = tonals.tonal(t, f);
            new_list.addLast(new_tonal);
        else
            new_list.addLast(tonal);
        end
    end
    
    if problems
        Nfiles = Nfiles + 1;
        fprintf('%d problems in %d tonals file %s\n', problems, N, bins{fidx});
        
        % Rename old tonal detections
        dest = [bins{fidx}, '-unrepaired'];
        %todo:  write mv command
        movefile(bins{fidx}, dest);
        
        % Write out new detections
        dtTonalsSave(bins{fidx}, new_list);
    end
end
fprintf('%d of %d files had problems\n', Nfiles, length(bins));

1;
