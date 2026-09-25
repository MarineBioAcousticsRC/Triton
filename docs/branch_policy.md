# Triton GitHub Branch and Merge Policy

The goal of this policy is to keep Triton stable and maintainable while making it easy for students and collaborators to develop and share experimental research code.

## Branches

`master` should contain code that is reasonably stable and usable. New development should normally occur on a branch.

Branches are encouraged for work at any stage, including incomplete or experimental work. Code does **not** need to be ready for release before it is pushed to GitHub.

Branch names should identify the developer and purpose when practical, for example:

`name/remora-feature`  
`name/xwav-fix`

Long-lived branches are discouraged because they become increasingly difficult to merge. Branches with no activity for approximately **3 months** may be flagged as stale. After approximately **6 months**, the owner should decide whether the branch is still active, should be preserved for reference, or can be removed. Old branches will not be deleted solely because a student or project is progressing slowly.

Developers are encouraged to periodically incorporate changes from `master` into active branches. Maintainers and AI tools can assist with this; familiarity with advanced Git operations such as rebasing is not required.

Draft pull requests are encouraged for work that is still in progress.

## Requirements for merging

The amount of review required depends on the scope of the change.

**Core Triton changes** — including WAV/XWAV handling, LTSA generation, shared data structures, configuration, and functions used broadly across Triton — require careful review and testing. Changes should preserve existing functionality and supported MATLAB compatibility unless there is a documented reason for changing it.

**Established Remoras** should be checked for obvious regressions and should document significant new dependencies, toolbox requirements, or MATLAB-version requirements.

**Experimental or research-specific Remoras** may be merged with a lower bar when they are sufficiently isolated from core Triton. Specialized code does not need to meet the same compatibility or completeness standard as the core software, but its limitations and requirements should be documented.

## MATLAB compatibility

Triton will maintain a defined minimum supported MATLAB version for core functionality. Core changes should not raise this requirement without discussion.

Remoras may use newer MATLAB functionality or require specific toolboxes when scientifically useful, but these requirements should be stated clearly.

Where practical, automated or AI-assisted review should flag use of MATLAB functions or syntax that may violate the supported compatibility range.

## General principle

We prefer **visible, recoverable work on GitHub** over code that remains only on individual computers.

A branch can be experimental. `master` should be dependable.