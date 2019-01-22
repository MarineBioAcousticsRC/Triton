function index = end(w, k, n)

if k == 1
  index = w.Samples;
elseif k == 2
  index = w.Channels;
else
  error('Bad use of end')
end
