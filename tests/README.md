# Regression tests

A way to check that a change to Triton did not alter results it was not meant to alter.

The idea is simple. Before you merge anything, record what Triton currently produces from a set of
real recordings. Merge. Record again. Compare the two records. Anything that moved, moved because
of your merge — so either you meant it, or you just found a regression.

This is not a unit-test suite and does not check that Triton is *correct*. It checks that Triton
still does **what it did yesterday**, which is the thing that actually goes wrong when several
versions get merged together.

## Running it

You need MATLAB and a copy of the example data. From the Triton folder:

```matlab
addpath('tests')

% before your change
triton_baseline('out','tests/baseline/before.json')

% ... merge, edit, whatever ...

% after your change
triton_baseline('out','tests/baseline/after.json')

triton_compare('tests/baseline/before.json','tests/baseline/after.json')
```

A clean result looks like this:

```
  unchanged : 450
  changed   : 0
  appeared  : 0
  vanished  : 0

  No regressions: every case that ran before produces identical output.
```

A run over all the example data takes a few minutes. While you are iterating, restrict it:

```matlab
triton_baseline('sets',{'200kHz_xwavs'}, 'maxfiles',2, 'out','tests/baseline/quick.json')
```

## What it checks

For every `.x.wav` file it finds, it calls Triton's own functions — `rdxwavhd`, `check_time`,
`readseg`, `mkspecgram` — and records:

- the header: sample rate, channels, bit depth, raw-file count, byte offsets, gain, and a
  fingerprint of the per-raw-file start and end times
- three reads of audio, taken at the first, middle and last raw file, each with a fingerprint of
  the samples plus their size, minimum, maximum and sum
- one spectrogram, with fingerprints of the power, frequency and time vectors

For every `.ltsa` file: the header fields, and a fingerprint of one hour of power values.

For plain `.wav`: the header fields.

For every `.flac` file: the header from `audioinfo`, and three reads at fixed offsets. flac carries
no harp header, so there is no per-raw-file timing to step through; the reads run through
`initparams` then `initdata` then `readseg`, the same order the application uses, which exercises
the `ftype == 3` path end to end.

That comes to **450 cases** over the current example data. `current.json` is the baseline as of the
commit that added it.

Large outputs are stored as MD5 fingerprints rather than as arrays, which keeps the record to about
180 KB instead of gigabytes. A fingerprint still changes if a single sample changes — this was
tested by introducing a one-part-in-ten-million error in the gain applied by `readseg`, which the
comparison caught in all eight affected cases while correctly leaving the two header-only cases
alone.

## The other half: LTSA generation

`triton_baseline` covers *reading*. `triton_ltsa_baseline` covers *making an LTSA*, which is the
other half of Triton's core and the half where the four checkouts are known to disagree —
`calc_ltsa`, `write_ltsahead`, `get_headers` and `ck_ltsaparams` are only reachable this way.

```matlab
triton_ltsa_baseline('out','tests/baseline/ltsa_before.json')
% ... change something ...
triton_ltsa_baseline('out','tests/baseline/ltsa_after.json')
triton_compare('tests/baseline/ltsa_before.json','tests/baseline/ltsa_after.json')
```

Same comparison tool — both recorders emit the same identity fields.

For each directory holding two or more recordings of one type it builds an LTSA into a temporary
folder and records the **header block and the power block as separate fingerprints**, so a change
in the computed spectra is distinguishable from a change in the metadata written around it. It also
records the parameters the pipeline derived on the way — `nfft`, `cfact`, `nfreq`, the LTSA version,
the per-file averaging counts and the start times.

`mk_ltsa` cannot be driven headlessly: it asks for the directory and the averaging parameters
through dialogs. Those two steps are replaced by setting the same `PARAMS` fields the dialogs set,
marked in the source with *"what the dialogs would do"*. Everything that computes anything —
`get_headers`, `ck_ltsaparams`, `write_ltsahead`, `calc_ltsa` — is the real function, unmodified.
`write_ltsahead` skips its save dialog because `PARAMS.ltsa.outfile` is pre-set, which the
`isfield` guard in that file makes possible.

Generated LTSAs go to a temp folder and are deleted afterwards; pass `'keep',true` to inspect them.
Nothing is written into the data folder.

### The calc_ltsa padding branch, and the fixtures that reach it

`calc_ltsa` pads the final spectral average of a raw file with zeros when that average holds fewer
samples than `nfft`. That branch is where the four checkouts differ, and it carries the
misplaced-bracket bug found on six branches:

```matlab
if length(data(1,:) == length(dz(1,:)))     % always true -- the else is dead
```

**None of the real example data reaches it**, because every raw file's sample count happens to be a
whole multiple of `nfft`. `tests/fixtures/` holds two small pairs of files, built by
`make_pad_fixture.m`, that do:

