function    CAL = tag231(date)
%
%     CAL = tag231([date])
%     Calibration file for tag231
%     Use date=[yr mon day] in case calibration constants
%     changed over time.
%
%     FAKE!!!
%
%     mark johnson and tom hurst
%     thurst@whoi.edu
%     last modified: 21 May 2006


CAL.TAG = 231 ;

CAL.TREF = 20 ;                     % temperature of calibration
CAL.TCAL = [125 75] ;               % temperature sensor calibration

CAL.PCAL = [-8.531 1340.16 1214.6] ;     % bogus!!
CAL.PTC = 0 ;
CAL.Pi0 = 0.877e-3 ;                        % pressure bridge current
CAL.Pr0 = 130 ;                             % current sensing resistor

CAL.ACAL = [3.9421 -1.0841 ;        % values from flips, signs are correct
         -4.0247 1.1176 ;
         3.8261 -1.0133] ;

CAL.MCAL = [-89.388 11.323 ;
         -88.857 38.791
         87.837 -6.654] ;

CAL.APC = [0 0 0] ;  % pressure sensitivity on ax,ay,az
CAL.ATC = [0 0 0] ;                    % temperature sensitivity on ax,ay,az
CAL.AXC = [1 0 0 ;                     % cross-axis sensitivity on A
           0 1 0 ;
           0 0 1] ;

CAL.MMBC = [0 0 0] ;             % mbridge sensitivity on mx,my,mz
CAL.MPC = [0 0 0] ;                    % pressure sensitivity on mx,my,mz
CAL.MXC = [1 0.03 0.007 ;           % cross-axis sensitivity on M
           0.03 1 -0.02 ;
           0.007 -0.02 1] ;

CAL.VB = [5 5] ;           % battery voltage conversion to volts
CAL.PB = [2.5 2.5] ;       % pb conversion to volts
CAL.PBTREF =  3.29;        % pb value in volts at TREF
CAL.MB = [2.5 2.5] ;       % mb conversion to volts
CAL.MBTREF =  2.82;        % mb value in volts at TREF

