#Files from /data/clusterfs/lag/projects/lg-ukbiobank/projects/Lucas/data
import os
import matplotlib.pyplot as plt
import numpy as np
os.chdir('/data/clusterfs/lag/projects/lg-ukbiobank/projects/Lucas/data')

# Load data from text files
baseline_file = "pgs_baseline.txt"
siena_file = "pgs_siena.txt"

# Load the data assuming one value per line
data_baseline = np.loadtxt(baseline_file)
data_siena = np.loadtxt(siena_file)

# Combine both datasets for overall statistics
data = np.append(data_baseline, data_siena)
mean_data = np.mean(data)
std_data = np.std(data)


print(f"Mean: \t\t\t\t\t{mean_data}")
print(f"Standard Deviation: \t{std_data}")
print(f"Mean difference: \t\t{np.mean(data_baseline)-np.mean(data_siena)}")
print(f"SD difference: \t\t\t{np.std(data_baseline)-np.std(data_siena)}")


def PGShistogram():
    plt.figure(figsize=(10, 6))
    # Create a figure with a black background
    # plt.style.use('dark_background')
    plt.style.use('seaborn-paper')
    plt.axvline(x=-1, color='red', linestyle='--', linewidth=1, alpha = 0.4, label = 'mean')
    plt.axvline(x=-1, color='blue', linestyle='--', linewidth=1, alpha = 0.4, label = '$\pm\sigma$')
    # Plot histograms
    plt.hist(data_baseline, bins=130, alpha=0.7, label="Cross-sectional (n=37493)", color="cyan")
    plt.hist(data_siena, bins=130, alpha=0.7, label="Longitudinal (n=4186)", color="magenta")
    
    # Add lines for mean and mean ± 1, 2, 3 standard deviations
    x_values = [mean_data, mean_data + std_data, mean_data - std_data,
                mean_data + 2 * std_data, mean_data - 2 * std_data,
                mean_data + 3 * std_data, mean_data - 3 * std_data]
    colors = ["red", "blue", "blue", "blue", "blue", "blue", "blue"]
    labels = ["Mean", "+1σ", "-1σ", "+2σ", "-2σ", "+3σ", "-3σ"]
    
    for x, color, label in zip(x_values, colors, labels):
        plt.axvline(x=x, color=color, linestyle='--', linewidth=1, alpha = 0.4)
        
    
    
    # Add labels and title
    plt.xlabel("Value", fontsize=12)
    plt.ylabel("Frequency", fontsize=12)
    plt.xlim([-0.17,0.43])
    plt.title("Distribution of dyslexia polygenic scores", pad=15, fontsize=14)
    
    # Add legend
    plt.legend(loc="upper right", fontsize="medium")
    
    # Save the plot or display it
    plt.savefig("/home/lucjon/Renders/pgs_histograms_with_stats_white.png", dpi=600, bbox_inches="tight")
    plt.show()

PGShistogram()
