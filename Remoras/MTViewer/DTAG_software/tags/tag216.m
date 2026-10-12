function    CAL = tag216(date)
%
%     CAL = tag216([date])
%     Calibration file for tag216
%     Use date=[yr mon day] in case calibration constants
%     changed over time.
%
%     mark johnson and tom hurst
%     thurst@whoi.edu
%     last modified: 21 May 2006

CAL.TAG = 216 ;

CAL.TREF = 20 ;                     % temperature of calibration
CAL.TCAL = [125 75] ;               % temperature sensor calibration

% pressure cal in Woods Hole
CAL.PCAL = [-76.1 1276.6 1258.2] ;
CAL.PTC = 0 ;

% from a 300 m CTD drop 20/10/2008
CAL.PCAL = [-186.9 1101.1 1192.2] ; 
CAL.PTC = 0 ;

% CTD drop with temperature compensation
CAL.PCAL = [-202.9 1075.7 1180.8] ; 
CAL.PTC = 0.070 ;

CAL.Pi0 = 0.877e-3 ;                        % pressure bridge current
CAL.Pr0 = 130 ;                             % current sensing resistor

CAL.ACAL = [-6.7643 1.7341
            6.9023 -1.9608
            -6.9612 1.8771] ;

CAL.MCAL = [-88.7613 -5.9454
            84.2085 -7.5514
            -87.4766 15.8022] ;

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
CAL.PBTREF =  3.27;        % pb value in volts at TREF
CAL.MB = [2.5 2.5] ;       % mb conversion to volts
CAL.MBTREF =  2.84;        % mb value in volts at TREF

