function    CAL = tag011(date)
%
%     CAL = tag011([date])
%     Calibration file for tag011
%     Use date=[yr mon day] in case calibration constants
%     changed over time.
%
%     mark johnson and tom hurst
%     thurst@whoi.edu
%     last modified: June 2007

CAL.TAG = 11 ;

CAL.TREF = 20 ;                             % temperature of calibration
CAL.TCAL = [-0.0158 60.0] ;                 % temperature sensor calibration

CAL.PCAL = [0,0.604,-261.6] ;
CAL.PTC = 0 ;
CAL.Pi0 = [] ;                              % pressure bridge current
CAL.Pr0 = [] ;                              % current sensing resistor

CAL.ACAL = [0.0013701 -2.656 ;
            0.0014186 -2.765 ;
      	   0.0014478 -3.050 ] ;

CAL.MCAL = [-0.09149	0 ;
            -0.08658	0 ;
            -0.08084	0 ] ;

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

CAL.VB = [] ;              % battery voltage conversion to volts
CAL.PB = [] ;              % pb conversion to volts
CAL.PBTREF = [] ;          % pb value in volts at TREF
CAL.MB = [] ;              % mb conversion to volts
CAL.MBTREF = [] ;          % mb value in volts at TREF