| Fixture | Reaches padding with | Why both are needed |
|---|---|---|
| `fixtures/pad_wav` | 50 samples left over, `nfft` 100 | wav samples are a **column**, so the correct and broken forms both concatenate vertically. Output is identical. This is the case that proves the bug is harmless here |
| `fixtures/pad_xwav` | 250 samples left over, `nfft` 300 | x.wav samples are a **row** (`data = data(ch,:)`), so the correct form appends horizontally and the broken form vertically. This is the case that exposes the bug |

Both fire at the harness's default `tave` and `dfreq` — no special parameters needed. The x.wav is
one channel, 16-bit, version 1, written to the byte layout in `docs/formats/xwav.md` of the Python
port, and confirmed readable by Triton's own `rdxwavhd`.

Demonstrated by injecting the broken form into `calc_ltsa` and re-running:

```
  fixtures/pad_wav    wav   hdr b21140f3  pwr 6a0df0bd     <- unchanged
  fixtures/pad_xwav   xwav  ERROR Dimensions of arrays being concatenated are not consistent.

  unchanged : 1
  changed   : 1
```

So the branch is now covered, and it is worth knowing *how* it fails: on x.wav input the bug is not
a quiet numerical drift, it is a hard error. Any tree carrying that form cannot build an LTSA from
x.wav at all whenever the last average comes up short.

The fixtures are about 800 KB in total and are committed, so this case runs on a fresh clone with
no example data present. Pass `'fixtures',false` to skip them.

## Reading the comparison

```
  CHANGED  SOCAL_E_63_EN_180315_234230.x.wav :: read_seg15
             data_hash    eeb50a4c...  ->  91a1e8c4...
             data_max     772          ->  771.9999228
```

Three outcomes are reported:

| | |
|---|---|
| `CHANGED` | same input, different output. If you did not mean to change behaviour, this is a regression |
| `APPEARED` | a case that failed before and works now, or a new file in the data folder |
| `VANISHED` | a case that worked before and fails now, or a file removed from the data folder |

Errors are recorded rather than thrown, so a file Triton refuses to read is part of the baseline
like anything else. That is deliberate: when someone restores a missing capability, the error
disappears and the comparison reports it as a change. Fixing something shows up just as clearly as
breaking it.

## Known errors in the current baseline

One of the 450 cases records an error.

**`200kHz_xwavs/SOCAL_E_63_EN_LTSA_testSet.ltsa.wav`** — the file begins with the bytes `LTSA`, so
it is an LTSA file that has been given a `.wav` extension. Triton declines it cleanly with *"not
wav file - exit"*. Nothing to fix in Triton; renaming it to end in `.ltsa` rather than `.wav` would
move it into the LTSA cases and clear the error.

Flac used to be the other one, and is now covered: 2 headers and 6 reads, no errors.

## Baselines in this folder

| File | What it is |
|---|---|
| `current.json` | master, 450 cases, the reference to compare against |
| `variant_harplab.json` | `Triton-HARPLab/triton1.95.20231113` over the same data |
| `variant_spotcheck.json` | `Triton-SpotCheck/triton1.93.20170330_dev` |
| `variant_dataproc.json` | `Triton1.95.20230315-DataProcessing/Triton-DataProc` |
| `ltsa_master.json` | master, LTSA generation over a scoped set (see below) |
| `ltsa_harplab.json` `ltsa_spotcheck.json` `ltsa_dataproc.json` | the same six builds on each variant |

The variant snapshots were taken with the `'triton'` option, which points the harness at another
checkout while using the same data:

```matlab
triton_baseline('triton','D:/Code/Triton-HARPLab/triton1.95.20231113', ...
                'out','tests/baseline/variant_harplab.json')
```

The path is reset before each run, so one tree is never mixed with another.

**What those three comparisons showed.** Each variant differs from master in 32 to 38 of the roughly
80 core `.m` files, yet all three produce **byte-identical output on every one of the 443 comparable
cases**. So on the paths this harness covers — header parsing, audio reads, spectrograms and LTSA
reading — the divergence between the four trees is entirely cosmetic.

**LTSA generation says the same thing.** All four trees were run through `triton_ltsa_baseline`
over six builds -- both padding fixtures, `Flac`, `Wavs`, `4Channel_100kHz` and `200kHz_xwavs` -- and
all three variants produce **byte-identical header and power blocks to master on all six**. So the
32-38 differing core files per tree are cosmetic for LTSA generation as well as for reading.

That includes the two cases most likely to separate them: the flac path, and the `calc_ltsa` padding
branch on both wav and x.wav. If any tree carried the broken bracket form, `pad_xwav` would have
errored instead of matching.

