function    CAL = tag205(date)
%
%     CAL = tag205([date])
%     Calibration file for tag205
%     Use date=[yr mon day] in case calibration constants
%     changed over time.
%
%     mark johnson and tom hurst
%     thurst@whoi.edu
%     last modified: May 2007

      a_cal = [-6.849 1.632+.0099+.0049+.0257-.0296;
               7.018 -1.613+.0024+.0115+.0158-.0220;
              -7.107  1.415-.0138-.0008-.0232+.0268] ;
      a_cal = [-6.849*(1+.0029) 1.632+.0097;
               7.018 -1.613+.1283;
              -7.107*(1-.0066) 1.415-.0357] ;

CAL.TAG = 205 ;

CAL.TREF = 20 ;                     % temperature of calibration
CAL.TCAL = [125 75] ;               % temperature sensor calibration

CAL.PCAL = [0,1318.9,1204.3] ;
CAL.PTC = 0 ;
CAL.Pi0 = 0.877e-3 ;                        % pressure bridge current
CAL.Pr0 = 130 ;                             % current sensing resistor

CAL.ACAL = [-6.869 1.642 ;
            7.018 -1.485 ;
      	   -7.060 1.379 ] ;

CAL.MCAL = [-105.11	0	;
            97.92	0 ;
            -99.67	0 ] ;

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
