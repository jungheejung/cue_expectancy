function step02_extract_ROI_cueepoch(event)
%% Extract pain-pathway ROI averages from CUE-EPOCH single-trial betas.
% Cue-epoch twin of step02_extract_ROI.m. The ONLY substantive change is
% event = 'cue' (default) instead of 'stimulus'; exposed as an optional
% argument so this one function covers both epochs. Atlas, ROI list, averaging
% ('unique_mask_values','nonorm'), flattening, and output format are identical
% to the stimulus-epoch pipeline, so the cue-epoch ROI file is directly
% comparable to roi-painpathway_..._event-stimulus.tsv.
%
% Run on the server where CANlab tools + single-trial betas live.
%   step02_extract_ROI_cueepoch          % event = 'cue'
%   step02_extract_ROI_cueepoch('stimulus')
% Output: roi-painpathway_sub-all_runtype-pvc_event-cue.tsv

if nargin < 1 || isempty(event)
    event = 'cue';
end

%% 1. load filenames as fmri_data
current_dir = pwd;
main_dir = fileparts(fileparts(fileparts(current_dir)));
singletrial_dir = fullfile(main_dir, 'analysis', 'fmri', 'nilearn', 'singletrial_rampupplateau');
output_dir = fullfile(main_dir, 'analysis', 'fmri', 'nilearn', 'deriv01_signature', 'rampup_plateau_painpathway');
if ~exist(output_dir, 'dir'); mkdir(output_dir); end

sub = '*'; ses = '*'; run = '*'; runtype = '*';
fname_template = fullfile(singletrial_dir, sub, ...
    strcat(sub, '_', ses, '_', run, '_runtype-', runtype, '_event-', event, '*.nii.gz'));
fname_list = dir(fname_template);
assert(~isempty(fname_list), 'no *_event-%s* single trials under %s', event, singletrial_dir);
flist4table = {fname_list.name};
output_table = cell2table(flist4table', "VariableNames", ["singletrial_fname"]);

dat = fmri_data(filenames(fname_template));

%% 2. load pain pathway atlas + extract per-ROI averages (flattened L/R)
roi_name = {'Thal_VPLM','Thal_IL','Thal_MD', ...
    'Hythal','pbn','Bstem_PAG','rvm','Amy','dpIns','S2','mIns', ...
    'aIns','aMCC_MPFC','s1_foot','s1_handplus'};
pain_pathways = load_atlas(which('pain_pathways_atlas_obj.mat'));
for roi_ind = 1:length(roi_name)
    roi = pain_pathways.select_atlas_subset({roi_name{roi_ind}}, 'flatten');
    pain_pathways_mean = extract_roi_averages(dat, fmri_data(roi), 'unique_mask_values', 'nonorm');
    output_table = [ table(pain_pathways_mean.dat, 'VariableNames', roi.labels)  output_table ];
end
table_fname = fullfile(output_dir, strcat('roi-painpathway_sub-all_runtype-pvc_event-', event, '.tsv'));
writetable(output_table, table_fname, 'FileType', 'text', 'Delimiter', '\t');
fprintf('wrote %s\n', table_fname);

%% 3. metadata
json.code_generated = "scripts/step10_nilearn/singletrialLSS/step02_extract_ROI_cueepoch.m";
json.event = event;
json.input_data = singletrial_dir;
json.atlas = "CANlab pain pathway object - Neuroimaging_Pattern_Masks/Atlases_and_parcellations/2019_Wager_pain_pathways/pain_pathways_atlas_obj.mat";
json.matlab_functions = {"CanlabCore", ...
    "CanlabCore/@atlas/select_atlas_subset", ...
    "CanlabCore/@image_vector/extract_roi_averages", ...
    "CanlabCore/Data_extraction/load_atlas"};
fid = fopen(fullfile(output_dir, strcat('extract_painpathway_event-', event, '.json')), 'w');
fwrite(fid, jsonencode(json), 'char'); fclose(fid);
end
