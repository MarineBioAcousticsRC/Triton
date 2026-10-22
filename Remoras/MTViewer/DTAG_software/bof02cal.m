function     [A,M,t,p,mbb] = bof02cal(s,tagrun)

%     [A,M,t,p,mbb] = bof02cal(s,tagrun)
%     Correct accelerometer, magnetometer, temperature and 
%     pressure time series for offset and scale.
%       s is the raw sensor matrix from readsen2b()
%       tagrun is the name of the deployment e.g., 'sw01_200'
%       A is the corrected accelerometer signals, A=[ax,ay,az],
%            The units are g.
%       M is the corrected magnetometer signals, M=[mx,my,mz],
%            The units are Gauss.
%       t is the corrected temperature signal in Celcius.
%       p is the corrected pressure signal in m water depth.
%       mbb is the magnetometer bridge signal.
%
%     Output sampling rate is the same as the input sampling rate.
%     Note that the t and p corrections are based on ad-hoc values
%     and will change as better calibrations are available.
%
%     DTAG V1.2 Script Set
%     mark johnson and patrick miller, WHOI
%     July-August 2001

switch tagrun
    case 'rw02_212b'
      % rw02_212b used tag #10,32kHz samp.Determined tag id empirically:10 fits better than 11
      % No post-tagging cal sheet was done at tag recovery time.
      p_cal = [427 3 0] ;
   	  t_cal = [3800 -63.3] ;
      a_cal = [2261.2-(0.0913)*685.7 685.7;
              1962-(0.0311)*692.6 692.6;
              1887.8-(0.0059)*669.3 669.3] ;
      ax_cal = [0 0 1 0 0;
              -0.035e-3 0 0 1 0;
              -0.24e-3 0 0 0 1] ;
      m_cal = [2087.5-(-0.7471+0.5505)*11.1 11.1;
              2190.4-(-0.7032+0.0754)*10.34 10.34;
              1958.5-(-1.0345-0.2094)*11.79 11.79] ;
      mx_cal = [0.0261 1 0 0;
                0.0487 0 1 0;
                0.0504 0 0 1] ;
  case 'rw02_212g'
    % rw02_212g used tag #10,32kHz samp.Determined tag id empirically:10 fits better than 11.
    % No post-tagging cal sheet was done at tag recovery time.
   	  p_cal = [427 3 0] ;
   	  t_cal = [3800 -63.3] ;
      a_cal = [2261.2-(0.0732)*685.7 685.7;
              1962-(0.0397)*692.6 692.6;
              1887.8-(0.0061)*669.3 669.3] ;
      ax_cal = [0 0 1 0 0;
              -0.035e-3 0 0 1 0;
              -0.24e-3 0 0 0 1] ;
      m_cal = [2087.5-(-5.3058+0.0938)*11.1 11.1;
              2190.4-(5.9713+0.3352)*10.34 10.34;
              1958.5-(-2.5664-0.0550)*11.79 11.79] ;
      mx_cal = [-0.1254 1 0 0;
                0.1457 0 1 0;
                0.0360 0 0 1] ;
  case 'rw02_213b'
      % rw02_213b used tag #11, 32kHz sampling
   	p_cal = [441.5-8.3 1.656 0] ;
   	t_cal = [3800 -63.3] ;
      a_cal = [1935.7 729.9;
              1964.8-5.6 704.9;
              2115.5+41.4 690.7] ;
      ax_cal = [0 -5.6e-3 1 0 0;
              0 -3e-4 0 1 0;
              -4e-4 -3.6e-3 0 0 1] ;
      m_cal = [1807-(.6246*11.55) 11.55;
               2099.5+(.2805*11.06) 11.06;
               2231.1-(3.7636*12.52) 12.52] ;
      mx_cal = [0.03 1 0 -0.02;
               0.03 -0.02 1 -0.02;
               -0.08 0 0 1] ;
      k = 1:31600 ;
  case 'rw02_213g'
      % rw02_213g used tag #11, 32kHz sampling
   	p_cal = [441.5-8.3 1.656 0] ;
   	t_cal = [3800 -63.3] ;
      a_cal = [1935.7 729.9;
              1964.8-5.6 704.9;
              2115.5+41.4 690.7] ;
      ax_cal = [0 -5.6e-3 1 0 0;
              0 -3e-4 0 1 0;
              -4e-4 -3.6e-3 0 0 1] ;
      m_cal = [1805.5-3.8 11.55;
               2098.8+8.5 11.06;
               2231.8-60.7 12.52] ;
      mx_cal = [0.03 1 0 -0.02;
               0.03 -0.02 1 -0.02;
               -0.08 0 0 1] ;
      k = 1:108000 ;
 % case 'rw02_214b'
 case 'rw02_214b'
      % rw02_214b used tag #10?, 32kHz sampling.
      % Determined tag id empirically: 10 fits better than 11.
      % No post-tagging cal sheet was done at tag recovery time.
   	  p_cal = [427 3 0] ;
   	  t_cal = [3800 -63.3] ;
      a_cal = [2261.2-(0.5248)*685.7 685.7;
              1962-(-0.0665)*692.6 692.6;
              1887.8-(-0.3131)*669.3 669.3] ;
      ax_cal = [0 0 1 0 0;
              -0.035e-3 0 0 1 0;
              -0.24e-3 0 0 0 1] ;
      m_cal = [2087.5-(23.8316+1.0415)*11.1 11.1;
              2190.4-(7.4053-0.2332)*10.34 10.34;
              1958.5-(-19.8041-1.0551)*11.79 11.79] ;
      mx_cal = [-0.0045 1 0 0;
                -0.0465 0 1 0;
                -0.0186 0 0 1] ;
      %k = 1:108000 ;
 case 'rw02_219b'
      % rw02_219b used tag #10, 32kHz sampling
   	p_cal = [427 3 0] ;
   	t_cal = [3800 -63.3] ;
      a_cal = [2261.2-(.0872*685.7) 685.7;
              1962-.0686*692.6 692.6;
              1887.8-(-.0252*669.3) 669.3] ;
      ax_cal = [0 0 1 0 0;
              -0.035e-3 0 0 1 0;
              -0.24e-3 0 0 0 1] ;
      m_cal = [2087.5-(-.5235+0.1118)*11.1 11.1;
              2190.4-(-.9259+.0717)*10.34 10.34;
              1958.5-(-.8982+.0973)*11.79 11.79] ;
      mx_cal = [0.0157 1 0 0;
               -0.0048 0 1 0;
               0.0149 0 0 1] ;
       %k=1:17600;
  case 'rw02_220b'
      % rw02_220b used tag #11, 32kHz sampling
      % RW02_220B: !! NOTE THAT A MAGNET WAS ON THE REED SWITCH PRIOR TO POST-TAG CAL.
   	p_cal = [441.5-8.3 1.656 0] ;
   	t_cal = [3800 -63.3] ;
      a_cal = [1935.7-((-0.0335)*729.9) 729.9;
              1964.8-((-0.0020)*704.9) 704.9;
              2115.5-((-0.0619)*690.7) 690.7] ;
      ax_cal = [0 -5.6e-3 1 0 0;
             0 -3e-4 0 1 0;
             -4e-4 -3.6e-3 0 0 1] ;
      m_cal = [1825.8-((1.4453-0.2376)*11.55) 11.55;
               1966.6-((-13.9911-0.1199)*11.06) 11.06;
               2327.2-((9.3030+0.6747)*12.52) 12.52] ;
      mx_cal = [0.0082 1 0 -0.02;
                -0.0438 -0.02 1 -0.02;
                -0.0549 0 0 1] ;
      %k = 1:36000 ;
  case 'rw02_220f'
      % rw02_220f used tag #10, 32kHz sampling
   	p_cal = [427 3 0] ;
   	t_cal = [3800 -63.3] ;
    a_cal = [2261.2-(0.0784)*685.7 685.7;
             1962-(0.0527)*692.6 692.6;
             1887.8-(-0.0128)*669.3 669.3] ;
    ax_cal = [0 0 1 0 0;
              -0.035e-3 0 0 1 0;
              -0.24e-3 0 0 0 1] ;
    m_cal = [2087.5-(0.1540+0.8874)*11.1 11.1;
              2190.4-(-1.0742+0.8984)*10.34 10.34;
              1958.5-(0.7260-1.5950)*11.79 11.79] ;
    mx_cal = [0.0010 1 0 0;
              0.0286 0 1 0;
              0.0366 0 0 1] ;
    k=1:17600;
  case 'rw02_221c'
      % rw02_221c used tag #11, 32kHz sampling
   	p_cal = [441.5-8.3 1.656 0] ;
   	t_cal = [3800 -63.3] ;
      a_cal = [1935.7-((-0.0199)*729.9) 729.9;
              1964.8-((-0.0029)*704.9) 704.9;
              2115.5-((-0.0665)*690.7) 690.7] ;
      ax_cal = [0 -5.6e-3 1 0 0;
             0 -3e-4 0 1 0;
             -4e-4 -3.6e-3 0 0 1] ;
      m_cal = [1798.6-((-2.2214-1.0688)*11.55) 11.55;
               2094.1-((-0.5768-0.7325)*11.06) 11.06;
               2208.9-((0.8776+1.1425)*12.52) 12.52] ;
      mx_cal = [-0.0391 1 0 -0.02;
                -0.0581 -0.02 1 -0.02;
                -0.0717 0 0 1] ;
      %k = 1:36000 ;
  case 'rw02_221d'
      % rw02_221d used tag #10, 32kHz sampling
   	p_cal = [427 3 0] ;
   	t_cal = [3800 -63.3] ;
    a_cal = [2261.2-(0.1005)*685.7 685.7;
             1962-(0.0793)*692.6 692.6;
             1887.8-(0.0524)*669.3 669.3] ;
    ax_cal = [0 0 1 0 0;
              -0.035e-3 0 0 1 0;
              -0.24e-3 0 0 0 1] ;
    m_cal = [2099.3-(0.6046-0.0312)*11.1 11.1;
             2189.4-(-0.7458-0.0377)*10.34 10.34;
             1981.8-(0.8661+0.0769)*11.79 11.79] ;
    mx_cal = [0.0005 1 0 0;
              0.0415 0 1 0;
              -0.0091 0 0 1] ;
    %k=1:17600;
  case 'rw02_222c'
      % rw02_222c used tag #11, 32kHz sampling
   	p_cal = [441.5-8.3 1.656 0] ;
   	t_cal = [3800 -63.3] ;
      a_cal = [1935.7-(-.0196*729.9) 729.9;
              1964.8-(-.0276*704.9) 704.9;
              2115.5-(-.0506*690.7) 690.7] ;
      ax_cal = [0 -5.6e-3 1 0 0;
             0 -3e-4 0 1 0;
             -4e-4 -3.6e-3 0 0 1] ;
       
      m_cal = [1798.6-((-.8271+.2069)*11.55) 11.55;
               2094.1-((-1.1643-.4155)*11.06) 11.06;
               2208.9-((1.0393-.2576)*12.52) 12.52] ;
      mx_cal = [.1156 1 0 -0.02;
               .0431 -0.02 1 -0.02;
               -.1347 0 0 1] ;
      k = 1:36000 ;
  case 'rw02_229d'
      % rw02_229d used tag #11, 32kHz sampling. No completed post-tagging cal sheet.
   	p_cal = [441.5-8.3 1.656 0] ;
   	t_cal = [3800 -63.3] ;
      a_cal = [1935.7-(-0.0075)*729.9 729.9;
               1964.8-(-0.0091)*704.9 704.9;
               2115.5-(-0.0199)*690.7 690.7] ;
      ax_cal = [0    -5.6e-3 1 0 0;
                0    -3e-4   0 1 0;
               -4e-4 -3.6e-3 0 0 1] ;
       
      m_cal = [1798.6-((0)*11.55) 11.55;
               2094.1-((0)*11.06) 11.06;
               2208.9-((0)*12.52) 12.52] ;
      mx_cal = [0 1 0 -0.02;
                0 -0.02 1 -0.02;
                0 0 0 1] ;
      %k = 1:36000 ;
  case 'rw02_229e'
	% rw02_229e used tag #5, 16kHz sampling
    % accel scale&offset, mag scale values from rw01_241, rw01_227b (mag scale commented out).
    p_cal = [449 1.47 0] ;
	t_cal = [3800 -63.3] ;
	a_cal = [2044.0-(-0.0212+0.0055+0.0036-0.0153)*700.5 700.5;
		     2028.7-(0.166 +0.0055-0.0541+0.3933)*677.7 677.7;
		     1902.0-(-0.0136+0.0117+0.0459-0.0417)*682.0 682.0] ;
	ax_cal = [-0.0003 -0.0004 1 0 0;                % -0.0005 0 1 0 0
		       0.0012  0.0045 0 1 -0.345            %  0.0010 0 0 1 0
		      -0.0002 -0.0039 0 0 1] ;              %  0.0002 0 0 0 1
	m_cal = [2415.4+(-2.7431+0.2293)*8.21 8.21;                   % 8.62
		     1921.4+(2.7352-0.9232)*9.67 9.67;                   % 10.15
		     2044.2+(2.6053+3.1513)*11.226 11.226] ;             % 11.787
  	mx_cal = [-0.1666 1 0 0.0045;
              -0.0378 0 1 0;
               0.0246 0 0 1] ;
  case 'rw02_232b'
    disp('WARNING: rw02_232b tag frame not complete');
    % rw02_232b used tag #5, 16kHz sampling
    % accel scale&offset, mag scale values from rw01_241, rw01_227b (mag scale commented out).
    p_cal = [449 1.47 0] ;
	t_cal = [3800 -63.3] ;
	a_cal = [2044.0-(0)*700.5 700.5;
		     2028.7-(0)*677.7 677.7;
		     1902.0-(0)*682.0 682.0] ;
	ax_cal = [ 0.0000  0.000 1 0 0;                % -0.0005 0 1 0 0
		      -0.000 -0.0 0 1 0;                %  0.0010 0 0 1 0
		      -0.000 -0.000 0 0 1] ;             %  0.0002 0 0 0 1
	m_cal = [2415.4-(0)*8.21 8.21;                   % 8.62
		     1921.4-(0)*9.67 9.67;                   % 10.15
		     2044.2-(0)*11.226 11.226] ;             % 11.787
  	mx_cal = [-0.0 1 0 0;
              -0.0 0 1 0;
              -0.00 0 0 1] ;      
  case 'rw02_232d'
      % rw02_232d used tag #11, 32kHz sampling
   	p_cal = [441.5-8.3 1.656 0] ;
   	t_cal = [3800 -63.3] ;
      a_cal = [1935.7-(0.1193-0.0298-0.0480)*729.9 729.9;
               1964.8-(0.0244+0.0084-0.0017)*704.9 704.9;
               2115.5-(-0.0191+0.0351+0.0090)*690.7 690.7] ;
      ax_cal = [ 0.0003 -0.0031 1 0 0;
                -0.0001 -0.0002 0 1 0;
                -0.0002  0.0010 0 0 1] ;
       
      m_cal = [1812.1-((-0.4176+0.2399)*11.55) 11.55;
               2091.1-((-1.1384+0.4359)*11.06) 11.06;
               2256.0-((4.5390-0.0239)*12.52) 12.52] ;
      mx_cal = [0.0545 1 0 -0.02;
                0.0069 -0.02 1 -0.02;
                -0.1218 0 0 1] ;
      k = 1:8.5e4;
  case 'rw02_233a'
      % rw02_233a used tag #11, 32kHz sampling
   	p_cal = [441.5-8.3 1.656 0] ;
   	t_cal = [3800 -63.3] ;
      a_cal = [1935.7-(0.1193-0.0298-0.0480)*729.9 729.9;
               1964.8-(0.0244+0.0084-0.0017)*704.9 704.9;
               2115.5-(-0.0191+0.0351+0.0090)*690.7 690.7] ;
      ax_cal = [ 0.0003 -0.0031 1 0 0;
                -0.0001 -0.0002 0 1 0;
                -0.0002  0.0010 0 0 1] ;
       
      m_cal = [1811.0-((-0.5039+0.0819+0.0000+0.1492)*11.55) 11.55;
               2092.0-((-1.0462+0.0718+0.0016+0.3530)*11.06) 11.06;
               2250.4-((4.0917-0.0000+0.0000-0.0236)*12.52) 12.52] ;
      mx_cal = [ 0.0545 1 0 -0.02;
                 0.0069 -0.02 1 -0.02;
                -0.1219 0 0 1] ;
   case 'rw02_233c'
       disp('WARNING: rw02_233c tag frame not complete');
   case 'rw02_233i'
       disp('WARNING: rw02_233i tag frame not complete');
   case 'rw02_236b'
      % rw02_236b used tag #11, 32kHz sampling
   	  p_cal = [441.5-8.3 1.656 0] ;
   	  t_cal = [3800 -63.3] ;
      a_cal = [1935.7-(0.0888-0.0560-0.0366)*729.9 729.9;
               1964.8-(0.0287-0.0187+0.0127)*704.9 704.9;
               2115.5-(-0.0158+0.0337-0.0051)*690.7 690.7] ;
      ax_cal = [ 0.0006 -0.0024 1 0 0;
                 0.0002  0.0013 0 1 0;
                -0.0003  0.0000 0 0 1] ;
      m_cal = [1834.8-(-0.8957+1.0660)*11.55 11.55;
               2097.8-(-0.2220-1.6685)*11.06 11.06;
               2237.9-(1.9202+2.2816)*12.52 12.52] ;
      mx_cal = [-0.0032 1 0 -0.02;
                -0.0159 -0.02 1 -0.02;
                -0.1083 0 0 1] ;
  case 'rw02_236c'
      % rw02_236c used tag #11, 32kHz sampling
   	  p_cal = [441.5-8.3 1.656 0] ;
   	  t_cal = [3800 -63.3] ;
      a_cal = [1935.7-(0.0929-0.0160-0.0148)*729.9 729.9;
               1964.8-(0.0032+0.0066+0.0218)*704.9 704.9;
               2115.5-(-0.0109+0.0262+0.0169)*690.7 690.7] ;
      ax_cal = [ 0.0003 -0.0007 1 0 0;
                 0.0000  0.0015 0 1 0;
                -0.0003  0.0012 0 0 1] ;
      m_cal = [1834.8-(-0.0643-0.0474)*11.55 11.55;
               2097.8-(-0.6254-0.1596)*11.06 11.06;
               2237.9-(2.8311+1.0878)*12.52 12.52] ;
      mx_cal = [-0.0056 1 0 -0.02;
                 0.0186 -0.02 1 -0.02;
                -0.1999 0 0 1] ;
   case 'test11'
      % test11 used tag #11, 32kHz sampling
   	p_cal = [441.5-8.3 1.656 0] ;
   	t_cal = [3800 -63.3] ;
      a_cal = [1935.7-(0.0574)*729.9 729.9;
               1964.8-(0.0100)*704.9 704.9;
               2115.5-(0.0118)*690.7 690.7] ;
      ax_cal = [ 0  0 1 0 0;
                 0  0 0 1 0;
                 0  0 0 0 1] ;
       
      m_cal = [1812.1-((0)*11.55) 11.55;
               2096.6-((0)*11.06) 11.06;
               2250.5-((0)*12.52) 12.52] ;
      mx_cal = [ 0 1 0 -0.02;
                 0 -0.02 1 -0.02;
                 0 0 0 1] ;
