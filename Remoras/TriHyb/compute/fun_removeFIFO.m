function [psd_clean, removedHz] = fun_removeFIFO(psd_db, f_hz, Fs, varargin)
% Simple FIFO harmonic remover based ONLY on sampling rate
%
% psd_db : [Ntime x Nfreq] PSD in dB
% f_hz   : [Nfreq x 1] frequency vector (Hz)
% Fs     : sampling rate (Hz)
%
% Name-value:
%   'halfWbins' : +/- bins to remove (default = 2)
%   'fillMethod': 'spline' (default) | 'movmedian'
%
% Returns:
%   psd_clean : cleaned PSD
%   removedHz : FIFO harmonic frequencies removed

% ---------------- parser ----------------
ip = inputParser;
ip.addParameter('halfWbins', 2, @(x)isnumeric(x)&&isscalar(x)&&x>=0);
ip.addParameter('fillMethod','spline', @(s)ischar(s)||isstring(s));
ip.parse(varargin{:});

halfW = ip.Results.halfWbins;
fillMethod = ip.Results.fillMethod;

% ---------------- setup ----------------
psd_clean = psd_db;
f_hz = f_hz(:);
Nf = numel(f_hz);

% ---------------- determine FIFO base ----------------
switch round(Fs)
    case {2000, 10000, 200000}
        fifoBaseHz = 50;
    case 320000
        fifoBaseHz = 80;
    otherwise
        fifoBaseHz = [];
        warning('removeFIFO_simple:UnknownFs', ...
            'Fs = %.0f Hz not recognized; no FIFO removed.', Fs);
        removedHz = [];
        return
end

% ---------------- harmonic frequencies ----------------
maxHz = max(f_hz);
fifoHz = fifoBaseHz : fifoBaseHz : maxHz;

% ---------------- Hz → bin mapping ----------------
mapHz2Bin = @(hz) ...
    max(1, min(Nf, round(interp1(f_hz, 1:Nf, hz, 'nearest','extrap'))));

fifoBins = mapHz2Bin(fifoHz);

% ---------------- build removal mask ----------------
mask = false(1, Nf);
for c = fifoBins
    a = max(1, c - halfW);
    b = min(Nf, c + halfW);
    mask(a:b) = true;
end

% ---------------- apply removal ----------------
psd_clean(mask) = NaN;
psd_clean = fillmissing(psd_clean, fillMethod, 1);

removedHz = f_hz(mask).';
end
