#!/bin/bash
module load fsl
module load gcc
module load openblas
unset PYTHONPATH
unset PYTHONHOME

# Paths
fslpath="/usr/shared/apps/fsl/6.0.3/bin"
input_dir="/data/clusterfs/lag/projects/lg-ukbiobank/projects/Lucas/data"
output_dir="/data/clusterfs/lag/projects/lg-ukbiobank/projects/Lucas/results/glm/siena/permutations"

ica_weights="${input_dir}/ica_weights.txt"
design_matrix="${input_dir}/pgs_ica_with_intercept.vest"
contrast="${input_dir}/contrast.mat"
output="${output_dir}/dys_autocs_pgs_siena_glm_ica"
temp_weights="${output_dir}/temp_ica_weights.txt"
tvals_csv="${output_dir}/tvals_h0_siena.csv"

# Ensure output directory exists
mkdir -p ${output_dir}

# Debugging: Check paths
echo "Checking input files..."
ls ${ica_weights} || { echo "ICA weights file not found!"; exit 1; }
ls ${design_matrix} || { echo "Design matrix file not found!"; exit 1; }
ls ${contrast} || { echo "Contrast file not found!"; exit 1; }

# Initialize CSV file
echo "min_tval,max_tval" > ${tvals_csv}

# Run 5000 permutations
echo "Starting permutations..."
for ((i=1; i<=5000; i++)); do
    echo "Permutation $i..."

    # Permute ICA weights
    shuf ${ica_weights} > ${temp_weights}

    # Run FSL GLM with permuted weights
    ${fslpath}/fsl_glm \
        -i ${temp_weights} \
        -d ${design_matrix} \
        -c ${contrast} \
        -o ${output}_perm_${i} \
        --out_t=${output}_perm_${i}_tstat 

    if [ $? -eq 0 ]; then
        echo "FSL GLM for permutation $i completed successfully."

        # Extract minimum and maximum t-values
        min_tval=$(cat t_vaules.txt.file |sed 's/ /\n/g'|sort -k1,1 -g|head -n 1) 
        max_tval=$(cat t_vaules.txt.file |sed 's/ /\n/g'|sort -k1,1 -g|tail -n 1) 

        # Append to CSV
        echo "${min_tval},${max_tval}" >> ${tvals_csv}
    else
        echo "FSL GLM failed for permutation $i! Skipping..."
    fi
done

# Cleanup
rm -f ${temp_weights}

echo "Permutations completed! Results saved to: ${tvals_csv}"
