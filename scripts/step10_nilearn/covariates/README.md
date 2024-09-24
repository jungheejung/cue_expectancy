# Overview
Main question: Q. what are the neural correlates of prediction errors, stimulus effects and cue effects?
Methods: parametric modulation, using the single trials. 

# Analysis

1. run `step01_singletrial_SLURM_PE.sh` which is a wrapper for `step01_singletrial_PE.py`
NOTE: input required: `data/RL/July2024_Heejung_fMRI_paper/table_pain.csv`
2. run `step02_singletrial_PE.ipynb` for t-test visualization and saving t maps
NOTE: figure outputs are saved in `/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/deriv04_covariate/cov_PE/pain`
3. run `step03_singletrial_covPE_plot.ipynb` for 
