# Compressed XWAVs (`.x.flac`)

Triton reads and writes `.x.flac` as a first-class format. An `.x.flac` is an
`.x.wav` compressed losslessly with [flac](https://xiph.org/flac/), keeping the
`harp` header intact. It is about **half the size** and behaves the same way
everywhere in Triton.

The short version: **you do not need to convert back to `.x.wav` to use the
header information.** Recording times, raw-file boundaries, gain and sample rate
all come out of the `.x.flac` exactly as they come out of the `.x.wav`.

---

## Why this works

`flac --keep-foreign-metadata` stores the original RIFF chunks — `RIFF`, `fmt`,
`harp` and `data` — inside the flac file as metadata blocks. The `harp` chunk,
with its complete raw-file directory, survives byte for byte. So an `.x.flac`
carries the same header as the `.x.wav` it came from; only the audio is
compressed.

That is why an `.x.flac` is treated as **file type 2 (XWAV)**, not type 3. File
type 3 is a *plain* flac, which has no `harp` header at all and whose start time
has to be guessed from its file name.

Inside Triton there is exactly one function that knows the difference —
`xwav_read` — plus one that reproduces the header for the parsers that read it
by byte offset (`xwav_hdrfile`). Both ask `xwav_container`, which decides from
the file's first four bytes rather than its name. Everything else, including
every Remora, treats the two identically.

**[xflac_handling.md](xflac_handling.md) explains the mechanism** — how a header
full of byte offsets still finds the right samples in a file that has none, and
what "without decompressing" does and does not mean. Read that one if someone
asks you how this works.

Reading the magic bytes rather than the extension is not fussiness. Triton
keeps file names in padded character matrices, so a name arrives with trailing
null characters and its extension matches nothing. Decide from the name and an
`.x.flac` gets read as a wav: the file opens, compressed frames come back
interpreted as 16-bit samples, and the result is plausible-looking noise with
no error anywhere.

---

## Getting the flac tool

You need the `flac` command-line program. Triton finds it automatically if it is
on your PATH or in a usual install location; otherwise set the `TRITON_FLAC`
environment variable to its full path.

- Windows: download from <https://xiph.org/flac/download.html>
- macOS: `brew install flac`
- Linux: `apt install flac` (or your package manager's equivalent)

MATLAB cannot do the conversion itself. `audiowrite` writes flac, but it cannot
write the metadata blocks that carry the `harp` header, so a MATLAB-written flac
would lose the recording times.

---

## Converting a folder, either direction

**Tools → Compress/Expand Audio Folders** does this from the menu: pick a source
folder, pick a destination, and Triton shows you what it found and how much
space it needs before anything is written.

From the command line, the same thing:

```matlab
audiodir2flac('E:\HARP\SiteA', 'F:\ToPartner')              % dry run
audiodir2flac('E:\HARP\SiteA', 'F:\ToPartner', 'go', true)  % convert
```

and the reverse:

```matlab
flacdir2audio('F:\FromPartner', 'E:\HARP\SiteA', 'go', true)
```

A bare call is always a **dry run** — it writes nothing and reports what it
would do. Both walk subfolders and reproduce the source layout at the
destination, so a deployment folder with one subfolder per disk arrives looking
the same. Source files are never deleted.

`.wav` becomes `.flac`, `.x.wav` becomes `.x.flac`, and back again. Which one a
file is gets read from the file itself, so an x.wav that was renamed to a plain
`.wav` still comes out as `.x.flac` rather than quietly losing its header.

Single files:

```matlab
audio2flac('E:\HARP\SiteA\file.x.wav')
flac2audio('E:\HARP\SiteA\file.x.flac')
```

### Running out of room

This is the failure the folder tools are built around, because it has bitten: a
drive filling mid-transfer used to leave empty or truncated flac files that
looked perfectly healthy.

Before starting, the tool works out how much space the whole job needs and
refuses if the destination cannot take it. **Expanding, that figure is exact** —
every flac records the size of the file it came from, so there is no guessing
involved. Compressing, it budgets the full input size, which the output never
reaches.

During the run every file is checked again, and each one is written under a
temporary name and renamed into place only once it has been verified. A drive
that fills therefore leaves an obviously-named orphan, never something that
passes for a finished recording.

If the destination does run short, the run **stops** rather than carrying on and
failing on everything after it. Free some space and run it again: finished files
are kept and re-checked, so it continues from where it stopped.

Every run writes a CSV log to the destination listing every file and what
happened to it. Its path is printed when the run *starts*, not when it ends, so
an interrupted run still leaves a record.

### Reclaiming space in place

To convert an archive where it sits and remove the originals as you go:

```matlab
audio2flac('E:\HARP\SiteA\file.x.wav', 'keepInput', false)
audiodir2flac('E:\HARP\SiteA', 'E:\HARP\SiteA', 'go', true)   % same folder
```

Nothing is deleted until the conversion has been verified. The older
`xwavdir2flac` still works and does the same thing, but note it lives in
`Extras/`, which is not on the MATLAB path on a normal install.

---

## Producing `.x.flac` straight from `.hrp`

`write_hrp2xwavs` takes an options struct as its fifth argument:

```matlab
opts.compress = true;    % write x.flac
opts.keepXwav = false;   % and don't keep the x.wav (this is the default)
write_hrp2xwavs(infilename, hdrfilename, outdir, 1, opts)
```

Each `.x.wav` is written as before, then converted, verified, and deleted. It is
written first rather than compressed on the fly for two reasons: flac needs a
complete RIFF file to preserve the header from, and a conversion that cannot be
verified must leave the `.x.wav` where it is.

Compression is **off by default**. This is the function that produces the lab's
primary data, so turning it on should be a deliberate choice rather than
something that happens by upgrading Triton.

---

## Verification, and the failure that matters

The dangerous failure is not a corrupted file — it is a **file that lost its
header and looks completely healthy**.

Compress an `.x.wav` without `--keep-foreign-metadata` and you get a flac that
plays correctly, reports the right sample rate, and passes every casual check.
But the raw-file structure, the gain and the deployment times are gone for good,
and it can never become an `.x.wav` again. Nothing about the file announces
this. Some conversion scripts retry without the metadata flag when the first
attempt fails, which produces exactly this loss across part of a folder without
anyone noticing.

So `xwav2flac` checks two things before it will delete anything:

1. **The audio** — flac is run with `--verify`, which decodes each frame as it
   encodes it and compares against the input.
2. **The header** — the preserved chunks are read back out of the flac and
   compared, byte for byte, with the header of the `.x.wav` about to be deleted.

If either check fails, the `.x.flac` is discarded and the `.x.wav` is kept.

To audit files converted by other means:

```matlab
ck_xflac_metadata('E:\HARP\SiteA')
```

This reports any flac missing its `harp` header, and any whose header declares a
different number of raw files than it actually contains.

---

## Going back

The conversion is lossless, so the original `.x.wav` can be regenerated exactly:

```bash
flac -d --keep-foreign-metadata-if-present file.x.flac
```

The result is byte-identical to the original — this is checked by
`tests/triton_flac_parity.m`.

---

## Guard rails

Three dialogs can be pointed at an `.x.flac` by accident, and all now check the
file rather than trusting its name or your choice of type:

- **Open Wav or Flac File** — if the flac you pick carries a `harp` header,
  Triton says so and opens it as an XWAV instead of a plain flac.
- **LTSA file type 3** — if every flac in the folder carries a `harp` header,
  Triton switches the type to 2 and says so. If only some do, it warns and
  suggests separating them.
- **Decimate Single/All WAV or FLAC File(s)** — same check. This one mattered
  most: decimating a compressed XWAV as though it were a plain flac would have
  written an output with no `harp` header at all, losing the raw-file structure
  and the deployment times permanently.

Decimation also accepts `.x.flac` directly now, under the XWAV entries. The
decimated output is written as `.x.wav`; compress it afterwards with
`xwav2flac` if you want it back.

Without these, an `.x.flac` read as a plain flac would take each file's start
time from its **name** instead of its header, which is wrong by however much the
recorder's clock drifted, with nothing on screen to show it.

---

## Tests

| Test | What it answers |
|---|---|
| `tests/triton_flac_parity.m` | Does the header still mean the same thing, and does the same time window give the same samples from both containers? |
| `tests/triton_flac_ltsa_parity.m` | Is an LTSA generated from `.x.flac` identical to one generated from the `.x.wav`? |
| `tests/triton_convert_dir.m` | Does a whole folder tree survive compression and expansion unchanged, and do the guards fire before anything is written? |
| `Extras/ck_xflac_metadata.m` | Did any file in this folder lose its `harp` header? |

All three need the flac tool. `triton_convert_dir` builds its own tree from the
committed fixtures, so it runs on a fresh clone with no ExampleData; among other
things it truncates a converted file and checks that a re-run notices and redoes
it rather than skipping over it.

---

## Known gaps

- The **Soundscape-Metrics** and **TriHyb** remoras carry their own copies of
  the LTSA code (`sm_get_headers.m`, `sm_ck_ltsaparams.m`, `sm_calc_ltsa.m`,
  `sm_get_headers_recur.m`). They read the `harp` header by byte offset and have
  not been converted, so they will not read `.x.flac`. Each needs the same
  change made in core: open `xwav_hdrfile(...)` instead of the file itself.
- Multichannel conversion needs `--channel-map=none`, which Triton passes
  automatically. Above two channels the WAV spec expects
  `WAVE_FORMAT_EXTENSIBLE`, which XWAVs do not use, and flac otherwise refuses
  with "cannot assign channels".
