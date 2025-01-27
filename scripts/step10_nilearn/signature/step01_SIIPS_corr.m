% function step01_SIIPS()
%% Purpose of this code: to apply SIIPS to the extracted singletrials.
%% 1. load filenames as fmri_data
current_dir = pwd;
rootgroup = settings; rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = 'v7.3'; rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = 'v7.3';
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12'));
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/MasksPrivate'))
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore'));
rmpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12/external/fieldtrip/external/stats');
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/Neuroimaging_Pattern_Masks_bak/Multivariate_signature_patterns'))
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore/canlab_canonical_brains/Canonical_brains_surfaces'));

save_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/deriv01_signature/rampup_plateau/SIIPS';
singletrial_dir = fullfile('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupplateau');
if ~exist(char(fullfile(save_dir)), 'dir')
    mkdir(char(fullfile(save_dir)))
end
d = dir(singletrial_dir);
dfolders = d([d(:).isdir]);
dfolders_remove = dfolders(startsWith({dfolders.name}, 'sub-'));

key = 'stimulus';
sub_list = {dfolders_remove.name};

skipped_subjects = {};
% load siips and mask objects
% SIIPS_name = "/dartfs-hpc/rc/lab/C/CANlab/modules/Neuroimaging_Pattern_Masks/Multivariate_signature_patterns/2017_Woo_SIIPS1/nonnoc_v11_4_137subjmap_weighted_mean.nii";
SIIPS_obj = fmri_data(fmri_data(which('nonnoc_v11_4_137subjmap_weighted_mean.nii')));
refmask = fmri_data('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore/canlab_canonical_brains/Canonical_brains_surfaces/brainmask_canlab.nii');

for sub_ind = 1:length(sub_list)
    try
        output_table = [];
        sub = sub_list{sub_ind};
        disp(strcat(num2str(sub_ind), sub))
        sub = sub;    ses = '*';    run = '*';    runtype = 'pain';    event = 'stimulus';
        fname_template = fullfile(singletrial_dir, sub, ...
            strcat(sub, '_', ses, '_', run, '_runtype-', runtype, '_event-', event,'*.nii.gz'));
        fname_list = dir(fname_template);
        flist4table = {fname_list.name};
        output_table = cell2table(flist4table', 'VariableNames', {'singletrial_fname'});
        dat = fmri_data(filenames(fname_template));
        
        %% 2. load pain pathwy object
        %     [siips_values, image_names, data_objects, siipspos_exp_by_region, siipsneg_exp_by_region, siipspos, siipsneg]
        
        
        siips = resample_space(SIIPS_obj, refmask);
        siips_values = apply_mask(dat, siips,'pattern_expression', 'correlation', 'ignore_missing');
        
        output_table = table(cellstr(dat.image_names),siips_values, 'VariableNames', {'singletrial_fname', 'SIIPS'})  ;
        table_fname = fullfile(save_dir, strcat(sub,'_signature-SIIPScorr_runtype-pain_event-', event, '.csv'));
        writetable(output_table, table_fname, 'Delimiter',',');
        clear dat
    catch
        skipped_subjects{end+1} = sub;  % Log skipped subject
        warning(['Error processing subject ', sub, '. Skipping...']);
    end
end


%% Metadata details
metadata = struct();
metadata.code_name = 'step01_SIIPS_corr';
metadata.code_path = 'scripts/step10_nilearn/signature/step01_SIIPS_corr.m';
metadata.description = 'This code applies SIIPS (stimulus intensity independent pain signature-1) to extracted single trials from fMRI data, loading fMRI single-trial filenames, applying SIIPS correlations, and saving results as a CSV file.';
metadata.input_files_directory = singletrial_dir;
metadata.output_directory = save_dir;

% Convert the structure to JSON and write it to a file
output_path = fullfile(save_dir, strcat('sub-all_signature-SIIPScorr_runtype-pvc_event-', key, '.json'));%fullfile(metadata.output_directory, 'metadata.json');
json_text = jsonencode(metadata);

% Format JSON for readability (adding indentation)
% json_text = prettyjson(json_text);
pretty = regexprep(json_text, ',', ',\n');  % Newline after each item
pretty = regexprep(pretty, '\{', '{\n\t');  % Indent after opening bracket
pretty = regexprep(pretty, '\}', '\n}');
json_text = pretty;
% Write JSON to file
fid = fopen(output_path, 'w');
if fid == -1
    error('Cannot create JSON file');
end
fwrite(fid, json_text, 'char');
fclose(fid);


%% keep track of skipped subjects
skipped_file_path = fullfile(save_dir, 'signature-SIIPScorr_skipped_subjects.txt');

if ~isempty(skipped_subjects)
    % For MATLAB R2022a and newer
    writelines(skipped_subjects', skipped_file_path);  %
    
    fid = fopen(skipped_file_path, 'w');
    if fid == -1
        error('Cannot create skipped subjects file');
    end
    
    for i = 1:length(skipped_subjects)
        fprintf(fid, '%s\n', skipped_subjects{i});
    end
    
    fclose(fid);
end

disp(['Metadata JSON created at ' output_path]);

% Function to pretty print JSON (optional)
function pretty = prettyjson(json_text)
pretty = regexprep(json_text, ',', ',\n');  % Newline after each item
pretty = regexprep(pretty, '\{', '{\n\t');  % Indent after opening bracket
pretty = regexprep(pretty, '\}', '\n}');    % Newline before closing bracket
end

end