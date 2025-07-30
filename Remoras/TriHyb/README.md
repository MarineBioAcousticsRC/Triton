# TriHyb: Triton-based Hybrid Millidecade Products

**TriHyb** is a [Triton](https://github.com/MarineBioAcousticsRC/Triton)-compatible Remora developed to compute **Hybrid Millidecade (HMD)** soundscape products, as described in Martin et al. (2021). These minutely-resolution products follow standards established by NOAA's [National Centers for Environmental Information (NCEI)](https://www.ncei.noaa.gov/), and enable detailed analysis of long-term underwater soundscapes.

---

## 🚀 Key Features

- Computes **minutely power spectral density (PSD)** data.
- Generates **daily netCDF** files for long-term acoustic archives.
- Provides visualization-ready data products.
- Supports flexible **frequency band selection** (e.g., 10–4000 Hz).
- Built-in GUI tabs for **metadata entry** and **HMD computation**.
- Integrated as a **Remora** within the Triton PAM software suite.

---

## 🧭 Use Cases

- Identify sound sources (e.g., ships, marine mammals, fish, environmental noise).
- Study temporal trends in underwater soundscapes.
- Compare soundscapes across different sites and deployments.
- Quantify acoustic habitat conditions and anthropogenic impact.

---

## 🛠️ Installation

### 1. Clone or Download Triton + TriHyb

Clone the Triton repository and the TriHyb Remora:

```bash
git clone https://github.com/MarineBioAcousticsRC/Triton.git

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

Enter metadata about your deployment, or click **"Import from .csv file"** to auto-fill fields.

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

**Figure 1 – Example spectrogram with ship and whale detections:**

![Spectrogram Example](https://github.com/miguelgonzalez12/Remora-wiki-draft-/blob/main/IMG_1249.png)

- **Box A:** PSD colorbar  
- **Box B:** Ship noise  
- **Box C:** Whale calls

---

**Figure 2 – Example of high ship traffic day:**

![Ship Day](https://github.com/miguelgonzalez12/Remora-wiki-draft-/blob/main/031724spectragraph.PNG)

- On March 27, 2024, ~11 ships passed by the Channel Islands.

---

### PSD Averages

**Figure 3 – PSD average by frequency (Hz):**

![PSD Average](https://github.com/miguelgonzalez12/Remora-wiki-draft-/blob/main/Combinedfrequencies500.PNG)

- Highlights low-frequency dominance by ship and whale signals.

---

## 🤝 Acknowledgments

Developed by the **Marine Bioacoustics Research Collaborative** with support from NOAA, National Marine Sanctuary Foundation, and the HARP - NCEI working group.

---

## 🧠 Questions?

For support, open an issue on the [Triton GitHub repository](https://github.com/MarineBioAcousticsRC/Triton/issues) or check the [Triton Wiki](https://github.com/MarineBioAcousticsRC/Triton/wiki).


