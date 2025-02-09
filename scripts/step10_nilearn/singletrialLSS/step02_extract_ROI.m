function step02_extract_ROI()
%% Extract ROI beta weights for pain pathways from single-trial fMRI data
% This function applies the Wager pain pathway atlas to extract beta weights
% from preprocessed single-trial fMRI data. The extracted values are saved
% in a TSV file along with metadata in a JSON file.
% PATH of pain pathway: Neuroimaging_Pattern_Masks/Atlases_and_parcellations/2019_Wager_pain_pathways/pain_pathways_atlas_obj.mat

%% 1. load filenames as fmri_data
current_dir = pwd;
main_dir = fileparts(fileparts(fileparts(current_dir)));
singletrial_dir = fullfile(main_dir, 'analysis', 'fmri', 'nilearn', 'singletrial_rampupplateau');
output_dir = fullfile(main_dir, 'analysis', 'fmri', 'deriv01_signature', 'rampup_plateau_painpathway');
d = dir(singletrial_dir);
dfolders = d([d(:).isdir]);
dfolders_remove = dfolders(~ismember({dfolders(:).name},{'.','..','sub-0000','sub-0002'}));
sub_list = {dfolders_remove.name};
sub = '*';    ses = '*';    run = '*';    runtype = '*';    event = 'stimulus';
fname_template = fullfile(singletrial_dir, sub, ...
    strcat(sub, '_', ses, '_', run, '_runtype-', runtype, '_event-', event,'*.nii.gz'));
fname_list = dir(fname_template);
flist4table = {fname_list.name};
output_table = cell2table(flist4table', "VariableNames",  ["singletrial_fname"]);

dat = fmri_data(filenames(fname_template));
%% 2. load pain pathwy object
roi_name = {'Thal_VPLM','Thal_IL','Thal_MD',...
    'Hythal','pbn','Bstem_PAG','rvm','Amy','dpIns','S2','mIns',...
    'aIns','aMCC_MPFC','s1_foot','s1_handplus'};
pain_pathways = load_atlas(which('pain_pathways_atlas_obj.mat'));
for roi_ind = 1:length(roi_name)
    roi = pain_pathways.select_atlas_subset({roi_name{roi_ind}}, 'flatten');
    pain_pathways_mean = extract_roi_averages(dat, fmri_data(roi), 'unique_mask_values', 'nonorm');
    output_table = [ table(pain_pathways_mean.dat, 'VariableNames', roi.labels)  output_table];
end
table_fname = fullfile(output_dir, strcat('roi-painpathway_sub-all_runtype-pvc_event-', event, '.tsv'));
writetable(output_table, table_fname, 'FileType', 'text', 'Delimiter', '\t');

% pain_pathways = pain_pathways.select_atlas_subset({'Thal_VPLM_R','Thal_VPLM_L','Thal_IL','Thal_MD',...
% 'Hythal','pbn_R','pbn_L','Bstem_PAG','rvm_R','Amy_R','Amy_L','dpIns_L','dpIns_R','S2_L','S2_R','mIns_L','mIns_R',...
% 'aIns_L','aIns_R','aMCC_MPFC','s1_foot_L','s1_foot_R','s1_handplus_L','s1_handplus_R'});
% pain_pathways = pain_pathways.select_atlas_subset({'Thal_VPLM','Thal_IL','Thal_MD',...
% 'Hythal','pbn','Bstem_PAG','rvm','Amy','dpIns','S2','mIns',...
% 'aIns','aMCC_MPFC','s1_foot','s1_handplus'}, );
% pain_pathways_mean = extract_roi_averages(dat, fmri_data(pain_pathways), 'unique_mask_values', 'nonorm');


%% 3. Save metadata (json)
json.code_generated = "scripts/step10_nilearn/singletrialLSS/step02_extract_ROI.m";
json.input_data = singletrial_dir;
json.atlas = "CANlab pain pathway object - Neuroimaging_Pattern_Masks/Atlases_and_parcellations/2019_Wager_pain_pathways/pain_pathways_atlas_obj.mat";
json.matlab_functions = {
    "CanlabCore", ...
    "CanlabCore/@atlas/select_atlas_subset", ...
    "CanlabCore/@image_vector/extract_roi_averages", ...
    "CanlabCore/Data_extraction/load_atlas" ...
    };

jsonStr = jsonencode(json);
jsonFilename = fullfile(output_dir, 'extract_painpathway.json');

% Write JSON to file
fid = fopen(jsonFilename, 'w');
if fid == -1
    error('Cannot create JSON file.');
end
fwrite(fid, jsonStr, 'char');
fclose(fid);

fprintf('JSON file saved: %s\n', jsonFilename);
