function    CAL = tag203(date)
%
%     CAL = tag203([date])
%     Calibration file for tag203
%     Use date=[yr mon day] in case calibration constants
%     changed over time.
%
%     *** this tag has not been calibrated - the numbers come from 204
%
%     mark johnson and tom hurst
%     thurst@whoi.edu
%     last modified: May 2007

CAL.TAG = 203 ;

CAL.TREF = 20 ;                     % temperature of calibration
CAL.TCAL = [125 75] ;               % temperature sensor calibration

CAL.PCAL = [0,1342.3,1216.7] ;
CAL.PTC = 0 ;
CAL.Pi0 = 0.877e-3 ;                        % pressure bridge current
CAL.Pr0 = 130 ;                             % current sensing resistor

CAL.ACAL = [-6.623 1.671 ;
            7.077 -1.620 ;
      	   -6.694 1.499 ] ;

CAL.MCAL = [-107.12	0	;
            100.70	0 ;
            -103.93	0 ] ;

CAL.APC = [0 0 0] ;                 % pressure sensitivity on ax,ay,az
CAL.ATC = [0 0 0] ;                 % temperature sensitivity on ax,ay,az
CAL.AXC = [1 0 0 ;                  % cross-axis sensitivity on A
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
