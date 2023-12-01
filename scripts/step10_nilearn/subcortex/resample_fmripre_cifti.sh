wb_command -cifti-resample
      <cifti-in> - the cifti file to resample
      <direction> - the direction of the input that should be resampled, ROW or
         COLUMN
      <cifti-template> - a cifti file containing the cifti space to resample to
      <template-direction> - the direction of the template to use as the
         resampling space, ROW or COLUMN
      <surface-method> - specify a surface resampling method
      <volume-method> - specify a volume interpolation method
      <cifti-out> - output - the output cifti file
CIFTIIN=/Users/h/Documents/projects_local/sandbox/fmriprep_bold/surface/sub-0061_ses-01_task-social_acq-mb8_run-1_space-fsLR_den-91k_bold.dtseries.nii

# wb_command -cifti-resample ${CIFTIIN} ROW ${CIFTITEMPLATE} ROW 
wb_command -cifti-resample ${CIFTIIN} COLUMN -nvertices 10242 -new-nifti output_resample.nii.gz

# convert to freesurfer
wb_command -cifti-convert -to-gifti-ext  ${CIFTIIN} output.func.gii
