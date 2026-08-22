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
  unchanged : 444
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

That comes to **444 cases** over the current example data. `current.json` is the baseline as of the
commit that added it.

Large outputs are stored as MD5 fingerprints rather than as arrays, which keeps the record to about
180 KB instead of gigabytes. A fingerprint still changes if a single sample changes — this was
tested by introducing a one-part-in-ten-million error in the gain applied by `readseg`, which the
comparison caught in all eight affected cases while correctly leaving the two header-only cases
alone.

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

Three of the 444 cases record an error. All three are expected, and all three are useful.

- **`Flac/CINMS01C_sitC_080216_083730.x.flac`** and its sibling — `rdxwavhd` reports *"not wav file
  - exit"*. Current Triton has no flac reading path: there is no `ftype == 3` anywhere in the base
  folder, though `decimatewav.m` handles flac and several comments mention it. The
  `D:\Code\Triton-master` checkout *does* have `ftype == 3` in `ck_ltsaparams.m`, `get_headers.m`
  and `get_ltsadir.m`, so this is a capability that exists in another version and not in this one.
  When it is merged back, these two cases will flip from error to a real fingerprint.

- **`200kHz_xwavs/SOCAL_E_63_EN_LTSA_testSet.x.wav`** — the same message, for a different reason:
  the file begins with the bytes `LTSA`, so it is an LTSA file that has been given a `.x.wav`
  extension. Renaming it to `.ltsa` would move it into the LTSA cases. Nothing to fix in Triton.

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
- The files are `triton_baseline.m` (record), `triton_compare.m` (diff), `tr_hash.m` (fingerprint)
  and `tr_headless_handles.m` (the shim).

## Where this came from

The approach and the headless shim were built for the Python port's parity harness
(`D:\Code\Triton_python`), which needed a trustworthy record of what MATLAB Triton does in order to
check a reimplementation against it. The same record answers a more immediate question — *did this
merge change anything?* — which is what this folder is for.
