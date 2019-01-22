function features = WriteFeatures(segList, outdir, name, date)
% features = WriteFeatures(segList, outdir, name, datestr)
%
% Given a set of transformed whistle parameters in segList (e.g. time, log
% freq), and an output directory, write each whistle to a featuren file and
% returns the list of filenames as a cell array.  Whistle names are
% constructed based on a name (e.g. 'Sl_grd'), the time at which the file was
% started, and the whistle number relative to the file.

advance_ms = 20;
mfcFType = '.fea';   % feature file extension

tonalsN = segList.size();
features = cell(1, tonalsN);
% write HTK feature vectors
k = 1;
it = segList.iterator();
while it.hasNext()
    whistle = it.next();
    features{k} = fullfile(outdir, ...
        sprintf('%s_%sW%04d%s', name, datestr(date,  'yymmddTHHMMSS'), ...
        k, mfcFType));
    f = whistle.getThisTonal.get_freq();
    
    % Compute 1st and 2nd differences
    fd1 = diff(f);
    fd2 = diff(fd1);
    f = [.21; f; .21]; 
    % Assemble feature vector with derivatives
    featvec = [f, [.21; fd1(1); fd1; .21], [.21; fd2(1); fd2; fd2(end); .21]];
    spWriteFeatureDataHTK(features{k}, ...
        featvec, advance_ms, 'USER_D_A');
    k=k+1;
end

