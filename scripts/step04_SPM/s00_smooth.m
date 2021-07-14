function s00_smooth(input)
%-----------------------------------------------------------------------
% Job saved on 08-Jul-2021 21:03:45 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

disp(input);

sub_num = sscanf(char(input),'%d');
sub = strcat('sub-', sprintf('%04d', sub_num));
disp(strcat('subject: ', sub));

fmriprep_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/dartmouth/fmriprep/fmriprep/';
main_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/';
output_dir = fullfile(main_dir,'analysis', 'fmri', 'spm', 'model-01_CcEScaA',...
    '1stLevel',sub);
if ~exist(output_dir, 'dir')
    mkdir(output_dir)
end
filelist = dir(fullfile(fmriprep_dir, sub, '*/func/*task-social*_bold.nii.gz'));
T = struct2table(filelist);
sortedT = sortrows(T, 'name');

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
    matlabbatch{1}.spm.spatial.smooth.fwhm = [5 5 5];
    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
    matlabbatch{1}.spm.spatial.smooth.im = 0;
    matlabbatch{1}.spm.spatial.smooth.prefix = 'smooth_5mm_';
    
    batch_fname = fullfile(output_dir, strcat(strcat(sub, '_smoothbatch.mat')));
    save( batch_fname  ,'matlabbatch');
    spm_jobman('run',matlabbatch);
    clearvars matlabbatch
    
end

disp(strcat('FINISH - subject complete'))
end

