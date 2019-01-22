 dir = '.';
n = 3;
switch n
  case 1
   file = ['092007/melon-headed_whales/palmyra092007FS192-071003-' ...
           '234000.wav'];
   offset = 30.2+[.2 2];
   case 2
    file = '092007/melon-headed_whales/palmyra092007FS192-071004-024000.wav';
    offset = 7*60+[29.5 31.5];
 case 3
  file = 'palmyra092007FS192-071011-230000.wav';
  offset = 8*60+[30.5 31.5]; % we are using only one second data ( 8*60+30.5 (510.5 sec) --- 8*60+31.5(511.5 sec) )
end

[size, fs] = wavread(fullfile(dir, file), 'size');
[pcm, fs] = wavread(fullfile(dir, file), round(offset*fs));
