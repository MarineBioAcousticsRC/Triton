# HARPproc

Converts raw HARP disk data (`.hrp`) into x.wav, and builds the spot-check reports used
to QC a deployment before analysis.

Merged into Triton master on 2026-08-27 from
`Triton1.95.20230315-DataProcessing/Triton-DataProc/Remoras/HARPproc_260304`, which was
the most recent of four diverging copies. See [Provenance](#provenance) for what the
others were and why this one won.

**Behaviour was carried forward exactly.** Nothing was redesigned as part of the merge,
including the parts that want redesigning — those are listed under
[Known rough edges](#known-rough-edges) so they are visible rather than surprising.

## Installing

Remoras are not on the MATLAB path until installed. `check_path.m` strips all of
`Remoras/` from the path at startup and adds back only what
`Settings/InstalledRemoras.cnf` lists, so copying this directory in does nothing until
you install it through Triton's Remora menu.

**One thing to be careful of.** `ExampleRemoras/HRP/` is an older copy of this same
code — 13 of the same function names, all earlier versions, including `ckFirmware.m`,
`read_rawHARPdir.m` and `write_XWAVhead.m`. It is not on the path by default and neither
is this Remora, so there is no conflict as shipped. But **do not install both**: with
both on the path, which `ckFirmware` runs depends on path order, and the older one lacks
every firmware released since 2022.

## The firmware table, and the thing to know before processing 320 kHz

`ckFirmware.m` reads `table_ckFirmware.csv` to learn how to interpret a disk: channel
count, bits per sample, samples per sector, compression factor, and how many
samples/sectors make up one raw file.

**There are three tables in this directory, and the right one depends on the sample
rate.** This is a workaround, not a design:

| file | rows | `nsampPerRawFile` for `3A01240501` / `3A01251028` | use for |
|---|---:|---|---|
| `table_ckFirmware.csv` | 64 | 15,000,000 samples, 60,000 sectors | **200 kHz** (the default) |
| `table_ckFirmware_3A01240501+251028_320kHz.csv` | 61 | 14,000,000 samples, 56,000 sectors | **320 kHz on `3A01` firmware only** |
| `table_ckFirmware_OG.csv` | 58 | *(rows absent)* | historical reference only |

The reason the split exists is that one firmware string now covers both 200 and 320 kHz,
and those have different raw-file durations — 75 s versus 43.75 s. Firmware version alone
therefore no longer determines raw-file size, so the workaround is to keep two copies of
the table and swap the file.

**Two things make this worse than it sounds, and both were measured rather than assumed.**

**The 320 kHz table is a stale branch, not a variant.** As well as the two changed rows it
is missing three firmwares that the default table has:

| firmware | default | 320 kHz table |
|---|---|---|
| `3A05250108` — 4×100 kHz with IMU + realtime UDP | present | **absent** |
| `4A01251106` — new CPU without FIFO, prototype | present | **absent** |
| `6A01260219` — Feb 2026 | present | **absent** |

`ckFirmware` fails cleanly on an unknown firmware, so the symptom is "cannot process this
disk" rather than wrong numbers — but it means **swapping in the 320 kHz table breaks
processing for those three firmwares**. The swap does not just require remembering to
swap; it guarantees the two tables drift apart, which is the four-copies problem
reproduced inside one directory.

**Only the new `3A01` firmware needs the swap at all.** `V2.64`, the older 320 kHz
firmware, already carries the correct 320 kHz values (14,000,000 / 56,000) in *both*
tables — verified against `ExampleData/320kHz_spotcheck`, whose x.wavs report
`write_length = 56,000` and 14,000,000 samples per raw file. So 320 kHz data from `V2.64`
processes correctly with the default table, and the swap is only needed where one
firmware string spans two rates.

**If you process `3A01`-firmware 320 kHz data with the default table, the raw-file size
will be wrong by 1,000,000 samples per raw file.** Copy the 320 kHz table over
`table_ckFirmware.csv` first, put it back afterwards, and be aware you cannot process the
three firmwares above while it is in place.

This is tracked for redesign — see
[OPEN_DECISIONS §2a](../../../Triton_python/docs/OPEN_DECISIONS.md) if you have that
repository, and [Known rough edges](#known-rough-edges) below for the short version.

## Known rough edges

Carried forward deliberately. Each is a real thing to fix, none was fixed here, because
the point of the merge was to stop maintaining four copies rather than to change
behaviour.

1. **The two-table swap above.** The measured position is that it should not be needed:
   the raw disk's own directory list already records `num_blocks` (sectors) and
   `rec_length` (bytes) *per raw file* — see the layout comment at
   `read_rawHARPdir.m:10-26`, which says **recorded**, not expected. The reading loop in
   `hrp2xwav_multidir.m` already uses `dirlist(j,10)`; only `write_XWAVhead.m:61-73`
   falls back to the table and then to hardcoded sample-rate conditionals. Measured on
   `ExampleData`, raw files on a single disk came in three different sizes (30,000 /
   30,040 / 30,050 sectors), so one table value is wrong for some files regardless of
   which table is loaded.

2. **`ckFirmware.m:29` matches firmware by substring and does not stop at the first
   hit.** `any(findstr(vnum, fwCell{i,1}))` is a bidirectional substring test, and the
   loop has no `break`, so the **last** matching row wins. A firmware string that is a
   prefix of several entries — `V2.9` against `V2.98`, `V2.97`, `V2.96`, `V2.95` — takes
   whichever is last in the CSV, with no warning. It fails cleanly on an unknown
   firmware (`success = 0` and a message naming the file to update), so the risk is
   mis-identification rather than silent garbage. Wants an exact match plus a
   warn-on-multiple. (`findstr` is also long deprecated in favour of `strfind`.)

3. **Firmware-specific behaviour lives outside `ckFirmware`.** `hrp2xwav_multidir.m:250`
   decides whether to extract IMU data with a hardcoded
   `strcmp(PARAMS.head.firmwareVersion(1:4),'3B03')`, and carries its author's own
   comment asking whether it should be a table column instead. It should.

4. **`mk_SpotCheck.m:391` writes the x.wav header version as a character.**
   `PARAMS.xhd.WavVersionNumber = '1'` where its neighbours are genuinely strings, so
   `wrxwavhd.m`'s `fwrite(...,'uchar')` stores 49 rather than 1. Of 123 x.wav files in
   `ExampleData`, 112 carry 49. Harmless today — v0 and v1 share a layout — but a v2 file
   written this way would store 50, `rdxwavhd`'s `== 2` test would fail, and every
   `byte_loc` would be read from the wrong offset. `rdxwavhd.m` was fixed to normalise
   both forms on read (`60a7f02`), which protects existing files; dropping the quotes
   here would fix new ones.

## Two binaries are not committed

`mk_SpotCheck.m:136` invokes `pdftk.exe` (with `libiconv2.dll`) from this directory to
assemble the spot-check PDF. Both files are present in the working copy but excluded
from git, pending a decision: `pdftk` is GPL v2, and this repository is under UC terms.
Invoking a separate executable is normally mere aggregation rather than derivation, but
committing a 9 MB GPL binary to a public repository is not a call to make in passing.

Until that is settled, **the PDF assembly step will fail on a fresh clone.** Everything
else works. Copy the two files from a HARPproc_260304 checkout, or ask.

## Provenance

Four copies existed. This one was chosen by measurement, not seniority:

| copy | firmware table | `hrp2xwav_multidir.m` |
|---|---|---|
| **DataProc `HARPproc_260304`** | 64 rows, current to `3A01251028` | 1,083 lines — newest |
| DataProc `HARPproc_230315` | 64 rows, same | 1,002 lines |
| `Triton-HARPLab HARPproc_251030` | 59 rows, stops at 2022 | 1,021 lines |
| `Triton-SpotCheck HARPproc_230315` | 58 rows, stops at 2022 | 1,002 lines |

* `ckFirmware.m` was **byte-identical in all four**, so nothing had to be reconciled in
  the parser; every difference between the copies was table data.
* Adopting DataProcessing's table is purely additive: no copy held a row it lacks, and
  where a shared row differs it differs only in the trailing comment column — all eleven
  functional columns match.
* HARPLab's 21 unique lines of code in `hrp2xwav_multidir.m` were all the older,
  hardcoded form of the same IMU extraction that 260304 has since parameterised
  (`imu_block == 4` versus `imuRecSz`; fixed 8-byte records versus `idlen` with a
  200 kHz branch). Confirmed with the author, who had extended it earlier in 2026.
* **Consequence of the divergence, for the record:** the three older copies could not
  process single-channel compressed HARP data from 2024 onward at all, because their
  firmware tables stop at `3A01220318`. `ckFirmware` fails cleanly in that case, so the
  symptom was "cannot process this disk" rather than wrong numbers.

`hrp2xwav_multidir_4chTimeHeader.m`, which existed only in the SpotCheck copy, was **not
merged**. It is a 1,056-line variant that reads the per-sector timestamp for uncompressed
4-channel data and cross-checks it against the directory-listing time, trusting the
sector over the dirlist when they disagree (`ckSectorTime`, a local function at its line
483). That is a useful validation idea rather than a kludge, and worth folding into
`hrp2xwav_multidir.m` as an option later; it was left out of this merge because merging a
parallel 1,000-line fork is not "carry behaviour forward exactly".
