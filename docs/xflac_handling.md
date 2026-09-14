# How Triton reads an `.x.flac` without unpacking it

This explains the mechanism behind `.x.flac` support: how a header that
addresses audio by *byte position in an uncompressed file* still finds the right
samples once that file has been compressed, and why this does not require
decompressing the file back to `.x.wav` first.

For how to *use* the feature — converting archives, the `flac` tool, the safety
checks — see [flac.md](flac.md). This document is the "how does that even work"
companion, for users who ask and for whoever maintains this next.

---

## The problem

An XWAV's `harp` header is a directory of raw files. For each one it records,
among other things:

| field | meaning |
|---|---|
| timestamp | when this raw file started recording |
| `byte_loc` | **where this raw file's audio begins, as a byte offset into the file** |
| `byte_length` | how many bytes of audio it contains |
| `sample_rate` | the rate for this raw file |
| `gain` | recorder gain |

`byte_loc` is the problem. It is a position in a plain, uncompressed file:
"raw file 4 starts at byte 90,001,068." Everything in Triton that extracts a
time window ultimately turns a time into one of those byte offsets, seeks there,
and reads.

A flac has no such positions. Compression means different stretches of audio
take different numbers of bytes, so there is no fixed relationship between "byte
N of the file" and "sample N of the recording." Seeking to byte 90,001,068 of an
`.x.flac` lands in the middle of a compressed frame and means nothing.

So a header full of byte offsets and a file with no byte offsets. The question
is how to reconcile them.

---

## The fact that makes it work

**An `.x.wav` is uncompressed PCM, so its audio is a perfectly regular grid.**

Every sample slice occupies exactly the same number of bytes:

```
bytes per slice = number of channels × (bits per sample ÷ 8)
```

For a 1-channel 16-bit HARP recording that is 2 bytes. For 4-channel 16-bit it
is 8 bytes. It never varies — not between raw files, not within one.

That regularity means **a byte offset and a sample number are two ways of
writing down the same position.** Converting between them is one division:

```
sample number = (byte offset − start of audio) ÷ bytes per slice
```

And a sample number is exactly what flac *can* seek to. Sample position is
native to the format: every compressed frame carries the sample number it starts
at, and the file keeps a seek table mapping sample numbers to byte positions in
the compressed stream.

So the byte offsets in the `harp` header are not useless after compression.
They are still true — they describe the `.x.wav` that this file *would be* if
decompressed — and they convert into something flac understands.

---

## A worked example

Take a real file: `ExampleData/Flac/CINMS01C_sitC_080216_083730.x.flac`.
200 kHz, 1 channel, 16-bit, 30 raw files, 2250 seconds.

**Its preserved header is 1068 bytes**, made of four RIFF chunks:

```
RIFF chunk      12 bytes
fmt  chunk      24 bytes
harp chunk    1024 bytes    = 64 fixed  +  30 raw files × 32 bytes each
data chunk       8 bytes
              ────────────
              1068 bytes    ← this is byte_loc of raw file 1
```

That last line is the whole trick in one number. **The audio starts right after
the header, so `byte_loc(1)` *is* the header size.** Call it `audioStart`.

Now take raw file 4. The header says `byte_loc(4) = 90,001,068`.

```
audioStart      = 1,068 bytes           (byte_loc of raw file 1)
bytes per slice = 1 channel × 2 bytes   = 2

sample number   = (90,001,068 − 1,068) ÷ 2
                = 90,000,000 ÷ 2
                = 45,000,000
```

Raw file 4 begins at sample 45,000,000. Ask flac for samples 45,000,000 onward
and you get exactly the audio the `.x.wav` would have given you at byte
90,001,068 — the same samples, in the same order, bit for bit.

If that division ever came out with a remainder, something would be wrong: it
would mean a byte offset that does not land on a sample boundary. Triton treats
that as an error rather than rounding it away.

---

## What actually happens when Triton reads a segment

Say a Remora asks for two seconds of audio starting at some time.

