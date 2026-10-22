function    CAL = tag005(date)
%
%     CAL = tag005([date])
%     Calibration file for tag005
%     Use date=[yr mon day] in case calibration constants
%     changed over time.
%
%     mark johnson and tom hurst
%     thurst@whoi.edu
%     last modified: June 2007

CAL.TAG = 5 ;
	a_cal = [2044.0-(-0.0212+0.0055+0.0036-0.0153)*700.5 700.5;
		     2028.7-(0.166 +0.0055-0.0541+0.3933)*677.7 677.7;
		     1902.0-(-0.0136+0.0117+0.0459-0.0417)*682.0 682.0] ;
	m_cal = [2415.4+(-2.7431+0.2293)*8.21 8.21;                   % 8.62
		     1921.4+(2.7352-0.9232)*9.67 9.67;                   % 10.15
		     2044.2+(2.6053+3.1513)*11.226 11.226] ;             % 11.787

CAL.TREF = 20 ;                             % temperature of calibration
CAL.TCAL = [-0.0158 60.0] ;                 % temperature sensor calibration

CAL.PCAL = [0,0.680,-305.4] ;
CAL.PTC = 0 ;
CAL.Pi0 = [] ;                              % pressure bridge current
CAL.Pr0 = [] ;                              % current sensing resistor

CAL.ACAL = [0.0014756 -2.483 ;
            0.0014276 -2.945 ;
      	   0.0014663 -2.787 ] ;

CAL.MCAL = [-0.1218	291.7 ;
            -0.1034	200.5 ;
            -0.0891	187.9 ] ;

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
