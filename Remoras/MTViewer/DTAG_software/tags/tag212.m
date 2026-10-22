function    CAL = tag212(date)
%
%     CAL = tag212([date])
%     Calibration file for tag212
%     Use date=[yr mon day] in case calibration constants
%     changed over time.
%
%     mark johnson and tom hurst
%     thurst@whoi.edu
%     last modified: 21 May 2006

CAL.TAG = 212 ;

CAL.TREF = 20 ;                     % temperature of calibration
CAL.TCAL = [125 75] ;               % temperature sensor calibration

CAL.PCAL = [-62.1,1276.4,1067.7-6.3] ;
CAL.PTC = -0.39 ;
CAL.Pi0 = 0.877e-3 ;                        % pressure bridge current
CAL.Pr0 = 130 ;                             % current sensing resistor

CAL.ACAL = [-6.950	1.736;
	         6.994	-1.599;
	         -7.042	1.741 ] ;

CAL.MCAL = [-101.96	0;
	         99.02	0;
	         -104.03  0 ] ;

CAL.APC = [0.12e-3 0.29e-3 -0.16e-3] ;  % pressure sensitivity on ax,ay,az
CAL.ATC = [0 0 0] ;                    % temperature sensitivity on ax,ay,az
CAL.AXC = [1 0 0 ;                     % cross-axis sensitivity on A
           0 1 0 ;
           0 0 1] ;

CAL.MMBC = [20 8.4 -2.8] ;             % mbridge sensitivity on mx,my,mz
CAL.MPC = [0 0 0] ;                    % pressure sensitivity on mx,my,mz
CAL.MXC = [1 -0.035 -0.025 ;           % cross-axis sensitivity on M
           -0.035 1 -0.008 ;
           -0.025 -0.008 1] ;

CAL.VB = [5 5] ;           % battery voltage conversion to volts
CAL.PB = [2.5 2.5] ;       % pb conversion to volts
CAL.PBTREF = 3.36 ;        % pb value in volts at TREF
CAL.MB = [2.5 2.5] ;       % mb conversion to volts
CAL.MBTREF = 2.83 ;        % mb value in volts at TREF

%      a_cal = [-6.878 2.024+0.038;
%                7.106*0.99 -1.692+0.023;
%               -7.131*0.97 2.003-0.035] ;
