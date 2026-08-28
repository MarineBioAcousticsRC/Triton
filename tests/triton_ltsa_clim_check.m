function ok = triton_ltsa_clim_check
%TRITON_LTSA_CLIM_CHECK  Does the LTSA colour range hold across windows?
%
%   ok = triton_ltsa_clim_check
%
% Drives the real plot_ltsa.m headlessly and asserts four things. The regression
% harness cannot check any of them: it records what Triton *reads*, and colour
% limits are display state that never reaches a fingerprint.
%
%   1. The range is derived from the data on the first draw.
%   2. It is then HELD. Redrawing after a brightness change must not move it --
%      that is the entire point. A range that moved as the analyst scrolled would
%      make the same sound level look different from one window to the next.
%   3. Clearing PARAMS.ltsa.clim re-derives, which is what opening a file does.
%   4. An -Inf in PARAMS.ltsa.pwr does not crash the colorbar.
%
% WHY 2 AND 4 EXIST
%
% Both are regressions that actually happened.
%
% (2) When plot_specgram was made sticky for issue #111, plot_ltsa was left
% recomputing its range every frame, so brightness and contrast did not survive
% scrolling in the LTSA. Reported by sfregosi-noaa in PR #131. Note that check 3
% returning a *different* range than check 1 is what check 2 would have returned
% had the bug still been present -- the test exhibits the bug and the fix in one
% run.
%
% (4) The colorbar minimum used to be min(abs(c(:))), which mislabelled the scale
% whenever the data went negative. The obvious fix, min(c(:)), reintroduces a
% crash: PARAMS.ltsa.pwr can hold +/-Inf (see the comment at plot_ltsa.m line 53)
% and [-Inf:2:maxc] does not merely misbehave, it errors with "Requested array
% exceeds the maximum possible variable size". The live code filters non-finite
% values instead, which gets the correct label *and* a finite colon. This check
% is what stops someone simplifying it back.
%
% Usage: run from the Triton root with tests/ on the path.
%
% Part of the Triton regression harness -- see tests/README.md.

global PARAMS HANDLES %#ok<GVMIS>

ok = true;
initparams;
tr_headless_handles;

f = figure('Visible','off');
ax = axes('Parent',f);

% A synthetic LTSA: 51 frequency bins by 12 time bins, ramping 20..60 dB.
PARAMS.ltsa.pwr   = repmat(linspace(20,60,51)',1,12);
PARAMS.ltsa.t     = (0.5:11.5)/3600;
PARAMS.ltsa.f     = (0:50)*100;
PARAMS.ltsa.freq  = PARAMS.ltsa.f;
PARAMS.ltsa.fimin = 1;
PARAMS.ltsa.fimax = 51;
PARAMS.ltsa.bright = 0;
PARAMS.ltsa.contrast = 100;
PARAMS.ltsa.tave  = 1;
PARAMS.ltsa.dfreq = 100;
PARAMS.ltsa.fs    = 10000;
PARAMS.ltsa.nfft  = 100;
PARAMS.ltsa.nf    = 51;
PARAMS.ltsa.nave  = 12;
PARAMS.ltsa.ch    = 1;
PARAMS.ltsa.inpath = ['synthetic' filesep];
PARAMS.ltsa.infile = 'clim_check.ltsa';
PARAMS.ltsa.plotStartRawIndex = 1;
PARAMS.ltsa.plotStartBin = 1;
PARAMS.ltsa.nrftot = 1;
PARAMS.ltsa.tseg.step = -1;
PARAMS.ltsa.tseg.hr = 1/60;
PARAMS.ltsa.plot.dnum  = datenum([11 1 30 8 45 0]);
PARAMS.ltsa.start.dnum = PARAMS.ltsa.plot.dnum;
PARAMS.ltsa.dnumStart  = PARAMS.ltsa.plot.dnum;
PARAMS.ltsa.dnumEnd    = PARAMS.ltsa.plot.dnum + 12/86400;
HANDLES.plt.ltsa = image('Parent',ax,'CData',PARAMS.ltsa.pwr);
PARAMS.ltsa.cb   = colorbar('peer',ax);

try
    % 1 -- derived from the data
    plot_ltsa;
    first = PARAMS.ltsa.clim;
    ok = expect(ok, ~isempty(first) && first(2) > first(1), ...
        sprintf('1. derived a range: %s', mat2str(first,6)));

    % 2 -- held across a redraw, even though brightness moved the data
    PARAMS.ltsa.bright = -15;
    plot_ltsa;
    ok = expect(ok, isequal(first, PARAMS.ltsa.clim), ...
        sprintf('2. held after brightness change: %s', mat2str(PARAMS.ltsa.clim,6)));

    % 3 -- cleared means re-derive, which is what opening a file does
    PARAMS.ltsa.clim = [];
    plot_ltsa;
    ok = expect(ok, ~isequal(first, PARAMS.ltsa.clim), ...
        sprintf('3. re-derived once cleared: %s (differs from 1, as it must)', ...
        mat2str(PARAMS.ltsa.clim,6)));

    % 4 -- non-finite power does not crash the colorbar
    PARAMS.ltsa.clim = [];
    PARAMS.ltsa.bright = 0;
    PARAMS.ltsa.pwr(1,1) = -Inf;
    PARAMS.ltsa.pwr(2,2) = Inf;
    plot_ltsa;
    ok = expect(ok, all(isfinite(PARAMS.ltsa.clim)), ...
        sprintf('4. survived +/-Inf in pwr: %s', mat2str(PARAMS.ltsa.clim,6)));
catch err
    fprintf('  FAIL  %s\n        at %s line %d\n', err.message, ...
        err.stack(1).name, err.stack(1).line);
    ok = false;
end

close(f);
fprintf('\n%s\n', repmat('-',1,58));
if ok
    fprintf('triton_ltsa_clim_check: PASS\n');
else
    fprintf('triton_ltsa_clim_check: FAIL\n');
end
end


function ok = expect(ok, cond, msg)
if cond
    fprintf('  ok    %s\n', msg);
else
    fprintf('  FAIL  %s\n', msg);
    ok = false;
end
end
