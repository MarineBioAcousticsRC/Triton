
% 36-length df=2
H = round(32768*fir1(35,0.9*1/2)) ;

% 42-length df=3
H = round(32768*fir1(41,0.9*1/3)) ;

% 46-length df=4
H = round(32768*fir1(45,0.9*1/4)) ;

% 36-length df=5
H = round(32768*fir1(35,0.9*1/5)) ;

% 48-length df=6
H = round(32768*fir1(48,0.9*1/6)) ;

% 60-length df=10
H = round(32768*fir1(59,0.9*1/10)) ;

fprintf('%d,',H) ;
fprintf('\n') ;
