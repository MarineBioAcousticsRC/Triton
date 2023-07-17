function [t_f, angle_f, dangle, ddangle] = ...
    phase_pred(T, Fs, phi0, advance_ms, model, modelArgs, Plot)
% [t, angle_f, dangle, ddangle] = phase_pred(T, Fs, phi0, model, typeArgs)
% Calculate phase information for a given model of frequency modulation
% Assumes that the filter remains constant.
% 
% T - time over which to predict (ending time, start assumed at 0)
% Fs - sample rate
% omega0 - initial freq
% phi0 - initial phase
% advance_ms - delta between successive frames for determining
%              phase prediction per frame
% model - model of freq change
%   'linear', [m, omega0] - linearly changing frequency:
%            m - slope
%            omega0 - freq at time 0
%   'quadratic', [a, m, omega0]
%            omega(t) = a t^2 + m t + omega0
%   'poly', [... d c b a m omega0]
%            generalization of above
%            omega(t) = ... + d t^5 + c t^4 + b t^3 + a t^2 + m t + omega0
% plot - true/false
%
% See Seection 9.2: T. Quatieri, Discrete-Time Speech Signal 
% Processing, Prentice Hall PTR, Upper Saddle River, NJ, 2002
%
% examples:
% FM sweep starting at 20.67 kHz with a sweep rate of 35 kHz/ s
% phase_pred(.1, 192000, 0, 1, 'linear', [35 20.67] * 1000)
% Author:  Marie A. Roch

t = 0:1/Fs:T;  % time axis

if nargin < 7
    Plot = false;
end
% offsets for derivatives
offset = round(Fs/50000);   % How many samples for 1 cycle X Hz

switch model
    case 'linear'
        m = modelArgs(1);
        omega0 = modelArgs(2);
        angle = m * omega0 * (t.^2) / 2 + phi0;

    case 'quadratic'
        coeff = modelArgs;
        polycoef = coeff .* [1/3 1/2 1];
        % angle(t) = a/3 t^3 + b/2 t^2 + c t + phi0
        angle = polyval(polycoef, t) + phi0;
        
    case 'poly'
        % handles linear and quadratic too
        coeff = modelArgs;
        order = length(modelArgs)-1;
        Nth = order+1;
        polycoef = 1./(Nth:-1:1);
        angle = polyval(coeff .* polycoef, t) + phi0;
        
    otherwise 
        error('unknown phase model');
end

% determine phase per frame
frame_idx = 1+offset:round((advance_ms/1000)*Fs):length(t)-offset;
angle_f= angle(frame_idx);
dangle = angle(frame_idx) - angle(frame_idx - offset);
ddangle = (angle(frame_idx + offset) - angle(frame_idx)) - dangle;
t_f = t(frame_idx);


if Plot
    figure('Name', sprintf('%s phase prediction', model));
    
    ax(1) = subplot(3,1,1);
    plot(t, angle, '-', t_f, angle_f, 'o');
    ylabel 'radians'
    title('Unwrapped phase')
    
    ax(2) = subplot(3,1,2);
    % plot derivative
    dangle_f = diff(angle_f) / (advance_ms/1000);
    plot(t_f, unwrap(dangle), '-.');
    title 'phase derivative mod 2\pi'
    xlabel 'time s'
    ylabel 'd(radians)/dt'
    
    ax(3) = subplot(3,1,3);
    plot(t_f, unwrap(ddangle), ':.');
    title 'phase acceleration'
    
    linkaxes(ax, 'x');
end







