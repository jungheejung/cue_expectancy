function step02_apply_NPS()
% TODO:
%% 1. Data directories and parameters
current_dir = pwd;
main_dir = fileparts(fileparts(current_dir));
% sub-0060_ses-04_run-05_runtype-pain_event-stimulus_trial-000_cuetype-low_stimintensity-high.nii.gz
% sub-0060_ses-04_run-06_runtype-cognitive_event-stimulus_trial-000_cuetype-low_stimintensity-high.nii.gz

%% 2. test run
% main_dir = '/Volumes/spacetop_projects_social';
SINGLETRIALDIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupplateau"
SAVEDIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/deriv01_signature/rampup_plateau"

singletrial_dir = fullfile(main_dir, 'analysis', 'fmri', 'nilearn', 'singletrial_rampupplateau');
% nps_dir = fullfile(main_dir, 'analysis', 'fmri', 'nilearn', 'signature_canlabcore');
d = dir(singletrial_dir);
dfolders = d([d(:).isdir]);
dfolders_remove = dfolders(~ismember({dfolders(:).name},{'.','..','sub-0000','sub-0002'}));
sub_list = {dfolders_remove.name};
key_list = {'cue', 'stimulus'};
% sub = char(sub_list(input));
sub = sub_list[slurm_id];
ses = '*';    run = '*';    runtype = '*';    event = 'stimulus';
tableData = [];
% for s = 1:length(sub_list)
%     sub = char(sub_list(s));
for k = 1:length(key_list)
    
    key = char(key_list(k));
    dat = [];
    meta_nifti = [];
    % glob all files
    test_file = dir(fullfile(singletrial_dir, sub, ...
        strcat(sub, '_', ses, '_', run, '_runtype-', runtype, '_event-', key,'*.nii.gz')));
    flist4table = {test_file.name};
    output_table = cell2table(flist4table', "VariableNames",  ["singletrial_fname"]);
    
    [nps_values,image_names, ~, npspos_exp_by_region, npsneg_exp_by_region] = apply_nps(data_objects);
    % tabld =
    tableData = [tableData; {image_names, nps_values, sum(npspos_exp_by_region), sum(npsneg_exp_by_region)}];
end
output_table = cell2table(tableData, 'VariableNames', {'singletrial_fname', 'NPS_dotproduct', 'NPSpos', 'NPSneg'});

%% Save the table to a file (optional)
writetable(output_table, fullfile(nps_dir, strcat('nps_results.csv')));
end