otherwise
      fprintf('Unknown experiment - supported experiments are:\n') ;
      fprintf('  rw02_213g\n') ;
      A = []; t = []; p = [] ;
      return ;
end

if exist('k') ~= 1
   k = 1:length(s) ;
end

toffs = 27 ;		% temperature of cal set

% clean up temperature and pressure

h = fir1(60,0.2);   % low-pass filter

fprintf('Correcting temperature...\n') ;
t = filtfilt(h,[1 0],(s(:,10)-t_cal(1))/t_cal(2)) ;

fprintf('Correcting pressure...\n') ;
p = filtfilt(h,[1 0],(s(:,11)-p_cal(1))/p_cal(2)) ;

fprintf('Magnetometer bridge...\n') ;
mbb = (filtfilt(h,[1 0],s(:,14)-mean(s(:,14)))) ;
% calibrate accelerometers for pressure and z-cross-term effects

fprintf('Computing accelerations...\n') ;
%ax = ((s(:,3))-a_cal(1,1))/a_cal(1,2) + p*a_cal(1,3) + a_cal(1,4)*(s(:,5)-1958.5)/681.5;
%ay = ((s(:,4))-a_cal(2,1))/a_cal(2,2) + p*a_cal(2,3) + a_cal(2,4)*(s(:,5)-1958.5)/681.5;
%az = ((s(:,5))-a_cal(3,1))/a_cal(3,2) + p*a_cal(3,3) + a_cal(3,4)*(s(:,5)-1958.5)/681.5;
ax = ((s(:,3))-a_cal(1,1))/a_cal(1,2) ;
ay = ((s(:,4))-a_cal(2,1))/a_cal(2,2) ;
az = ((s(:,5))-a_cal(3,1))/a_cal(3,2) ;
A = [p t-toffs ax ay az]*ax_cal' ;

