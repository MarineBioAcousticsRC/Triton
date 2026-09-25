# Contributing to Triton

Triton is a research software project used by researchers, students, government partners, and other collaborators working with a wide range of MATLAB versions and research workflows.

Our goals are to keep core Triton functionality dependable while making it easy to develop, share, and preserve experimental research code.

## Development workflow

New development should normally occur on a branch rather than directly on `master`.

Branches are welcome at any stage of development, including incomplete or experimental work. Contributors are encouraged to push work to GitHub rather than keeping the only copy on a local computer.

Branch names should identify the contributor and purpose when practical, for example:

`name/xwav-header-fix`  

`name/remora-click-detector`  

Draft pull requests are encouraged for work that is still in progress.

## Core Triton and Remoras

Changes are reviewed differently depending on their scope.

Core Triton includes functionality in the Triton base folder and other code used broadly across the application. Changes to core Triton should receive relatively careful review because they may affect many users and workflows.

Remoras are more specialized modules and may have their own development practices, dependencies, and compatibility requirements. Decisions about compatibility and functionality within a Remora may generally be made by its most active contributors, provided that the Remora does not interfere with core Triton functionality.

## MATLAB compatibility

### Core Triton

Changes to core Triton functionality should remain compatible with MATLAB R2018b or newer unless there is a documented reason to change the minimum supported version.

Contributors should avoid introducing MATLAB syntax or functions newer than R2018b into core functionality unless the change has been discussed and the compatibility implications are understood.

### Remoras

MATLAB compatibility for individual Remoras may be determined by their active contributors.

Where practical, contributors are encouraged to support MATLAB releases from approximately the previous four years.

Some Remoras may reasonably require newer MATLAB releases because they depend on newer capabilities, including machine-learning, geospatial, visualization, or other specialized MATLAB functionality. These requirements should be documented clearly.

### Compatibility with current MATLAB releases

Backward compatibility should not come at the expense of allowing important functionality to become unusable in current MATLAB versions.

Code that fails or is substantially degraded in modern MATLAB releases should be flagged for attention.

Modern-MATLAB compatibility should receive particularly high priority for:

- core Triton functionality
- Spot Check tools
- data-processing tools
- other widely used components that tend to receive less frequent active development

## Dependencies

New MATLAB toolbox, package, library, or external software dependencies should be documented in the pull request and, when appropriate, in the relevant Remora documentation.

Core Triton should avoid unnecessary new dependencies.

Specialized Remoras may introduce dependencies when they provide important scientific or technical capabilities.

## Pull requests

A pull request should briefly describe:

- what changed
- why the change is needed
- whether the change affects core Triton or only a Remora
- MATLAB versions used for development or testing
- any new dependencies or toolbox requirements
- any known compatibility limitations
- any major workflows that should be checked before merging

Pull requests do not need to be perfect before they are opened. Draft pull requests are encouraged when contributors would benefit from feedback before the work is ready to merge.

## Testing expectations

Testing expectations depend on the scope of the change.

Changes to core Triton should be checked against the major workflows affected by the change and should not knowingly break existing core functionality.

Changes confined to a Remora primarily need to demonstrate that the affected Remora works as intended and that the change does not disrupt core Triton.

Where automated tests are available, they should be run before merging. Additional automated compatibility testing may be added over time.

## Review

Changes to core Triton should receive review from at least one maintainer or contributor familiar with the affected functionality before merging.

Remora-only changes may generally be reviewed and approved by active contributors to that Remora.

Changes that alter shared interfaces, file formats, XWAV/WAV handling, LTSA generation, or other broadly used behavior should be treated as core changes even if they originate within work on a Remora.

## General principle

Experimental code is welcome on branches.

The standard for putting work on GitHub is intentionally much lower than the standard for merging it into `master`.

We prefer visible and recoverable research code over work that exists only on individual computers.