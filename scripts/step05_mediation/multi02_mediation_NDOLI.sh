#!/bin/bash -l


CANLABCORE_DIR="/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore"
SCRIPT_DIR=${PWD}

module load matlab/r2020a
matlab -nodesktop -nosplash -batch "opengl('save','hardware'); rootgroup = settings; rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = 'v7.3'; rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = 'v7.3'; addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/MediationToolbox')); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore')); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12')); rmpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12/external/fieldtrip/external/stats'); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step05_mediation')); multi02_mediation"

echo "matlab -nodesktop -nosplash -batch 'opengl('save','hardware'); rootgroup = settings; rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = 'v7.3'; rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = 'v7.3';  addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/MediationToolbox'));addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore'));addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12'));rmpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12/external/fieldtrip/external/stats');addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step05_mediation')); multi02_mediation"