1. **The time becomes a byte offset.** Unchanged from how Triton has always
   worked — look up the raw file containing that time, take its `byte_loc`, add
   the offset of the wanted sample within it. Nothing here knows or cares about
   compression.

2. **`xwav_read` receives that byte offset** along with the file path and the
   sample geometry (channels, bits per sample, `audioStart`).

3. **It asks the file what it is** — the first four bytes, `RIFF` or `fLaC`.
   Not the file extension; see *What would break this* below.

4. **If `RIFF`:** seek to that byte and read. Exactly as before.

5. **If `fLaC`:** convert the byte offset to a sample number with the division
   above, and ask flac for that range of samples.

6. **Either way the caller gets the same numbers back** — the raw integer sample
   values, in the same shape. Nothing downstream can tell which happened.

The conversion happens at the last possible moment, inside one function. Every
other part of Triton — the timing arithmetic, the forty-odd places that branch
on file type, every Remora — goes on thinking in `.x.wav` byte offsets, because
that is still a correct description of the data.

---

## What "without decompressing" does and does not mean

Worth being precise, since this is the part people ask about.

**It does mean:** no intermediate file is ever written. Triton never expands the
`.x.flac` back to a 900 MB `.x.wav` on disk, not in a temp folder, not anywhere.
There is no unpacking step, no extra disk space needed, and nothing to clean up.

**It does mean:** only the part you asked for is touched. Reading two seconds out
of the middle of a 2250-second file does not walk the preceding 2248 seconds.

**It does not mean** the bytes are read without ever being decoded — that is not
possible, and would not be lossless if it were. Compressed audio has to be
decoded to become samples. What happens is that flac seeks to the frame
containing your first sample, decodes from there, and stops once it has enough.

In these files a frame is 4096 samples (about 20 ms at 200 kHz), so a read is
rounded outward to frame boundaries — at most about 20 ms of extra audio decoded
at each end, and discarded. That is the entire overhead.

### The measured version

Reading one second of audio from different points in that 500 MB file, and for
comparison decoding the whole thing:

| where | time |
|---|---|
| start of file | 17 ms |
| 25% in | 12 ms |
| 50% in | 22 ms |
| 75% in | 17 ms |
| 99% in | 5 ms |
| **the entire 2250-second file** | **3468 ms** |

Two things to notice. The cost does not grow with how far into the file you
read — that is the seek working; a sequential decode would climb steadily across
those rows. And a one-second read costs well under 1% of a full decode, so
nothing like "decompress it all and throw most away" is happening.

The file helps this along: it carries a **seek table** of 225 entries, one every
~10 seconds, so flac can jump close to any position immediately and decode
forward only a little from there.

---

## Where the header comes from

The conversion command is:

```bash
flac --keep-foreign-metadata-if-present ...
```

`--keep-foreign-metadata` tells flac to preserve the original RIFF structure. It
stores each chunk verbatim inside the flac as an `APPLICATION` metadata block
tagged `riff`. Dumping the metadata blocks of the example file:

```
STREAMINFO            34 bytes
SEEKTABLE           4050 bytes   (225 seek points)
VORBIS_COMMENT        40 bytes
APPLICATION           16 bytes   id=riff  chunk=RIFF
APPLICATION           28 bytes   id=riff  chunk=fmt
APPLICATION         1028 bytes   id=riff  chunk=harp     ← the raw-file directory
APPLICATION           12 bytes   id=riff  chunk=data
PADDING            65536 bytes
```

The `harp` chunk is there in full, unmodified — the same 1024 bytes that were in
the `.x.wav`. (Each block is 4 bytes larger than its chunk because of the `riff`
identifier.)

Concatenate those four chunk payloads and you get back the original 1068-byte
`.x.wav` header, byte for byte. That is not an approximation: it is how the
round trip to `.x.wav` is able to be exact.

### Triton does not write a second header parser

This matters for keeping the two formats honest with each other.

