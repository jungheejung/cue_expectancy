function estimation(input)

fmriprep_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/dartmouth/fmriprep/fmriprep/'; % sub / ses
main_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/';
motion_dir = fullfile(main_dir, 'data', 'dartmouth', 'd05_motion');
onset_dir = fullfile(main_dir, 'data', 'dartmouth', 'd04_EV_SPM');

sub_num = sscanf(char(input),'%d');
sub = strcat('sub-', sprintf('%04d', sub_num));

output_dir = fullfile(main_dir,'analysis', 'fmri', 'spm', 'model-01_CcEScaA',...
'1stLevel', sub);

matlabbatch = cell(1,1);


disp(strcat('[ STEP 07 ] estimation '))
SPM_fname= fullfile(output_dir, 'SPM.mat' );
matlabbatch{1}.spm.stats.fmri_est.spmmat = cellstr(SPM_fname);
matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;

batch_fname = fullfile(output_dir, strcat(strcat(sub, '_estimation.mat')));
save( batch_fname  ,'matlabbatch');

%% 4. run __________________________________________________________
spm_jobman('run',matlabbatch);
clearvars matlabbatch

disp(strcat('FINISH - subject complete'))
end
