# Load necessary libraries
print("Loading libraries")
.libPaths("/home/lucjon/.conda/envs/bigsnpr_env/lib/R/library")
library(bigsnpr)
library(data.table)
library(dplyr)
options(bigstatsr.check.parallel.blas = FALSE)

ukbb_genotypes_path <- "/data/clusterfs/lag/projects/lg-ukbiobank/projects/Lucas/data/big40.rds"
sumstats_PRScs <- "/data/clusterfs/lag/projects/lg-ukbiobank/projects/Lucas/data/dyslexia/pgs_calculation/"
output_path <- "/data/clusterfs/lag/projects/lg-ukbiobank/projects/Lucas/results/"

# Load PRScs summary statistics
print("Loading PRScs summary statistics..")
prscs_files <- paste0(sumstats_PRScs, "pgs_calculation_pst_eff_a1_b0.5_phiauto_chr", 1:22, ".txt")

# Combine PRScs files into one data frame
prscs_list <- lapply(prscs_files, function(file) {
  read.table(file, header = FALSE)
})
prscs_data <- do.call(rbind, prscs_list)
colnames(prscs_data) <- c('chr', 'rsid', 'pos', 'a1', 'a0', 'beta')

# Load genotypes
print("Loading genotypes")
obj.bigSNP.all <- snp_attach(ukbb_genotypes_path)

# Prepare map for matching
map <- as.data.frame(cbind(obj.bigSNP.all$map$chromosome,
                            obj.bigSNP.all$map$rsid,
                            obj.bigSNP.all$map$physical.pos,
                            obj.bigSNP.all$map$allele1,
                            obj.bigSNP.all$map$allele2))
names(map) <- c("chr", "rsid", "pos", "a0", "a1")
map$chr <- as.integer(map$chr)

# Match PRScs SNPs to SNPs in UKBB genotypes based on SNP ID (rsid)
print("Matching genotypes with PRScs SNPwise")
matched_snps <- snp_match(prscs_data, 
                            join_by_pos = FALSE,
                            map,
                            return_flip_and_rev = TRUE,
                            strand_flip = FALSE)

# Check if matched_snps contains data and the column _NUM_ID_ exists
if (is.null(matched_snps) || !"_NUM_ID_" %in% colnames(matched_snps)) {
  stop("Error: No matching SNPs found or '_NUM_ID_' column is missing.")
}

print("Calculating polygenic scores")
# Perform calculation of polygenic scores
tryCatch({
  individual_scores <- big_prodVec(obj.bigSNP.all$genotype, 
                                   matched_snps$beta, 
                                   ind.col=matched_snps$`_NUM_ID_`, 
                                   ncores=16)
  print("Polygenic scores calculated successfully.")

}, error = function(e) {
  message("Error during polygenic score calculation: ", e$message)
})

#SAVE OUTPUT IN CORRECT FORMAT
write.table(individual_scores, 
                file=paste(sep="",output_path, '/dyslexia_auto-cs.pgs'),
                quote=F,
                col.names=F,
                row.names=F)
  