% 1st value is often bad - replace

A(1,:) = A(2,:) ;

% report on trustworthiness of accelerometer measurements

v = sqrt(decdc(A(k,:),4).^2*[1;1;1]) ;
fprintf('Mean Accelerometer Magnitude: %4.2f g, standard deviation: %4.3f g\n',...
   mean(v), std(v)) ;

% calibrate magnetometers

fprintf('Computing magnetic field signals...\n') ;
mx = ((s(:,7)-m_cal(1,1))/m_cal(1,2)) ; %removed dec4
my = ((s(:,8)-m_cal(2,1))/m_cal(2,2)) ; %removed dec4
mz = ((s(:,9)-m_cal(3,1))/m_cal(3,2)) ; %removed dec4

% remove cross-terms and fix axes

fs = 32e3/680/8 ;
M = [mbb mx my mz]*mx_cal' ;

M=[-M(:,2) -M(:,1) -M(:,3)] ;  % corrects for magnetometer placement in tag (right hand rule) & intensity scale for Belize

% 1st value is often bad - replace

M(1,:) = M(2,:) ;

% report on trustworthiness of magnetometer measurements

v = sqrt(M(k,:).^2*[1;1;1]) ;
mi = mean(v) ;
fprintf('Mean Magnetic Field Intensity: %4.2f uT, standard deviation: %4.2f uT\n',...
   mean(v), std(v)) ;

v = 180/pi*real(acos(sum(A(k,:)'.*M(k,:)')'/mi))-90 ;
fprintf('Mean Magnetic Field Inclination: %4.2f\260, standard deviation: %4.2f\260\n',...
   mean(v), std(v)) ;
