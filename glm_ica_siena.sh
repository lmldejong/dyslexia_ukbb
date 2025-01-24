#!/bin/bash
module load fsl
module load gcc
module load openblas
unset PYTHONPATH
unset PYTHONHOME
#export FSLOUTPUTTYPE=NIFTI2_GZ

fslpath="/usr/shared/apps/fsl/6.0.3/bin"
input_dir="/data/clusterfs/lag/projects/lg-ukbiobank/projects/Lucas/data"
output_dir="/data/clusterfs/lag/projects/lg-ukbiobank/projects/Lucas/results/glm/siena"

ica_weights="${input_dir}/ica_weights.txt"
design_matrix="${input_dir}/pgs_ica_with_intercept.vest"
contrast="${input_dir}/contrast.mat"
output="${output_dir}/dys_autocs_pgs_siena_glm_ica"

# Ensure output directory exists
mkdir -p ${output_dir}

# Debugging: Check paths
echo "Checking input files..."
ls ${ica_weights} || { echo "ICA weights file not found!"; exit 1; }
ls ${design_matrix} || { echo "Design matrix file not found!"; exit 1; }
ls ${contrast} || { echo "Contrast file not found!"; exit 1; }

# Run FSL GLM
echo "Running FSL GLM..."
${fslpath}/fsl_glm \
       -i ${ica_weights} \
       -d ${design_matrix} \
       -c ${contrast} \
       -o ${output} \
       --out_t=${output}_tstat \
       --out_res=${output}_res \
       --out_p=${output}_pval

if [ $? -eq 0 ]; then
    echo "FSL GLM completed successfully!"
    echo "Output saved to: ${output}"
else
    echo "FSL GLM failed! Check inputs and logs."
    exit 1
fi
