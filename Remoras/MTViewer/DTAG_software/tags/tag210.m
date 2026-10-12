function    CAL = tag210(date)
%
%     CAL = tag210([date])
%     Calibration file for tag210
%     Use date=[yr mon day] in case calibration constants
%     changed over time.
%
%     mark johnson and tom hurst
%     thurst@whoi.edu
%     last modified: 21 May 2006

CAL.TAG = 210 ;

CAL.TREF = 20 ;                     % temperature of calibration
CAL.TCAL = [125 75] ;               % temperature sensor calibration

CAL.PCAL = [-38.5,1092.9,901.2] ;
%CAL.PCAL = [3.6 -88.6 1054.4 905.0] ;    % this may be a better cal (derived from sw05_199a)
                                    % but is only known to be good upto 900m

CAL.PTC = -0.3 ;
CAL.Pi0 = 0.877e-3 ;                        % pressure bridge current
CAL.Pr0 = 130 ;                             % current sensing resistor

CAL.ACAL = [-6.878 2.024 ;
            7.035 -1.692 ;
      	   -6.917 2.003 ] ;

CAL.MCAL = [-103.95	0	;
            101.00	0 ;
            -106.71	0 ] ;

CAL.APC = [0.19e-3 0.17e-3 0.13e-3] ;  % pressure sensitivity on ax,ay,az
CAL.ATC = [0 0 0] ;                    % temperature sensitivity on ax,ay,az
CAL.AXC = [1 0 0 ;                     % cross-axis sensitivity on A
           0 1 0 ;
           -0.065 0 1] ;

CAL.MMBC = [17.9 3.3 -47.9] ;          % mbridge sensitivity on mx,my,mz
CAL.MPC = [0 0 0] ;                    % pressure sensitivity on mx,my,mz
CAL.MXC = [1 -0.058 -0.015 ;           % cross-axis sensitivity on M
           -0.058 1 0 ;
           -0.015 0 1] ;

CAL.VB = [5 5] ;           % battery voltage conversion to volts
CAL.PB = [2.5 2.5] ;       % pb conversion to volts
CAL.PBTREF = 3.36 ;        % pb value in volts at TREF
CAL.MB = [2.5 2.5] ;       % mb conversion to volts
CAL.MBTREF = 2.82 ;        % mb value in volts at TREF
