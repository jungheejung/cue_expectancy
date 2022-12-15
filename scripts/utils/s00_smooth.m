function s00_smooth(input, fmriprep_dir,smooth_savedir, main_dir )
%-----------------------------------------------------------------------
% Job saved on 08-Jul-2021 21:03:45 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

disp(input);
sub_num = input;
%sub_num = sscanf(char(input),'%d');
sub = strcat('sub-', sprintf('%04d', sub_num));

disp(strcat('subject: ', sub));
% fmriprep_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/fmriprep'
% fmriprep_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/dartmouth/fmriprep/fmriprep/';
% smooth_savedir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/analysis/fmri/smooth6mm';
% main_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/';
% main_dir = fileparts(fileparts(pwd)); %'/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social';
filelist = dir(fullfile(fmriprep_dir, sub, '*/func/*task-social*_bold.nii.gz'));
T = struct2table(filelist);
sortedT = sortrows(T, 'name');
% if smooth file not exist, 
% add it to the queue and smooth

for run_ind = 1: size(sortedT,1)
    sub_num = sscanf(char(extractBetween(sortedT.name(run_ind), 'sub-', '_')),'%d'); sub = strcat('sub-', sprintf('%04d', sub_num));
    ses_num = sscanf(char(extractBetween(sortedT.name(run_ind), 'ses-', '_')),'%d'); ses = strcat('ses-', sprintf('%02d', ses_num));
    run_num = sscanf(char(extractBetween(sortedT.name(run_ind), 'run-', '_')),'%d'); run = strcat('run-', sprintf('%01d', run_num));
    
    scan_fname = fullfile(fmriprep_dir, sub, ses, 'func',...
        strcat(sub, '_', ses, '_task-social_acq-mb8_', run, '_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'));
    nii_fname = fullfile(fmriprep_dir, sub, ses, 'func',...
        strcat(sub, '_', ses, '_task-social_acq-mb8_', run, '_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'));
    if ~exist(nii_fname,'file'), gunzip(scan_fname)
    end
    
    scans = spm_select('Expand',nii_fname);
    matlabbatch{1}.spm.spatial.smooth.data = cellstr(scans);
    matlabbatch{1}.spm.spatial.smooth.fwhm = [6 6 6];
    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
    matlabbatch{1}.spm.spatial.smooth.im = 0;
    matlabbatch{1}.spm.spatial.smooth.prefix = 'smooth-6mm_';
    
    spm_jobman('run',matlabbatch);
    clearvars matlabbatch
    
end

disp(strcat('FINISH - subject complete'))
end

