function step02_applysignature_cueepoch(event)
%% Apply NPS + SIIPS as weighted PATTERNS to cue-epoch single-trial betas.
% CANlab convention, mirroring s04_applyNPS_spmglm.m:
%     apply_mask(dat, weights, 'pattern_expression', 'ignore_missing')
% i.e. the weighted dot product (pattern expression), plus correlation and
% cosine-similarity variants -- the same three metrics that produce the
% nps / nps_corr / nps_cosine columns in the existing stim-epoch files, so the
% cue-epoch output is directly comparable.
%
% IMPORTANT: signatures are weighted patterns -> pattern_expression, NOT
% extract_roi_averages (which would give an unweighted mean and discard the
% SIIPS/NPS weights). extract_roi_averages is only for the unweighted
% pain-pathway ROIs (see step02_extract_ROI_cueepoch.m).
%
% Run on the server where CANlab tools + the weight maps + single-trial betas
% live. Cue-epoch single-trial betas already exist as *_event-cue*.nii.gz.
%   step02_applysignature_cueepoch            % event = 'cue'
%   step02_applysignature_cueepoch('stimulus')
% Output (rampup_plateau_canlab/):
%   signature-SIIPS_sub-all_runtype-pvc_event-cue.tsv
%   signature-NPS_sub-all_runtype-pvc_event-cue.tsv   (cross-check; already curated)

if nargin < 1 || isempty(event); event = 'cue'; end

current_dir = pwd;
main_dir = fileparts(fileparts(fileparts(current_dir)));
singletrial_dir = fullfile(main_dir, 'analysis', 'fmri', 'nilearn', 'singletrial_rampupplateau');
out_dir = fullfile(main_dir, 'analysis', 'fmri', 'nilearn', 'deriv01_signature', 'rampup_plateau_canlab');
if ~exist(out_dir, 'dir'); mkdir(out_dir); end

%% 1. load cue-epoch single trials
fname_template = fullfile(singletrial_dir, '*', ...
    strcat('*_*_*_runtype-*_event-', event, '*.nii.gz'));
fl = dir(fname_template);
assert(~isempty(fl), 'no *_event-%s* single trials under %s', event, singletrial_dir);
singletrial_fname = {fl.name}';
dat = fmri_data(filenames(fname_template, 'char'));

%% 2. weight maps (same maps as the existing pipeline)
sig.NPS   = which('weights_NSF_grouppred_cvpcr.img');       % Wager 2013 NPS
sig.SIIPS = which('nonnoc_v11_4_137subjmap_weighted_mean.nii'); % Woo 2017 SIIPS
% (NPSpos/NPSneg already curated for cue epoch; add here if you want to redo them)

signames = fieldnames(sig);
for s = 1:numel(signames)
    key = signames{s};
    wmap = sig.(key);
    assert(~isempty(wmap), 'weight map for %s not found on path (which() returned empty)', key);
    w = resample_space(fmri_data(wmap), dat);

    % --- CANlab pattern expression (weighted dot product) + corr + cosine ---
    val        = apply_mask(dat, w, 'pattern_expression', 'ignore_missing');
    val_corr   = apply_mask(dat, w, 'pattern_expression', 'correlation', 'ignore_missing');
    val_cosine = apply_mask(dat, w, 'pattern_expression', 'cosine_similarity', 'ignore_missing');

    T = table(singletrial_fname, val, val_corr, val_cosine, ...
        'VariableNames', {'singletrial_fname', key, [key '_corr'], [key '_cosine']});

    out = fullfile(out_dir, ...
        sprintf('signature-%s_sub-all_runtype-pvc_event-%s.tsv', key, event));
    writetable(T, out, 'FileType', 'text', 'Delimiter', '\t');
    fprintf('wrote %s  (%d trials)\n', out, height(T));
end

%% NOTE: one-call alternative
% apply_all_signatures(dat) returns NPS, SIIPS, and many others in a single
% table (also using pattern expression internally). Use it if you prefer one
% call; the per-signature apply_mask above is kept to match the exact column
% naming (key / key_corr / key_cosine) of the existing stim-epoch files.
end
