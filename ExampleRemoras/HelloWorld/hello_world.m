function hello_world(src, ev)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This is the callback for the ui function.  Input arguments are: 
%	src - handle calling the function
%	ev - event data 
% These are the basic callback input arguments, and event data can be empty 
% if the callback functions without it.
% See http://www.mathworks.com/help/matlab/creating_plots/function-handle-callbacks.html
% for more information on callbacks.
%
% This callback creates a new formatted figure, reads the humpback.wav file 
% included in the Triton folder, creates a spectrogram, and overlays text. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global REMORA PARAMS

% Make a new window and give it a handle in the global HANDLES struct
REMORA.hello_world.fig = figure('NumberTitle', 'off',...
  'Name', 'Hello World',...
  'Units', 'normalized',...
  'Visible', 'on',...
  'MenuBar', 'none',...
  'Position', [.3 .3 .3 .3],...
  'Color', [.75 .875 1]);

% get full path for humpback.wav, it should always be in the triton folder
% tritonDir = fileparts(which('triton'));
humpback_wav = fullfile(PARAMS.path.Extras,'humpback.wav');
if ~exist(humpback_wav,'file')
  disp_msg(sprintf('%s is missing, can''t load any sample data!', humpback_wav));
  text(0.05,0.5,sprintf('%s is missing', humpback_wav))
  text(0.05,0.4,sprintf('can''t load any sample data!'))
else
  [ data, fs ] = audioread(humpback_wav);
end

% make spectrogram

nfft = fs/10;
overlap = 95;
[ S,F, T, P  ] = spectrogram(data, hanning(nfft), overlap, nfft, fs);
sec = T(end);
upper_lim = find(F==2e3); % only plot up to 2 KHz
br = 90;
ctrst = 1.00;
pwr = ctrst.* 10*log10(P(1:upper_lim,:)) + br;
% surf(T,F(1:upper_lim),pwr,'edgecolor','none');
image(T,F(1:upper_lim),pwr);
axis xy
axis tight, view(0,90);
xlabel('Time (s)'); 
ylabel('Frequency (Hz)'); 
title(sprintf('Humpback.wav nfft = %d, overlap = %d', nfft,overlap));

% plot some text on there!

x = [ 12/sec, 10/sec ]; 
y = [ .06, .19 ];
annotation('textarrow',x,y,'String','Look at the Humpback calls!',...
    'FontWeight','bold');



