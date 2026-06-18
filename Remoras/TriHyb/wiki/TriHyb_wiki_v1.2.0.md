# TriHyb: Triton-based Hybrid Millidecade Products

**TriHyb** is a [Triton](https://github.com/MarineBioAcousticsRC/Triton) Remora developed by the [Marine Bioacoustics Research Collaborative](https://mbarc.ucsd.edu/) that processes HARP deployment data to produce one-minute-resolution Hybrid Millidecade (HMD) soundscape products [(Martin et al. 2021)](https://pubs.aip.org/asa/jel/article/1/8/081201/220328/Erratum-Hybrid-millidecade-spectra-A-practical), following the standard established by NOAA's [National Centers for Environmental Information (NCEI)](https://www.ncei.noaa.gov/). Output is stored as daily netCDF files, which can then be used to generate long-term spectrograms and average spectra across deployments.

## Overview

HMD products enable detailed analysis of underwater soundscapes over long time periods. By examining how sound levels vary across frequency and time, researchers can identify and characterize sources such as vessel traffic, marine mammals, and fish, and quantify changes in acoustic habitat conditions across sites and seasons.

## How to Use TriHyb

### Step 1: Add TriHyb to Triton

See the [Quick Setup guide](https://github.com/MarineBioAcousticsRC/Triton/wiki/Quick-Setup#S1) for instructions on cloning the Triton repository and [adding the TriHyb Remora](https://github.com/MarineBioAcousticsRC/Triton/wiki/Quick-Setup#step-4-add-remoras).

### Step 2: Open TriHyb

In the Triton Control Window, go to **Remoras > TriHyb > Compute HMD Products**.

![](https://github.com/miguelgonzalez12/Remora-wiki-draft-/raw/main/IMG_1250.png)

This opens a tabbed window with two sections: **Metadata Compiler** and **Compute HMD**.

### Step 3: Compile Metadata

![](https://github.com/MarineBioAcousticsRC/Triton/raw/master/Remoras/TriHyb/wiki/metadataCompiler_snip.PNG)

The Metadata Compiler tab collects deployment metadata that will be embedded in the output netCDF files. Fields can be filled in manually or imported automatically by clicking **Import from .xlsx file**. If importing, the column headers in the spreadsheet must exactly match the field names in the Remora.

![](https://github.com/MarineBioAcousticsRC/Triton/raw/master/Remoras/TriHyb/wiki/metadataTemplate_snip.PNG)

The above shows a correctly formatted metadata spreadsheet. Field definitions:

- **Title:** Dataset title, including resolution and site name.
- **Summary:** Description of the dataset contents.
- **History:** Name of the person or process that created the product.
- **Source:** Description of how the data were collected.
- **Acknowledgment:** Funders, supporters, and collaborators to acknowledge.
- **Citation:** How to cite this dataset.
- **Conventions:** Metadata conventions followed (e.g., CF-1.8, ACDD-1.3).
- **Creator Role:** Role(s) of the dataset creator(s).
- **ID:** Identifier for the organization that created the product.
- **Institution:** Institution where the data were collected or processed.
- **Keywords:** Descriptive keywords for the dataset.
- **License:** Data license identifier.
- **Product Version:** Version of the data product.
- **References:** Citations for methods used in computing the HMD products.
- **Comment:** Any additional notes (e.g., sensor depth, height above seafloor, known data issues).
- **Creator Name:** Name of the dataset creator.
- **Creator URL:** URL for the creator or their institution.
- **Publisher URL:** URL for the data publisher.
- **Instrument:** Name of the recording instrument (e.g., HARP).
- **Keywords Vocabulary:** Controlled vocabulary used for keywords (e.g., GCMD Science Keywords).
- **Naming Authority:** Authority responsible for the dataset ID (e.g., NOAA NCEI).
- **Publisher Name:** Name of the data publisher.

### Step 4: Compute HMD Products

Select the **Compute HMD** tab.

![](https://github.com/MarineBioAcousticsRC/Triton/raw/master/Remoras/TriHyb/wiki/computeHMD_snip.PNG)

Field definitions:

- **Input Directory:** Directory containing the HARP `.xwav` files for the deployment or disk to process. To process a full deployment spanning multiple disks, check **Search Subfolders**, which will recursively gather all `.xwav` files beneath the selected directory.
- **Filename Pattern:** Glob pattern used to filter which files are processed (e.g., `*df20*` to select only 20 kHz decimation-factor files). Use asterisks as wildcards with no spaces around them.
- **Output Directory:** Directory where the output daily netCDF files will be written.
- **Transfer Function File:** Instrument calibration file (`.tf` extension) for the HARP used in this deployment.
- **Organization:** Organization responsible for data collection and processing.
- **Project:** Project name for the dataset.
- **Site Name:** Name of the recording site.
- **Site Location:** Site coordinates in decimal degrees.
- **Deployment #:** Deployment number.
- **Deployment Start/End Date:** Start and end dates of the deployment in YYMMDD format.
- **Start/End Frequency:** Frequency range (Hz) over which HMD products will be computed.
- **Minimum Effort for Minute Bin (%):** Minimum fraction of a one-minute bin that must contain valid data for the bin to be included in the output.

The output netCDF files can be used to generate long-term spectrograms showing how sound levels vary over time and frequency. The example below shows a long-term spectrogram from the Channel Islands site on March 19, 2024, with approximately 11 ship passages visible as high-amplitude, low-frequency events throughout the day.

![](https://github.com/miguelgonzalez12/Remora-wiki-draft-/raw/main/031724spectragraph.PNG)

**Figure 1:** Example long-term spectrogram output from TriHyb. High-amplitude, low-frequency banding corresponds to individual ship passages.

### Step 5: Visualize HMD Products

After computing HMD products, summary figures can be generated directly from the output `.nc` files. Go to **Remoras > TriHyb > Visualize HMD Products**.

Configure the following options:

- **Path with .nc files:** Directory containing the `.nc` output files from Step 4. The tool searches recursively, so pointing it at a top-level deployment folder will find files across subdirectories.
- **Figure Output Path:** Directory where the generated figure will be saved.
- **Bin by:** Temporal averaging applied to the long-term spectrogram. Options are **Hourly** (1-hour mean per bin), **Daily** (1-day mean per bin, default), or **Keep one-minute resolution** (no averaging).

![](https://github.com/MarineBioAcousticsRC/Triton/raw/master/Remoras/TriHyb/wiki/visualization_output_snip.jpg)

Click **Generate Figures** to produce a three-panel figure:

1. **Long-term spectrogram** (top): spectrum levels across all loaded deployments, with deployment boundaries marked by dashed lines. Uses the *thermal* colormap; units are dB re 1 uPa^2/Hz.
2. **Monthly average spectra** (bottom left): one curve per calendar month, color-coded chronologically. Useful for identifying seasonal patterns.
3. **Seasonal average spectra** (bottom right): spectra pooled across all years by season (Summer: Jun-Aug, Spring: Mar-May, Fall: Sep-Nov, Winter: Dec-Feb). Only seasons present in the data are shown.

The figure is saved as `<Organization>_<Project>_<Site>_HMD_Visualization.png` in the specified output directory.

### Troubleshooting

- **Persistent file locks:** MATLAB occasionally fails to fully release a `.nc` file after reading or writing it. If a file appears locked, run `close all` or restart MATLAB before attempting to access it again.
- **Overwrite restrictions (CLOBBER errors):** NetCDF-4 files cannot be overwritten in place. If a file already exists at the output path, the write will fail. Either delete the existing file or use a new output directory before re-running.
- **Deck test / recovery data:** At the start and end of each HARP deployment, the instrument records noise from shipboard operations (deck tests and recovery activities). To prevent this from affecting long-term analyses, delete the first and last days of data from the output directory after running TriHyb.

## Version History

- **v1.0.0:** First release
- **v1.1.0:** Added Remove FIFO option
- **v1.2.0:** Added Visualize HMD Products GUI and figure generation; bug fixes for MATLAB 2016 compatibility
