# Dyslexia UK Biobank Imaging-Genetics Pipeline

This repository contains scripts for preprocessing, polygenic score (PGS) calculation, 
neuroimaging registration, and statistical analyses of UK Biobank data. The pipeline 
investigates the relationship between dyslexia polygenic risk scores and brain morphology 
using tensor-based morphometry (TBM) and various statistical approaches. 

---

## Pipeline Overview

1. **Preprocessing & PRS Calculation (Genetic Branch)**

   - Convert GWAS summary statistics into a PRScs-compatible format.
   - Generate polygenic scores (PGS) using PRScs.
   - Extract relevant PGS subsets for statistical analyses.
   - Visualize PGS distributions.

2. **Image Registration (Neuroimaging Branch)**

   - Process T1-weighted neuroimaging data.
   - Register images to a common template.
   - Compute Jacobian determinants to quantify volumetric changes.

3. **Statistical Analysis**

   - Perform voxelwise and component-based statistical tests.
   - Conduct permutation testing to validate findings.
   - Visualize results.

---

## Pipeline Details

### 1. Preprocessing & PRS Calculation (Genetic Branch)

- `preprocess_dyslexia.py` : Converts GWAS summary statistics to PRScs input format.
- `dys_prscs.sh` : Runs PRScs to compute SNP-based effect sizes.
- `dys_pgs.R` : Aggregates PRScs output into polygenic scores.
- `get_relevant_pgs.py` : Extracts PGS subsets for different statistical tests.
- `PGS_histogram.py` : Generates histograms of the PGS distribution.

### 2. Image Registration (Neuroimaging Branch)

- `nifti_2_jacobian.sh` : Processes and registers neuroimaging data, generating Jacobian maps.

### 3. Statistical Analysis

- **Cross-Sectional Analysis**:

  - `glm_baseline.sh` : Performs voxelwise GLM for cross-sectional analysis.

- **Longitudinal Voxelwise Analysis**:

  - `glm_siena.sh` : Conducts voxelwise GLM on longitudinal TBM-derived Jacobian maps.
  - `randomise_siena.sh` : Permutation testing for longitudinal voxelwise analysis.

- **Longitudinal Component Analysis**:

  - `glm_ica_siena.sh` : GLM for longitudinal component analysis.
  - `glm_ica_permutation.sh` : Permutation testing for longitudinal component analysis.
  - `component_plots.py` : Generates plots for component-based analyses.

