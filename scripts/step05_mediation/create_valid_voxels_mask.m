%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run to extract single trial file paths
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(genpath('./utils'));

% Define the case variable
dir_location = 'local';  % 'local' vs. 'discovery' as needed
switch dir_location
    case 'local'
        matlab_moduledir = '/Users/h/Documents/MATLAB';
        main_dir = '/Volumes/spacetop_projects_cue';
        singletrial_dir = fullfile('/Volumes/seagate/cue_singletrials/uncompressed_singletrial');
        beh_dir = '/Volumes/seagate/cue_singletrials/beh03_bids';
        NPS_fname = '/Users/h/Documents/projects_local/cue_expectancy/analysis/fmri/nilearn/deriv01_signature/rampupdown/signature-NPSpos_sub-all_runtype-pvc_event-stimulus.tsv';
        graymatter_mask = '/Users/h/Documents/MATLAB/CanlabCore/CanlabCore/canlab_canonical_brains/Canonical_brains_surfaces/gray_matter_mask.nii';
    case 'discovery'
        matlab_moduledir = '/dartfs-hpc/rc/lab/C/CANlab/modules';
        main_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue';
%         singletrial_dir = fullfile(main_dir, 'analysis','fmri','nilearn','singletrial');
        singletrial_dir = '/dartfs-hpc/scratch/f0042x1/singletrial_smooth';
        beh_dir = fullfile(main_dir, 'data', 'beh', 'beh03_bids');
        NPS_fname = fullfile(main_dir, 'analysis/fmri/nilearn/deriv01_signature/rampupdown/signature-NPSpos_sub-all_runtype-pvc_event-stimulus.tsv');
        graymatter_mask = fullfile(matlab_moduledir, 'CanlabCore/CanlabCore/canlab_canonical_brains/Canonical_brains_surfaces/gray_matter_mask.nii');
    otherwise
        error('Invalid case specified.');

end


addpath(genpath(fullfile(matlab_moduledir, 'CanlabCore')));
addpath(genpath(fullfile(matlab_moduledir,'Neuroimaging_Pattern_Masks')));
addpath(genpath(fullfile(matlab_moduledir,'MediationToolbox')));
rmpath(genpath(fullfile(matlab_moduledir,'spm12/external/fieldtrip')));
rmpath(genpath(fullfile(matlab_moduledir,'spm12/external/fieldtrip/external/stats')));

sublist = find_sublist_from_dir(singletrial_dir); % find subdirectories that start with keyword "sub-"
M = cell(1, length(sublist));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% identify good voxels vs. voxels to exclude
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. fmri_data object per subject
% - load single trials. 
% - identify non-zero non-NAN voxels ("good voxel")
% - Each participant must have at last 10 trials worth of data for a given voxel. 
% - if a voxel is zero or NaN for more than 10 trials, we drop this voxel. 
% - This results in a binary mask per participant
% - With every participant's binary mask identified, I apply a group-level threshold;
% - 50 subjects must have at least good voxels.
%
% subjectwise inclusion
sub_data = fmri_data(M{1});
threshold = 10;
mask_double = zeros(length(sub_data.dat ), length(M));
for i = 1:length(M)

    if ~isempty(M{i})
        disp('has data')
    % % Count of NON 0 or NON NaN values per row
        countsNonZeroNaN = sum(sub_data.dat ~= 0 & ~isnan(sub_data.dat), 2);
        voxels_to_include = countsNonZeroNaN > threshold;
        mask_double(:,i) = voxels_to_include;
    else
        disp(strcat('this subject ', num2str(i), ' has no data'));
        continue

    end
end
% group level inclusion
mask = sum(mask_double,2);
threshold_sub=50;
final_mask = mask > threshold_sub;
graymatter = fmri_data(which(graymatter_mask));
resampled_gray = graymatter.resample_space(sub_data);
new_graymatter_mask = (resampled_gray.dat .* final_mask) > .001;
resampled_gray.dat = new_graymatter_mask;
write(resampled_gray, 'fname', 'new_graymattermask.nii', 'overwrite');

test = fmri_data('./new_graymattermask.nii');
