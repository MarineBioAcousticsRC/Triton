function data = subsref(w, index)

switch index(1).type
 case '()'
  % index.subs{1} indicates samples to retrieve
  % index.subs{2} indicates channels (if present)
  min_sample = min(index(1).subs{1});
  max_sample = max(index(1).subs{1});
  % Read data in the range the user wanted
  data = wavread(w.Filename, [min_sample, max_sample]);

  % Select only the samples user wanted
  if length(index(1).subs) == 1
    index(1).subs{2} = w.CurrentChannel;
  end
  data = data(index(1).subs{1} - (min_sample - 1), index(1).subs{2});

 case '.'
  data = w.(index(1).subs);
 otherwise
  error('unsupported substructure reference')
end
