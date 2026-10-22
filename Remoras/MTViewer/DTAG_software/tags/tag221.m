function    CAL = tag221(date)
%
%     CAL = tag221([date])
%     Calibration file for tag221
%     Use date=[yr mon day] in case calibration constants
%     changed over time.
%
%     mark johnson and tom hurst
%     thurst@whoi.edu
%     last modified: 21 May 2006

CAL.TAG = 221 ;

CAL.TREF = 20 ;                     % temperature of calibration
CAL.TCAL = [125 75] ;               % temperature sensor calibration

% pressure cal in Woods Hole
CAL.PCAL = [-101.6 1253.3 1241.6] ; 
CAL.PTC = 0 ;

% from a 300 m CTD drop 20/10/2008
CAL.PCAL = [-160.6 1147.8 1197.5] ; 
CAL.PTC = 0 ;

% CTD drop with temperature compensation
CAL.PCAL = [-185.3 1109.4 1180.6] ;
CAL.PTC = 0.102 ;

CAL.Pi0 = 0.877e-3 ;                        % pressure bridge current
CAL.Pr0 = 130 ;                             % current sensing resistor

CAL.ACAL = [-6.9604 1.8532
            7.1116 -1.6048
            -7.0678 2.1047] ;

CAL.MCAL = [-102.02 -17.8389
            98.0265 13.4775
            -104.985 2.7398] ;

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
CAL.PBTREF =  3.29;        % pb value in volts at TREF
CAL.MB = [2.5 2.5] ;       % mb conversion to volts
CAL.MBTREF =  2.82;        % mb value in volts at TREF

