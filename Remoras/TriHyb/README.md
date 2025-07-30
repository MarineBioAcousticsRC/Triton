# TriHyb: Triton-based Hybrid Millidecade Products

**TriHyb** is a [Triton](https://github.com/MarineBioAcousticsRC/Triton)-compatible Remora developed to compute **Hybrid Millidecade (HMD)** soundscape products, as described in Martin et al. (2021). These minutely-resolution products follow standards established by NOAA's [National Centers for Environmental Information (NCEI)](https://www.ncei.noaa.gov/), and enable detailed analysis of long-term underwater soundscapes.

---

## 🚀 Key Features

- Computes **minutely hybrid-millidecade** (HMD) soundscape products.
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

**CSV format example:**

![CSV Example](https://github.com/miguelgonzalez12/Remora-wiki-draft-/blob/main/Meta_data1029.PNG)

---

### ⚙️ Compute HMD Tab

Configure the HMD processing options:

- **Input Directory:** Folder containing WAV/XWAV data  
- **Filename Pattern:** Optional filter  
- **Output Directory:** Destination folder for output  
- **Transfer Function File (.tf):** Instrument calibration  
- **Organization**, **Project**, **Site Name**, **Site Location**  
- **Deployment #:** e.g., `CINMS_B_49`  
- **Start/End Date (YYMMDD)**  
- **Start/End Frequency (Hz)**  
- **Minimum Effort for Minute Bin (%)**

Check **"Search Subfolders"** to include multiple disks in a deployment.

---

## 📊 Example Outputs

### Spectrograms

**Figure 1 – Example spectrogram with ship and whale sounds:**

![Spectrogram Example](https://github.com/miguelgonzalez12/Remora-wiki-draft-/blob/main/IMG_1249.png)

- **Box A:** Power spectral density colorbar  
- **Box B:** Ship noise  
- **Box C:** Whale calls

---

## 🤝 Acknowledgments

Developed by the **Marine Bioacoustics Research Collaborative** with support from NOAA, National Marine Sanctuary Foundation, and the HARP - NCEI working group.

---

## 🧠 Questions?

For support, open an issue on the [Triton GitHub repository](https://github.com/MarineBioAcousticsRC/Triton/issues) or check the [Triton Wiki](https://github.com/MarineBioAcousticsRC/Triton/wiki).


