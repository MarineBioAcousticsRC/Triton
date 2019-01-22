
Notes on scoring


Run contour extractor over all files.  Use an extension other than the
one used for ground truth tonal files (.bin by default).  In this
example, we will assume that the user is using .det for "detection"

This can be done manually or as a batch:

     batchdetect('.det');  % Save detections w/ .det extension

     or manually by calling dtTonalsTracking and saving the output
     as "tonals" in this example:

     [directory, basename, ext] = fileparts(filename);
     % Rewrite the variable directory to match the tree structure
     % of filename, but in the directory where results are to be
     % stored.
     % example:  /corpora/whistles/Tt/test1.wav
     % If we want to store everything relative to the current 
     % directory:  
     directory = strrep(directory, '/corpora/whistles', '.');

     dtTonalsSave(fullfile(directory, basename, '.det'), tonals, ...
		     'Binary', true);


% Read in detected files with extension .det
% Compare to ground truth .bin tonals
% Whistles are stored in new fles representing
% false positives, and
% correct detections, ground truth matched/missed
% either compared to the entire corpus, or the SNR criteria
% Note that scoreall.m has a bhaveshonly variable which
% can restrict analysis to the files used in Bhavesh's thesis
results = scoreall('.det')

% Gather& display statistics
dtAnalyzeResults(results);

% Examining the results
%
% Assume that we have a results array.  The tonals themselves are not
% loaded into memory.  Each element of the results array has the
% following elements:
%
% falsePos - Path to tonal file with all false positive detections
% file - Path to source audio file
% falsePosN - # of false positives
% all & snr
%  Two substructures containing information about detections and
%  ground truth.  The snr structure filters results such that
%  they are reported with respect to only the ground truth tonals that 
%  met the selection criteria (duration & SNR).  
%  positives.  Fields:
%   The following fields are paths to tonal files that can be loaded
%   to observe performance:
%     detections - file containing detections matching ground truth tonals
%     gt_match - ground truth tonals that were detected by tonals in
%       the detections file.
%     gt_miss - grond truth tonals that were not detected
%   statistics about detections:
%     detectionsN - # of detections
%     gt_matchN - # of ground truth matches
%     gt_missN - # of ground truth misses
%     Vectors describing each ground truth match
%       covered_s - s of ground truth tonal that were matched
%       length_s - duration of each ground truth tonal
%       excess_s - s by which detection exceeded each ground truth

% Any of the tonals sets can be loaded by specifying the appropriate
%  field and then plotted using either the interactive ground truth
%  labeler dtPlotUIGroundTruth with the tonals as the input, or using
%  dtTonalsPlot.

Example:  Examine false positives
dtPlotUIGroundTruth(results(1).file, ...
   dtTonalsLoad(results(1).falsePos), 0, Inf);

Example:  Plotting ground truth tonals that were missed but
 expected to be matched (they met SNR & duration criteria)
dtTonalsPlot({results(1).file}, dtTonalsLoad(results(1).snr.gt_miss))