The six builds deliberately exclude the two duty-cycled sets and `ExampleSpotCheck`. Those are slow,
they exercise the same code paths as the sets above rather than new ones, and `Duty_cycled_df100`
triggers the MATLAB crash described next.

### An R2023a crash on files with thousands of raw files

Generating an LTSA from `ExampleData/Duty_cycled_df100_xwavs_and_LTSA` kills **MATLAB R2023a**:

```
Assertion in foundation::usm::Detail<struct foundation::usm::scope::Mvm>::find
  at ...matlab/foundation/usm/management.cpp line 778:
  find: no active context for type 'struct mcos::COSContext_Proxy'
```

This is an assertion inside MATLAB itself, not a Triton error. It happens **inside `calc_ltsa`**,
after `write_ltsahead` has succeeded, about 16% of the way through writing the spectra. Those two
files declare 5,368 raw-file entries each -- 10,736 for the pair, against 30 for a typical x.wav.

**R2024a and R2025b both run the identical job to completion**, producing the full 2,898,448-byte
file. So this is release-specific rather than a scale limit in Triton, and the guidance is simply to
build LTSAs from high-raw-count deployments on R2024a or newer.

The two releases also produced **byte-identical output** -- same header hash, same power hash. That
is worth knowing separately: the general warning above about comparing baselines only within one
release does not appear to bite for LTSA generation across R2024a and R2025b, at least on this
input.

Ruled out by direct test rather than reasoning, in case it resurfaces: `tr_hash` (1.5 million
elements, clean), headless `loadbar` (12,000 create-update-close cycles, clean), `pwelch` at volume
(200,000 calls, clean), and a file-handle leak (`fopen`/`fclose` are per-file, only two opens).

Attempts to reproduce it synthetically under R2023a all **succeeded**, so it is not a simple
capacity limit: 11,000 raw-file entries in one x.wav, 160,000 spectral averages over 1,000 raw
files, and 3,000 small wav files in a directory each completed normally. Whatever the trigger is,
it involves something about the real files that those do not capture.

Separately, and not the same thing: LTSA versions 1 and 2 stored `nrftot` as a 2-byte field, capping
total raw files at 65,535 (`read_ltsahead.m:71`). Version 4 widened it to 4 bytes and
`get_headers.m:126` now always writes version 4, so that ceiling is long gone. The count of *input
files*, `nxwav`, is still 2 bytes; `write_ltsahead` now refuses above 65,535 rather than letting
`fwrite` saturate silently.

The crash is also what exposed the truncated-LTSA bug described next, so it was worth chasing.

### Truncated LTSAs

An LTSA whose generation is interrupted -- a crash, a cancelled run, a full disk, a dropped network
share -- used to read back as valid data. Fixed, and worth knowing the shape of:

`read_ltsahead` accepted a file holding 16% of its declared spectra without comment. `read_ltsadata`
then sought past end-of-file; `fseek` returned -1 and a message was logged, but the code fell
through to the `fread` anyway. A failed seek leaves the file pointer where it was, so the read
returned a full block of **real-looking values from the wrong part of the file** -- not zeros, not
an error, just plausible spectra at incorrect times.

Now `read_ltsahead` reports how much is missing, and `read_ltsadata` returns NaN for a window it
cannot reach. Verified against a real truncated file, and against the full baseline to confirm
nothing changes for complete ones.

## Notes

- The example data is not in version control — it is several tens of gigabytes and `ExampleData/`
  is in `.gitignore`. The baseline JSON is committed, but reproducing it needs the data. Point
  `triton_baseline` at wherever your copy lives with the `'data'` option.
- Fingerprints depend on the MATLAB release. Numeric output can shift between versions, so a
  comparison across two different releases will show changes that are not caused by your edit. Each
  manifest records the release it was made with, and `triton_compare` prints both, so check they
  match before believing a difference. Compare like with like.
- `tr_headless_handles.m` is what makes this possible without opening the GUI. Several core
  functions touch the `HANDLES` global even though their work is pure computation; the shim builds
  just those handles as real controls on one invisible figure. This means `readseg`, `check_time`
  and `mkspecgram` run **for real** rather than being reimplemented here — the numbers recorded are
  the ones users get. If you add a case that needs another handle, extend the shim rather than
  working around it.
- The files are `triton_baseline.m` (record reading), `triton_ltsa_baseline.m` (record LTSA
  generation), `triton_compare.m` (diff either), `tr_hash.m` (fingerprint) and
  `tr_headless_handles.m` (the shim).

## Where this came from

The approach and the headless shim were built for the Python port's parity harness
(`D:\Code\Triton_python`), which needed a trustworthy record of what MATLAB Triton does in order to
check a reimplementation against it. The same record answers a more immediate question — *did this
merge change anything?* — which is what this folder is for.
