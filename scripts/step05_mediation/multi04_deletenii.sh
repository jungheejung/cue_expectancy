for dir in /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/analysis/fmri/fsl/multivariate/concat_nifti/*
do
    dir=${}
    rm -rf ${dir}/*.nii
done