Triton reads the `harp` header by seeking to fixed byte positions — channel
count at byte 22, bits per sample at 34, raw-file count at 80, the directory
from 100 — and that code lives in several places (`rdxwavhd`, `get_headers`,
`ck_ltsaparams`, `calc_ltsa`, and the remoras' copies).

Rather than teach each of them a second way to read a header, `xwav_hdrfile`
reassembles the preserved chunks into a small temporary file — 1068 bytes, not
900 MB — and hands back its path. Every one of those `fseek` calls then works
completely unchanged.

So there is exactly **one** header parser. An `.x.flac` and an `.x.wav` cannot
drift apart in how their headers are understood, because the same code reads
both, and a fix to it applies to both at once.

---

## The one number that needs care

`audioStart` — where the audio begins — is not stored as its own field. It is
`byte_loc` of the *first* raw file, which is fine when you have the whole header
in front of you.

It is less obvious in code that walks raw files one at a time. LTSA generation
does exactly that: it iterates over raw files across many files, so at raw file
#4,213 it needs to know where *that file's* audio started, which is not
`byte_loc(4213)`. So `get_headers` records it per raw file while it still has
the header open, and the read path uses that. No extra file access — it is
derived from bytes already read.

---

## Why offsets stay in `.x.wav` bytes until the last moment

This looks like a missed simplification and is deliberate.

Triton could convert positions to sample numbers early and work in samples
throughout. It does not, because the arithmetic that walks those positions
includes at least one known quirk — `calc_ltsa` advances its read pointer by
*this* average's length where the distance to move is the *previous* one's — and
that quirk is baked into LTSAs the lab has already produced and published.

Converting at the very end means both containers land on identical positions,
right or wrong. An LTSA built from an `.x.flac` is byte-identical to one built
from the `.x.wav`, quirks included. Had the flac path "fixed" the arithmetic on
the way past, the two would disagree and it would look like compression had
changed the data.

If that arithmetic is ever corrected, the correction reaches both formats at
once, for the same reason.

---

## What would break this, and what stops it

**A flac without its harp header.** Compress without `--keep-foreign-metadata`
and the audio is fine but the directory is gone — no raw-file boundaries, no
recording times, no gain, and no way back to `.x.wav`. The file still plays and
reports the right sample rate, so nothing looks wrong. `xwav2flac` refuses to
delete an original until it has read the preserved header back and compared it
byte for byte with the header of the file it is about to remove.
`ck_xflac_metadata` audits folders converted by other means.

**Deciding the format from the file name.** Triton stores file names in padded
character matrices, so a name often arrives with trailing null characters and
its extension matches nothing. Decide from the name and an `.x.flac` gets read
as a wav: the file opens, compressed frames come back interpreted as 16-bit
samples, and the result is plausible-looking noise with no error anywhere. This
is not hypothetical — it happened. The format is now decided from the file's
first four bytes (`xwav_container`), which padding cannot defeat.

**An edited flac.** If someone re-encodes the audio without updating the header,
the `harp` directory would describe a file that no longer exists. `rdxflachd`
cross-checks the sample count the header implies against what the file actually
holds, and warns on a mismatch.

---

## Where the code is

| function | what it does |
|---|---|
| `xwav_container.m` | wav or flac, from the first four bytes |
| `xwav_hdrfile.m` | a path whose bytes are the `.x.wav` header, either format |
| `xwav_read.m` | byte offset in, samples out; the conversion lives here |
| `rdxflachd.m` | reads an `.x.flac` header into the same `PARAMS` an `.x.wav` gives |
| `xflac_riff_chunks.m` | pulls the preserved RIFF chunks out of a flac |
| `xwav2flac.m` | convert one file, with verification |
| `Extras/xwavdir2flac.m` | convert a folder |
| `Extras/ck_xflac_metadata.m` | audit a folder for lost headers |

And the tests that hold it honest:

| test | what it answers |
|---|---|
| `tests/triton_flac_parity.m` | Does the same time window give the same samples from both formats? |
| `tests/triton_flac_ltsa_parity.m` | Is an LTSA from `.x.flac` identical to one from the `.x.wav`? |
