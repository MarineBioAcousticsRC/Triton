function    seriallogger(port,speed,fdir)
%
%   seriallogger(port,speed,fdir)
%   log data from a serial port to a text file
%     port is the comm port to log e.g., 'COM1'
%     speed is the baud rate to use e.g., 9600
%     fdir is the (optional) directory path to put the log file
%   If fdir is not given, the file will be saved in the current
%   work directory. The file will be called slogddmmyy.txt
%   where dd, mm and yy and day, month and year in 2 digit format.
%
%   mark johnson, WHOI
%	 majohnson@whoi.edu
%   last modified: April 2008

if nargin<2,
   help seriallogger
   return
end

INTERVAL = 1.0 ;
FSIZE = [500 280] ;     % enough for 20 lines

% find and disable any old serial port and timer instances
v = instrfind('Type','serial','Status','open') ;
if ~isempty(v)
   fclose(v) ;
   delete(v) ;
end

v = timerfind('Running','on') ;
if ~isempty(v)
   stop(v) ;
end

% initialize the serial ports and timers
P.port = port ;
P.speed = speed ;
p = ports('open',P) ;
if p==0, return, end

tt = clock ;
fname = sprintf('%s/slog%02d%02d%02d.txt',fdir,tt(3),tt(2),rem(tt(1),100)) ;
f = fopen(fname,'at') ;

s = sprintf('Connected to "%s"',port) ;
fh = figure ;
set(fh,'MenuBar','none','NumberTitle','off','Name',s,'Resize','off') ;
pp = get(fh,'Position') ;
pp = [pp(1)+pp(3)-FSIZE(1) pp(2)+pp(4)-FSIZE(2) FSIZE(1) FSIZE(2)] ;
set(fh,'Position',pp) ;

h = uicontrol('Style','text','Tag','showport','String','connecting...',...
               'FontSize',8,'HorizontalAlignment','left',...
               'BackgroundColor',[1 1 1]) ;

set(h,'Position',[10 10 FSIZE(1)-20 FSIZE(2)-20]) ;
D.p = p ;
D.f = f ;
D.h = h ;
D.s = {} ;
D.ss = '' ;

timr = timer('TimerFcn',@readport,'Period',1,...
               'ExecutionMode','fixedRate','UserData',D);
start(timr) ;
uiwait
stop(timr) ;
delete(timr) ;
fclose(f) ;
ports('close',p) ;
return


function    readport(obj,eventdata)
%
D = get(obj,'UserData') ;
vs = ports('read',D.p) ;
if ~isempty(vs),
   fwrite(D.f,vs,'char') ;
   s = [D.ss vs];
   k = findstr(s,char(10)) ;
   while ~isempty(k),
      sline = strtok(s(1:k(1)-1)) ;
      s = s(k(1)+1:end) ;
      if length(D.s)<20,
         D.s = {D.s{:},sline} ;
      else
         D.s = {D.s{end+(-19:0)},sline} ;
      end
      k = findstr(s,char(10)) ;
   end
   D.ss = s ;
   set(obj,'UserData',D) ;
   try
      set(D.h,'String',D.s) ;
   catch
   end
end
return
