function prop = get(w, Property)
% prop = get(w, Property)
% Get property of signal
%       'blocks' - number of blocks in file
%       'fs' - sample rate
%       'filename' - name of file
%       'samples' - number of samples
%       'channels' - number of channels
%       'position' - next sample which will be read

error(nargchk(1,2,nargin))

if nargin == 1
  prop = fieldnames(w);
else
  switch Property
   case 'blocks'
    % compute number of blocks of data that will be returned
    prop = 0;
    n = 1;
    while n < w.Samples
      prop = prop+1;
      n = n + w.BlockSamplesAdv;
    end
   case 'channels'
    prop = w.Channels;
   case 'fs'
    prop = w.fs;
   case 'filename'
    prop = w.Filename;
   case 'position'
    prop = w.NextSample;
   case 'samples'
    prop = w.Samples;
    
   otherwise
    error('bad property %s', Property)
  end
end

  
  
