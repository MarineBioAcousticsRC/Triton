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

## Converting an existing archive

Always start with a dry run. It writes nothing and tells you what it would do:

```matlab
xwavdir2flac('E:\HARP\SiteA')
```

Then convert, keeping the originals:

```matlab
xwavdir2flac('E:\HARP\SiteA', 'go', true)
```

Once you have spot-checked the results, convert and reclaim the space:

```matlab
xwavdir2flac('E:\HARP\SiteA', 'go', true, 'keepXwav', false)
```

Nothing is deleted unless `'go'` is true **and** `'keepXwav'` is false. Every
file is verified before its original is removed (see *Verification* below). A
run that stops part-way leaves the converted files in place and the rest
untouched; run it again and it picks up where it left off.

Single file:

```matlab
xwav2flac('E:\HARP\SiteA\file.x.wav', 'keepXwav', false)
```

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

Two dialogs can be pointed at an `.x.flac` by accident, and both now check the
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
| `Extras/ck_xflac_metadata.m` | Did any file in this folder lose its `harp` header? |

Both parity tests need the flac tool. The LTSA test drives generation through
`tests/triton_ltsa_baseline`, the same code the regression harness uses.

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
