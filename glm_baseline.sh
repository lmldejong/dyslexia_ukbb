#!/bin/bash
module load fsl
module load gcc
module load openblas
unset PYTHONPATH
unset PYTHONHOME
export FSLOUTPUTTYPE=NIFTI2_GZ

fslpath="/usr/shared/apps/fsl/6.0.3/bin"
input_dir="/data/clusterfs/lag/projects/lg-ukbiobank/projects/Lucas"
output_dir="/data/clusterfs/lag/projects/lg-ukbiobank/projects/Lucas/results/glm/baseline"

nifti="merged_jac/baseline/all_merged_glm_corrected.nii.gz"
design_matrix="data/pgs_baseline_with_intercept.txt"
contrast="data/contrast.mat"
output="dys_autocs_pgs_baseline_glm"
mask="merged_jac/template/brain-mask-freesurfer_roi_iso_2.nii.gz"

# Ensure output directory exists
mkdir -p ${output_dir}

# Debugging: Check paths
echo "Checking input files..."
ls ${input_dir}/${nifti} || { echo "NIfTI file not found!"; exit 1; }
ls ${input_dir}/${design_matrix} || { echo "Design matrix file not found!"; exit 1; }
ls ${input_dir}/${contrast} || { echo "Contrast file not found!"; exit 1; }
ls ${input_dir}/${mask} || { echo "Mask file not found!"; exit 1; }

# Run FSL GLM
echo "Running FSL GLM..."
${fslpath}/fsl_glm \
       -i ${input_dir}/${nifti} \
       -d ${input_dir}/${design_matrix} \
       -c ${input_dir}/${contrast} \
       -o ${output_dir}/${output}.nii.gz \
       -m ${input_dir}/${mask} \
       --out_t=${output_dir}/${output}_tstat.nii.gz \
       --out_z=${output_dir}/${output}_zstat.nii.gz \
       --out_res=${output_dir}/${output}_res.nii.gz \
       --out_p=${output_dir}/${output}_pval.nii.gz

if [ $? -eq 0 ]; then
    echo "FSL GLM completed successfully!"
    echo "Output saved to: ${output_dir}/${output}"
else
    echo "FSL GLM failed! Check inputs and logs."
    exit 1
fi

