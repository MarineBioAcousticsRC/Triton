% called back when a dag is selected after calling dtTonalsPlot
function dagcb(axisH, eventH)

h = gcbo;  % access current callback
tone = get(h, 'UserData');  % grab the dag segment which is a tonal
color = get(h, 'Color');
% extract information about the tonal
time = tone.get_time();
freq = tone.get_freq();
phase = tone.get_phase();
dphase = tone.get_dphase();
ddphase = tone.get_ddphase();
dtime = diff(time);

Fs = 192000;
window_ms = 1;
window_n = round(window_ms/1000 * Fs);

phase_c = exp(-j*phase);  % complex phase
phase_shift = exp(-j*2*pi .* freq(2:end) .* diff(time));


%dphase = [0; mod(angle(phase_c(2:end).*phase_shift) - angle(phase_c(1:end-1)), 2*pi)];
%dphase = [0; mod(angle(phase_c(2:end)) - angle(phase_c(1:end-1)), 2*pi)];
% derived information
kfreq = freq/1000;

figure('Name', sprintf('tonal %.2f-%.2f s %.1f-%.1f kHz', ...
    time(1), time(end), kfreq(1), kfreq(end)));

% fit an nth order model to the frequency sweep
order = 4;
time0 = time - min(time);
Advance_ms = 1;
p = polyfit(time0, freq, order+1);
[p_time, p_phase, p_dphase, p_ddphase] = ...
    phase_pred(time0(end), Fs, phase(1), Advance_ms, 'poly', p);

Nplot = 4;
ax(1) = subplot(Nplot,1,1);
p_time = linspace(0, time0(end), length(p_phase));
plot(time, freq, '.-', min(time)+p_time, polyval(p, p_time), 'k:', 'Color', color);
p_time = p_time + min(time);
ylabel('curve & fit')
legend('measured', 'predicted')
title(sprintf('%d points in tonal', length(time)));

ax(2) = subplot(Nplot, 1, 2);
plot(time, unwrap(phase), '-', p_time, unwrap(mod(p_phase, 2*pi)), 'k:');
ylabel 'phase'

ax(3) = subplot(Nplot,1,3);
plot(time, mod(dphase, pi), '.', p_time, mod(p_dphase, pi), 'k:');
ylabel 'd(rads)/dt % \pi'

ax(4) = subplot(Nplot,1,4);
plot(time, mod(ddphase, pi/2), '.', p_time, mod(p_ddphase, pi/2), 'k:');
xlabel 'time';
ylabel 'd^2(rads)/dt %\pi/2'
linkaxes(ax, 'x');

1;



