function s00_smooth_8mm(input)
%-----------------------------------------------------------------------
% Job saved on 08-Jul-2021 21:03:45 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

disp(input);

% sub_num = sscanf(char(input),'%d');
% sub = strcat('sub-', sprintf('%04d', sub_num));
% disp(strcat('subject: ', sub));

% fmriprep_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/dartmouth/fmriprep/fmriprep/';
% main_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/';
addpath('/optnfs/el7/spm/spm12'); 
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore')); 
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step04_SPM'));
main_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social';
% main_dir = '/Volumes/spacetop_projects_social/'
% output_dir = fullfile(main_dir,'analysis', 'fmri', 'spm', 'model-01_CcEScaA',...
%     '1stLevel',sub);
sub_list = [2,3,4,5,6,7,8,9,10,14,15,16,18,19,20,21,23,24,25,26,28,29,30,31,32,33,35]

for sub_num = 1:length(sub_list)
    
    sub = strcat('sub-', sprintf('%04d', sub_list(sub_num)));
    disp(strcat('STARTING SMOOTHING:', sub));
    output_dir = fullfile(main_dir,'analysis', 'fmri', 'fsl', 'multivariate',...
        'concat_nifti',sub);
    if ~exist(output_dir, 'dir')
        mkdir(output_dir)
    end
    nii_fname = fullfile(output_dir, strcat(sub,'_task-general_ev-cue.nii'));
    scan_fname = fullfile(output_dir, strcat(sub,'_task-general_ev-cue.nii.gz'));
    if ~exist(nii_fname,'file'), gunzip(scan_fname)
    end
  
    scans = spm_select('Expand',nii_fname);
    matlabbatch{1}.spm.spatial.smooth.data = cellstr(scans);
    matlabbatch{1}.spm.spatial.smooth.fwhm = [8 8 8];
    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
    matlabbatch{1}.spm.spatial.smooth.im = 0;
    matlabbatch{1}.spm.spatial.smooth.prefix = 'smooth_8mm_';
    
    spm_jobman('run',matlabbatch);
    clearvars matlabbatch
    disp(strcat('FINISH - subject complete'))
end


% end

