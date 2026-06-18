# TriHyb: Triton-based Hybrid Millidecade Products

**TriHyb** is a [Triton](https://github.com/MarineBioAcousticsRC/Triton)-compatible Remora developed to compute **Hybrid Millidecade (HMD)** soundscape products for High-frequency Acoustic Recording Package (HARP) data, as described in Martin et al. (2021). These minutely-resolution products follow standards established by NOAA's [National Centers for Environmental Information (NCEI)](https://www.ncei.noaa.gov/), and enable detailed analysis of long-term underwater soundscapes.

---

## 🚀 Key Features

- Computes **hybrid-millidecade** (HMD) soundscape products in one-minute resolution.
- Generates **daily netCDF** files for long-term acoustic archives.
- Provides visualization-ready data products.
- Built-in GUI tabs for **metadata entry** and **HMD computation**.
- Integrated as a **Remora** within the Triton PAM software suite.

---

## 🧭 Use Cases

- Study temporal trends in underwater soundscapes.
- Identify sound sources (e.g., ships, marine mammals, fish, environmental noise).
- Compare soundscapes across different sites and deployments.
- Quantify acoustic habitat conditions and anthropogenic impact.

---

## 🛠️ Installation

### 1. Clone or Download Triton + TriHyb

Clone the Triton repository and the TriHyb Remora:

Then, place the TriHyb Remora inside the `Remoras/` directory of Triton.

### 2. Add TriHyb to Triton

Follow the instructions in the [Quick Setup Guide](https://github.com/MarineBioAcousticsRC/Triton/wiki/Quick-Setup#step-4-add-remoras) to add the TriHyb Remora to your Triton GUI.

---

## 🧪 How to Use

### Launch TriHyb

1. Open Triton.  
2. From the **Remoras** menu, select `TriHyb > Compute HMD Products`.

This opens a tabbed GUI with the following sections:

---

### 🔖 Metadata Compiler Tab

Enter metadata about your deployment, or click **"Import from .xlsx file"** to auto-fill fields.

**Expected fields include:**

- `Title`, `Summary`, `History`, `Source`, `Acknowledgment`, `Citation`  
- `Institution`, `Keywords`, `License`, `References`  
- `Creator Name`, `Creator Role`, `Creator URL`  
- `Publisher Name`, `Publisher URL`  
- `Instrument`, `Naming Authority`, `Keywords Vocabulary`  
- `ID`, `Comment`, `Product Version`

---

### ⚙️ Compute HMD Tab

Configure the HMD processing options:
- `Input Directory`, `Filename Pattern`, `Output Directory`,
- `Transfer Function File`, `Organization`, `Deployment`  
- `Start Date`, `End Date`, `Start Frequency`, `End Frequency`  
- `Project`, `Site Name`, `Site Location`  
- `Start Frequency`, `End Frequency`  
- `Minimum Effort for Minute Bin`, `Remove FIFO`

---

### 📊 Visualize HMD Tab

After computing HMD products, generate figures from the output `.nc` files using **`TriHyb > Visualize HMD Products`** from the Remoras menu.

Configure the following options:
- `Path with .nc files` — directory containing output `.nc` files (searched recursively)
- `Figure Output Path` — directory where the figure will be saved
- `Bin by` — temporal resolution for the longterm spectrogram: **Hourly**, **Daily**, or **Keep one-minute resolution**

Clicking **Generate Figures** produces a single PNG with three panels:
- **Longterm spectrogram** (top) — full deployment view with deployment boundaries marked
- **Monthly average spectra** (bottom left) — one line per month, color-coded
- **Seasonal average spectra** (bottom right) — pooled Summer, Spring, Fall, Winter averages

The figure is saved as `<Organization>_<Project>_<Site>_HMD_Visualization.png` in the specified output directory.

---

### 🔀 Version History
v1.2.0: Added Visualize GUI and figure generation; bug fixes for MATLAB 2016/2017 compatibility (commit: e465f8b)
v1.1.0: Added Remove FIFO option (commit: 85ecd1f)
v1.0.0: First release

---

## 🤝 Acknowledgments


Developed by the **Marine Bioacoustics Research Collaborative** with support from NOAA, National Marine Sanctuary Foundation, and the HARP - NCEI working group.

---

## 🧠 Questions?

For support, open an issue on the [Triton GitHub repository](https://github.com/MarineBioAcousticsRC/Triton/issues) or check the [Triton Wiki](https://github.com/MarineBioAcousticsRC/Triton/wiki).


