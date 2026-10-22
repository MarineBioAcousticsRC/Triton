function    CAL = tag207(date)
%
%     CAL = tag207([date])
%     Calibration file for tag207
%     Use date=[yr mon day] in case calibration constants
%     changed over time.
%
%     mark johnson and tom hurst
%     thurst@whoi.edu
%     last modified: 31 October 2006

CAL.TAG = 207 ;

CAL.TREF = 20 ;                     % temperature of calibration
CAL.TCAL = [125 75] ;               % temperature sensor calibration

CAL.PCAL = [0,1311.6,1180.7] ;
CAL.PTC = 0 ;
CAL.Pi0 = 0.877e-3 ;                        % pressure bridge current
CAL.Pr0 = 130 ;                             % current sensing resistor

CAL.ACAL = [-6.902 1.533 ;
            7.100 -1.749 ;
      	   -6.926 1.693 ] ;

CAL.MCAL = [-104.56	0	;
            98.61	0 ;
            -99.66	0 ] ;

CAL.APC = [0 0 0] ;  % pressure sensitivity on ax,ay,az
CAL.ATC = [0 0 0] ;                    % temperature sensitivity on ax,ay,az
CAL.AXC = [1 0 0 ;                     % cross-axis sensitivity on A
           0 1 0 ;
           0 0 1] ;

CAL.MMBC = [0 0 0] ;          % mbridge sensitivity on mx,my,mz
CAL.MPC = [0 0 0] ;                    % pressure sensitivity on mx,my,mz
CAL.MXC = [1 0 0 ;           % cross-axis sensitivity on M
           0 1 0 ;
           0 0 1] ;

CAL.VB = [5 5] ;           % battery voltage conversion to volts
CAL.PB = [2.5 2.5] ;       % pb conversion to volts
CAL.PBTREF = 3.36 ;        % pb value in volts at TREF
CAL.MB = [2.5 2.5] ;       % mb conversion to volts
CAL.MBTREF = 2.82 ;        % mb value in volts at TREF
