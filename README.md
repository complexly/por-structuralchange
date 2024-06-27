# README
This repository hosts code to replicate the results of the paper "Bridging the short-term and long-term dynamics of economic structural change".

## Instructions
1. Open python folder and run notebooks in order:
    - 0_download_dataverse.ipynb
    - 1_clean data.ipynb
    - 2_llrca_var_tune.ipynb
    - 3_metric comparison.ipynb
    - 4_export_for_matlab.ipynb
    This will download and clean the main data files and produces some output figures.

    In addition the file 3.1_metric_corr_year.ipynb computes complexity metrics for every year of data. These operations are expensive, and for convenience the outputs of this notebook (region_year_rankcorr.tsv and region_year_corr.tsv) are already included in the `save` folder for use by MATLAB code.

2. Open matlab folder in MATLAB and run main.m. This will generate most of the figures and results of the manuscript.

Run with Python 3.10.10 with libraries in requirements.txt. Matlab code was executed on MATLAB R2021b.

The code applies to the main results using SITC trade data. For robustness checks with HS-based data or a different starting year, change the data downloading and analysis parameters accordingly.