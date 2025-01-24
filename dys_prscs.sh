#!/bin/bash

echo 'export PATH="/data/clusterfs/lag/projects/lg-ukbiobank/projects/Lucas/software/parallel/bin:$PATH"' >> /home/lucjon/.bashrc
source /home/lucjon/.bashrc

cluster_directory="/data/clusterfs/lag/projects/lg-ukbiobank/projects/Lucas"
workspace_directory="/data/workspaces/lag/workspaces/lg-ukbiobank/projects/Lucas"

index=$1
node_cores=$(lscpu | awk '$1=="CPU(s):"{print $2}' | awk '{if ($1 - 10 > 22) print 22; else print $1 - 10}')
node_mem=$(free -g|awk 'NR==2{print $2}')
node_free_mem=$(free -g|awk 'NR==2{print $4}')

module load anaconda/3.2021.05
module load python/3.9.4
. ~/.bashrc

n_sample=1138870

chromosomes=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22")
phi_value=("1e-6" "1e-4" "1e-2" "1" "auto")

run_prscs() {
    local chrom=$1

    echo "Processing chromosome $chrom"

    python3 /home/lucjon/PRScs/PRScs.py \
        --ref_dir=/data/clusterfs/lag/projects/lg-ukbiobank/projects/Lucas/data/ldblk_ukbb_eur \
        --bim_prefix=/data/clusterfs/lag/projects/lg-ukbiobank/projects/Lucas/data/big40 \
        --sst_file=/data/clusterfs/lag/projects/lg-ukbiobank/projects/Lucas/data/dyslexia/preprocessed/dys-sumstats-preproc.txt \
        --n_gwas=1138870 \
	--n_iter=5000
 	--phi=$phi_values
        --out_dir=/data/clusterfs/lag/projects/lg-ukbiobank/projects/Lucas/data/pgs_calculation/5k_ \
        --chrom=$chrom

    echo "Chromosome $chrom processing completed."
}

export -f run_prscs 

parallel -j "$node_cores" run_prscs {1} ::: "${chromosomes[@]}"

echo "PRS calculation completed, results can be found in $cluster_directory/data/pgs_calculation."
~                                 
