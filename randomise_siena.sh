module load fsl
unset PYTHONPATH
unset PYTHONHOME
export FSLOUTPUTTYPE=NIFTI2_GZ


fslpath="/usr/shared/apps/fsl/6.0.3/bin"
input_dir="/data/clusterfs/lag/projects/lg-ukbiobank/projects/Lucas"
output_dir="/data/clusterfs/lag/projects/lg-ukbiobank/projects/Lucas/results/randomise/siena"

nifti="merged_jac/siena/all_merged_glm_corrected.nii.gz"
design_matrix="data/pgs_siena_with_intercept.mat"
contrast="data/contrast.mat"
output="dys_autocs_pgs_siena_randomise"
mask="merged_jac/template/brain-mask-freesurfer_roi_iso_2.nii.gz"

# Ensure output directory exists
mkdir -p ${output_dir}

# Debugging: Check paths
echo "Checking input files..."
ls ${input_dir}/${nifti} || { echo "NIfTI file not found!"; exit 1; }
ls ${input_dir}/${design_matrix} || { echo "Design matrix file not found!"; exit 1; }
ls ${input_dir}/${contrast} || { echo "Contrast file not found!"; exit 1; }
ls ${input_dir}/${mask} || { echo "Mask file not found!"; exit 1; }

${fslpath}/randomise \
        -i ${input_dir}/${nifti} \
        -o ${output_dir}/${output} \
        -d ${input_dir}/${design_matrix} \
        -t ${input_dir}/${contrast} \
        -m ${input_dir}/${mask} \
	-x \
        -n 5000 \
	-T

if [ $? -eq 0 ]; then
    echo "FSL randomise completed successfully!"
    echo "Output saved to: ${output_dir}/${output}"
else
    echo "FSL randomise failed! Check inputs and logs."
    exit 1
fi

