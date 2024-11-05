function step01_SIIPS()
%% Purpose of this code: to apply SIIPS to the extracted singletrials.
%% 1. load filenames as fmri_data
current_dir = pwd;
nps_dir = '/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/deriv01_signature/rampup_plateau_canlab_corr';
singletrial_dir = fullfile('/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupplateau');

d = dir(singletrial_dir);
dfolders = d([d(:).isdir]);
dfolders_remove = dfolders(startsWith({dfolders.name}, 'sub-'));

key = 'stimulus';
sub_list = {dfolders_remove.name};
for sub_ind = 52:length(sub_list)
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
    
    SIIPS_name = which("nonnoc_v11_4_137subjmap_weighted_mean.nii");
    siips_values = apply_mask(dat, fmri_data(SIIPS_name), 'correlation', 'ignore_missing');
    %     SIIPS_mean = extract_roi_averages(dat, fmri_data(SIIPS_name), 'unique_mask_values', 'nonorm');
    % output_table
    output_table = table( cellstr(dat.image_names),siips_values, 'VariableNames', {'singletrial_fname', 'SIIPS'})  ;
    table_fname = fullfile(nps_dir, strcat(sub,'_roi-SIIPS_runtype-pain_event-', event, '.csv'));
    writetable(output_table, table_fname, 'Delimiter',',');
end


% Metadata details
metadata = struct();
metadata.code_name = 'step01_SIIPS_corr';
metadata.code_path = 'scripts/step10_nilearn/signature/step01_SIIPS_corr.m';
metadata.description = 'This code applies SIIPS (Social Influence of Pain Scale) to extracted single trials from fMRI data, loading fMRI single-trial filenames, applying SIIPS correlations, and saving results as a CSV file.';
metadata.input_files_directory = '/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupplateau';
metadata.output_directory = '/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/deriv01_signature/rampup_plateau_canlab_corr';

% Convert the structure to JSON and write it to a file
output_path = fullfile(metadata.output_directory, 'TODOmetadata.json');
json_text = jsonencode(metadata);

% Format JSON for readability (adding indentation)
json_text = prettyjson(json_text);

% Write JSON to file
fid = fopen(output_path, 'w');
if fid == -1
    error('Cannot create JSON file');
end
fwrite(fid, json_text, 'char');
fclose(fid);

disp(['Metadata JSON created at ' output_path]);

% Function to pretty print JSON (optional)
    function pretty = prettyjson(json_text)
        pretty = regexprep(json_text, ',', ',\n');  % Newline after each item
        pretty = regexprep(pretty, '\{', '{\n\t');  % Indent after opening bracket
        pretty = regexprep(pretty, '\}', '\n}');    % Newline before closing bracket
    end

end