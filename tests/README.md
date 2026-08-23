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

That is a useful and narrowing result, but read the limit carefully: **the harness does not cover
LTSA generation.** `calc_ltsa`, `write_ltsahead`, `get_headers` and `ck_ltsaparams` are only
exercised through reading an LTSA that already exists, not through making one. Those are precisely
the files where the known divergences live. Extending the harness to build an LTSA and fingerprint
the result is the obvious next step, and until that exists "identical" means identical *at reading
and display*, not everywhere.

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
