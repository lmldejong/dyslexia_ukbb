#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jan  9 17:01:49 2025

@author: lucjon
"""
import os
import matplotlib.pyplot as plt
import numpy as np
os.chdir('/data/clusterfs/lag/projects/lg-ukbiobank/projects/Lucas/results/glm/siena')

# Load data from text files
data_tvals = np.loadtxt("dys_autocs_pgs_siena_glm_ica_tstat.txt")
data_pvals = np.loadtxt("dys_autocs_pgs_siena_glm_ica_pval.txt")
max_tvals = np.loadtxt("max_values.txt")
min_tvals = np.loadtxt("min_values.txt")

# Get min and max values
observed_tmax = max(data_tvals)
observed_tmin = min(data_tvals)

# Get threshold for p < 0.05
upper_threshold_05 = max_tvals[4750]
lower_threshold_05 = min_tvals[250]

# Create a figure with a black background
plt.style.use('seaborn-paper')

# Separate significant and non-significant points
significant_indices = []
significant_tvals = []
non_significant_indices = []
non_significant_tvals = []
for i in range(len(data_pvals)):
    if data_pvals[i] > 0.05:
        non_significant_indices.append(i)
        non_significant_tvals.append(data_tvals[i])
    else:
        non_significant_indices.append(i)
        non_significant_tvals.append(data_tvals[i])

# PLOT OF LONGITUDINAL COMPONENTS T-VALUES
def scatterplot():
    """Plots scatterplot of the longitudinal component analysis"""
    plt.figure(figsize=(10, 6))
    
    # Plot non-significant points as crosses
    plt.scatter(
        non_significant_indices,
        non_significant_tvals,
        color="magenta",
        marker="x",
        alpha=0.8,
        label="IC/PC (p > 0.05)"
    )
    
    # Plot significant points as dots
    if len(significant_indices) > 0:
        plt.scatter(
            significant_indices,
            significant_tvals,
            c="cyan blue",
            cmap="viridis",
            edgecolor="white",
            s=50,
            label="Significant (p ≤ 0.05)"
        )
    
    # Add color bar for p-values of significant points
    if len(significant_indices) > 0:
        cbar = plt.colorbar()
        cbar.set_label("P-Value", rotation=270, labelpad=15)
    
    plt.axhline(max(data_tvals), color='blue', linestyle='dashed', linewidth=0.7, label="observed max t-value")
    plt.axhline(upper_threshold_05, color='blue', linestyle='-', linewidth=0.7, label="p<0.05 threshold")
    plt.axhline(min(data_tvals), color='red', linestyle='dashed', linewidth=0.7, label="observed min t-value")
    plt.axhline(lower_threshold_05, color='red', linestyle='-', linewidth=0.7, label="p<0.05 threshold")
    
    # Labels, legend, and title
    plt.xlabel("Component index", fontsize=12)
    plt.ylabel("T-Value", fontsize=12)
    plt.title("Longitudinal component analysis", pad=15, fontsize=14)
    plt.xlim([-10,850])
    plt.ylim([-5,6.5])
    plt.legend(loc="upper right", fontsize="medium")
    
    # Show or save the plot
    plt.savefig("/home/lucjon/Renders/significant_vs_non_significant_tvalues.png", dpi=600, bbox_inches="tight")
    plt.show()

# PLOT OF PERMUTATION DISTRIBUTION
def permutationplot():
    plt.figure(figsize=(10, 6))
    """Plots histogram of permutation test"""
    # Plot histograms
    plt.hist(max_tvals, bins=50, alpha=0.7, label="permuted max t-value", color='cyan')
    plt.hist(min_tvals, bins=50, alpha=0.7, label="permuted min t-value", color='magenta')
    plt.axvline(max(data_tvals), color='blue', linestyle='dashed', linewidth=0.7, label="observed max t-value")
    plt.axvline(upper_threshold_05, color='blue', linestyle='-', linewidth=0.7, label="p<0.05 threshold")
    plt.axvline(min(data_tvals), color='red', linestyle='dashed', linewidth=0.7, label="observed min t-value")
    plt.axvline(lower_threshold_05, color='red', linestyle='-', linewidth=0.7, label="p<0.05 threshold")
    
    plt.xlim([-5,5])
    plt.ylim([0,400])
    
    # Add labels and title
    plt.xlabel("T-value", fontsize=12)
    plt.ylabel("Count", fontsize=12)
    plt.title("Empirical distributions of component analysis", pad=15, fontsize=14)
    
    # Add legend
    plt.legend(loc="upper center", fontsize="medium")
    
    # Save the plot or display it
    plt.savefig("/home/lucjon/Renders/ICA_histograms_with_stats_white.png", dpi=600, bbox_inches="tight")
    plt.show()
    
permutationplot()
scatterplot()