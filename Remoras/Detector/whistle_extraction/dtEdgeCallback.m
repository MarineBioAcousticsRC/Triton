function dtEdgeCallback(axisH, eventH)
% dtEdgeCallback
% Callback for selecting an edge in a graph

h = gcbo;  % access current callback
tone = get(h, 'UserData');  % grab the dag segment which is a tonal
color = get(h, 'Color');
% extract information about the tonal
time = tone.get_time();
freq = tone.get_freq();
phase = tone.get_phase();
dphase = tone.get_dphase();
ddphase = tone.get_ddphase();

% derived information
kfreq = freq/1000;

figure('Name', sprintf('tonal %.2f-%.2f s %.1f-%.1f kHz', ...
    time(1), time(end), kfreq(1), kfreq(end)));

% fit an nth order model to the frequency sweep
order = 5;
time0 = time - min(time);
Advance_ms = 1;
p = polyfit(time0, freq, order);
[p_time, p_phase, p_dphase, p_ddphase] = ...
    phase_pred(time0(end), 192000, phase(1), Advance_ms, 'poly', p);

Nplot = 4;
ax(1) = subplot(Nplot,1,1);
p_time = linspace(0, time0(end), length(p_phase));
plot(time, kfreq, min(time)+p_time, polyval(p, p_time)/1000, 'k:', 'Color', color);
p_time = p_time + min(time);
ylabel('kHz')
legend('measured', 'predicted')

ax(2) = subplot(Nplot, 1, 2);
u_phase = unwrap(phase);
plot(time, mod(phase, 2*pi), 'b-o', p_time, mod(p_phase, 2*pi), 'r:');
ylabel 'phase'

ax(3) = subplot(Nplot,1,3);
plot(time, mod(dphase, 2*pi), 'b-o', p_time, p_dphase, 'r:');
ylabel 'd(radians)/dt % 2\pi'

ax(4) = subplot(Nplot,1,4);
plot(time, mod(ddphase, 2*pi), '-o', p_time, mod(p_ddphase, 2*pi), 'r:');
xlabel 'time';
ylabel 'd^2(radians)/dt'
linkaxes(ax, 'x');

1;



