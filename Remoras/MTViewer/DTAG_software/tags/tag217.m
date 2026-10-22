function    CAL = tag217(date)
%
%     CAL = tag217([date])
%     Calibration file for tag217
%     Use date=[yr mon day] in case calibration constants
%     changed over time.
%
%     mark johnson and tom hurst
%     thurst@whoi.edu
%     last modified: 21 May 2006

CAL.TAG = 217 ;

CAL.TREF = 20 ;                     % temperature of calibration
CAL.TCAL = [125 75] ;               % temperature sensor calibration

% pressure cal in Woods Hole
CAL.PCAL = [-50.7 1275.4 1066.1] ;
CAL.PTC = 0 ;

% from a 300 m CTD drop 20/10/2008
CAL.PCAL = [-36.5 1285.9 1195.7] ; 
CAL.PTC = 0 ;

% CTD drop with temperature compensation
CAL.PCAL = [-32.2 1292.3 1198.5] ; 
CAL.PTC = -0.019 ;

CAL.Pi0 = 0.877e-3 ;                        % pressure bridge current
CAL.Pr0 = 130 ;                             % current sensing resistor

CAL.ACAL = [-6.7548 1.7924
            6.7439 -1.6582
            -6.9348 1.7254] ;

CAL.MCAL = [-81.3683 8.7209
            79.6831 7.2726
            -88.6596 -6.5099] ;

CAL.APC = [0 0 0] ;  % pressure sensitivity on ax,ay,az
CAL.ATC = [0 0 0] ;                    % temperature sensitivity on ax,ay,az
CAL.AXC = [1 0 0 ;                     % cross-axis sensitivity on A
           0 1 0 ;
           0 0 1] ;

CAL.MMBC = [0 0 0] ;             % mbridge sensitivity on mx,my,mz
CAL.MPC = [0 0 0] ;                    % pressure sensitivity on mx,my,mz
CAL.MXC = [1 0 0 ;           % cross-axis sensitivity on M
           0 1 0 ;
           0 0 1] ;

CAL.VB = [5 5] ;           % battery voltage conversion to volts
CAL.PB = [2.5 2.5] ;       % pb conversion to volts
CAL.PBTREF =  3.39;        % pb value in volts at TREF
CAL.MB = [2.5 2.5] ;       % mb conversion to volts
CAL.MBTREF =  2.90;        % mb value in volts at TREF

