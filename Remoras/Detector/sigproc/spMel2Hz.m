function Hz = spMel2Hz(Mel)
% Hz = spMel2Hz(Hz)
% Convert Mel to Hertz
% Uses Mel conversion from CMU SphinxIII

Hz = 700 * (10.^(Mel/2595) - 1);
