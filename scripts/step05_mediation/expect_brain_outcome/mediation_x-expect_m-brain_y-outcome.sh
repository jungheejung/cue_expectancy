
#!/bin/bash -l
#SBATCH --job-name=med
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=24:00:00
#SBATCH -o /dartfs-hpc/scratch/f0042x1/log_mediation/medM_%A_%a.o
#SBATCH -e /dartfs-hpc/scratch/f0042x1/log_mediation/medM_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard

CANLABCORE_DIR="'/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore'"
SPM12_DIR="'/dartfs-hpc/rc/lab/C/CANlab/modules/spm12'"

module load matlab/r2022a

matlab -nodisplay -nosplash -batch "opengl('save','hardware'); rootgroup = settings; rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = 'v7.3'; rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = 'v7.3';  addpath(${SPM12_DIR}); addpath(genpath(${CANLABCORE_DIR})); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/MediationToolbox')); ./med2023_mediation_x_expect_m_brain_y_outcome_discovery"
