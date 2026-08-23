# Notes for AI agents working on Triton

Triton is MATLAB software for passive acoustic analysis, developed at the Scripps Whale Acoustics
Lab and used by researchers, students and government partners across many MATLAB versions. Most
contributors are scientists rather than software engineers, and several use AI assistants, so this
file records the things that go wrong here and are not obvious from the code.

It is operational advice. The rules about *what* may be merged and by whom live in
[docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) and [docs/branch_policy.md](docs/branch_policy.md) —
read those first. The regression harness has its own guide in [tests/README.md](tests/README.md).

---

## Hard rules

**Never stage everything.** `git add .` and `git add -A` will try to commit `ExampleData/`, which
holds tens of gigabytes of real recordings. It is in `.gitignore`, but a single wildcard in the
wrong place undoes that. Stage named paths. Check `git status` before every commit.

**Core Triton must keep working on MATLAB R2018b.** That means the base-folder `.m` files and
anything used across the application. Remoras may require newer releases if they say so. Functions
added after R2018b are the usual trap — `min(...,'omitnan')` needs R2023a, for instance, and
`mean(...,'omitnan')` does not. When in doubt, write the older form; it is nearly always available
and nearly always equivalent.

**Run the regression harness around any change to the base folder.** Record a baseline, make the
change, record again, compare. See [tests/README.md](tests/README.md). This is the difference
between "I believe this is safe" and "this changed nothing".

**Do not commit settings files.** Anything under `Remoras/*/settings/` is ignored unless its name
marks it as shared — `*default*`, `*_init.m`, `*example*`, `*template*`, `README*`. Settings files
name specific deployments and drive letters and are of no use to anyone else. Do not force-add one.

---

## Before merging a branch

**Measure the merge, do not read it.** `git merge-tree --write-tree master origin/<branch>` gives
the conflict list and, diffed against master, exactly what the merge would change. A three-dot
`git diff master...branch` is misleading on old branches: it shows everything master has gained
since the fork as though the branch were removing it.

**Read the diff, not the branch name.** Three branches in this repository had names unrelated to
their contents — one called `update_labelvis` contained no LabelVis changes at all.

**Look for accidental reverts, especially in squash merges.** PR #116 was a squash of a neural-net
branch that happened to carry a `Revert "Merge branch 'master'"` commit. It silently rolled back
flac support across four core files, a version-parsing fix in `xml_read.m`, and three deliberate
GUI changes — none of which anyone would think to look for in an NNet pull request. The signature
is a feature branch whose diff touches unrelated core files, or a deletion count far larger than
the feature warrants.

**When an old branch conflicts modify/delete, find out why the file was deleted.** Three such
conflicts in a 2019 branch were all files that had been removed on purpose — one renamed under a
naming convention, one an example removed twice, one a per-installation config now ignored.
`git log --diff-filter=D -- <path>` gives the commit and its message. Resurrecting a deliberately
deleted file is the quiet failure this whole consolidation exists to prevent.

---

## Known hazards in the codebase

**The same function exists in several places.** `which -all <name>` before assuming which copy
runs. Path order decides, and installed Remoras are added with `genpath`, so the winner can change
with which Remoras a user has. `ioReadXWAVHeader` currently resolves to the BlueWhaleBcall-Detector
copy rather than the Detector one.

**For x.wav format questions, `rdxwavhd.m`, `wrxwavhd.m` and `readseg.m` are the authority.** Files
carrying a `% Do not modify the following line, maintained by CVS` / `$Id: ... $` marker were
written by a different developer and are re-implementations of the same logic; they are often
clearer and occasionally wrong. Byte-exact specifications derived from the authoritative files are
in `D:\Code\Triton_python\docs\formats\` — `xwav.md`, `ltsa.md`, `timebase.md`.

**The year-2000 datenum offset is load-bearing.** Triton stores times as MATLAB datenums shifted by
2000 years, which is what gives sub-microsecond resolution at real sample rates. It looks like a bug
and is not. See `timebase.md` in the path above.

**Core functions touch `HANDLES` even when they are pure computation.** `readseg`, `check_time`,
`mkspecgram`, `init_ltsadata` and others reach into GUI controls. To run them headlessly use
`tests/tr_headless_handles.m`, and extend that shim when something new is needed rather than
stubbing the function under test.

**Generating an LTSA from a file with thousands of raw-file entries crashes MATLAB R2023a.** An
internal assertion inside `calc_ltsa`, not a Triton error. Details and what has been ruled out are
in [tests/README.md](tests/README.md).

**An interrupted LTSA used to read back as valid data.** Fixed, but the shape of the bug is worth
knowing: a failed `fseek` leaves the file pointer where it was, so a subsequent `fread` returns
real-looking values from the wrong place. Check `fseek` status and return, rather than carrying on.

---

## Running MATLAB from a shell

```bash
matlab -batch "addpath('D:/Code/Triton_remoras'); addpath('D:/Code/Triton_remoras/tests'); <command>"
```

`-batch` needs R2019a or newer. Several releases are installed; fingerprints recorded by the
harness are release-dependent, so compare baselines made with the same one.

To syntax-check files without running them, `checkcode(file,'-id')` and look for `SYNER`. Worth
doing on everything you touch — it catches the class of error that only appears when a rarely-taken
branch runs.

---

## Decisions already made

Recorded so they are not relitigated.

**`readseg` splices across recording gaps and always will.** It is the read path for every Remora,
so changing what `DATA` contains would silently alter detector and soundscape results. Gap
information travels separately, through a `PARAMS.raw` field the plotting code reads — the same way
`PARAMS.raw.delimit_time` already carries raw-file boundaries. This is the open question on PR #128.

**flac is file type 3.** `PARAMS.ftype` is 1 for wav, 2 for x.wav, 3 for flac. Both wav and flac
are read through `audioread`, which handles flac natively, so most code paths take them together as
`ftype == 1 || ftype == 3`.

**The four Triton checkouts produce identical output.** `Triton-HARPLab`, `Triton-SpotCheck` and
`Triton1.95.20230315-DataProcessing` each differ from this repository in 32–38 of the ~80 core
files, and all three are byte-identical to it on every case both harnesses cover — 443 reading
cases and 6 LTSA builds. Merging features from them is a tidying exercise, not a risk. Do not
assume a difference is meaningful because the files differ; measure it.

---

## Related repositories

**`D:\Code\Triton_python`** — a Python port of Triton, currently specification and test fixtures
only. Its `docs/formats/` holds the byte-exact format documentation referenced above, and its
`tools/matlab/dump_reference.m` is where this repository's regression harness came from. Worth
consulting before making any claim about file layout.
