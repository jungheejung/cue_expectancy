function FIR_spm_signature(sub, onset_dir, main_dir, fmriprep_dir, badruns_json, save_dir)
% ==============================================================================
% FIR_spm_signature.m
%
% Signature (NPS / NPSpos / SIIPS) FIR timecourses -- mirror of
% FIR_spm_fulltimecourse_stimulus.m, but instead of fitting FIR on an
% ROI-averaged timeseries it fits FIR on the whole-brain PATTERN-EXPRESSION
% timeseries of each signature (apply_mask(...,'pattern_expression') returns one
% scalar per TR). Same 9-condition design, same hrf_fit_one_voxel FIR fit, same
% output layout as the ROI FIR, so the R tracking test
% (fir_timecourse_tracking_test.R) runs on it unchanged.
%
% 9 conditions (matches the ttl2_painpathway tr-42 files):
%   cueH_stimH cueL_stimH cueH_stimM cueL_stimM cueH_stimL cueL_stimL   (onset03_stim)
%   rating (onset02 + onset04)   cueH   cueL   (onset01_cue split by cue type)
%
% NOTE: the run-discovery / badruns / onset-reading boilerplate below is copied
% from FIR_spm_fulltimecourse_stimulus.m -- diff it against your current version
% before running, in case that pipeline has since changed.
%
% Run on the cluster (CANlab + weight maps + fmriprep BOLD on path).
% Output: save_dir/<sub>/<sub>_<ses>_<run>_runtype-<rt>_signature-fir_tr-42.csv
% ==============================================================================
disp(strcat('-------------------- ', sub, ' signature FIR ----------------'));
addpath(genpath(fullfile(fmriprep_dir, sub)));
TR = 0.46;  T = 20;

% ---- signature weight maps (same maps as the canlab signature pipeline) ------
sig.NPS    = which('weights_NSF_grouppred_cvpcr.img');
sig.NPSpos = which('NPSp_Lopez-Sola_2017_PAIN.img');
sig.SIIPS  = which('nonnoc_v11_4_137subjmap_weighted_mean.nii');
signames = fieldnames(sig);
for s = 1:numel(signames)
    assert(~isempty(sig.(signames{s})), 'weight map for %s not found on path', signames{s});
end
condition_labels = {'cueH_stimH','cueL_stimH','cueH_stimM','cueL_stimM', ...
                    'cueH_stimL','cueL_stimL','rating','cueH','cueL'};

if ~exist(fullfile(save_dir, sub), 'dir'); mkdir(fullfile(save_dir, sub)); end

% ---- run discovery (copied from ROI FIR; verify vs current pipeline) ---------
niilist = dir(fullfile(fmriprep_dir, sub, '*/func/*task-social*_bold.nii'));
nT = sortrows(struct2table(niilist), 'name');
nT.sub_num(:) = str2double(extractBetween(nT.name, 'sub-', '_'));
nT.ses_num(:) = str2double(extractBetween(nT.name, 'ses-', '_'));
nT.run_num(:) = str2double(extractBetween(nT.name, 'run-', '_'));
nnum = nT.Properties.VariableNames(endsWith(nT.Properties.VariableNames, '_num'));

onsetlist = dir(fullfile(onset_dir, sub, '*', strcat(sub, '_*_task-cue_*_events.tsv')));
oT = sortrows(struct2table(onsetlist), 'name');
oT.sub_num(:) = str2double(extractBetween(oT.name, 'sub-', '_'));
oT.ses_num(:) = str2double(extractBetween(oT.name, 'ses-', '_'));
oT.run_num(:) = str2double(extractBetween(oT.name, 'run-', '_'));
onum = oT.Properties.VariableNames(endsWith(oT.Properties.VariableNames, '_num'));

bad = readBadRunsFromJSON(badruns_json);
bnum = bad.Properties.VariableNames(endsWith(bad.Properties.VariableNames, '_num'));
[~, ia] = ismember(nT(:, nnum), bad(:, bnum), 'rows');
good = nT(setdiff(1:size(nT,1), ia), :);
gnum = good.Properties.VariableNames(endsWith(good.Properties.VariableNames, '_num'));
A = intersect(good(:, gnum), oT(:, onum));

% ---- per run -----------------------------------------------------------------
for run_ind = 1:size(A, 1)
    ses   = strcat('ses-', sprintf('%02d', A.ses_num(run_ind)));
    run01 = strcat('run-', sprintf('%01d', A.run_num(run_ind)));
    run   = strcat('run-', sprintf('%02d', A.run_num(run_ind)));

    onset_glob = dir(fullfile(onset_dir, sub, ses, strcat(sub,'_',ses,'_task-cue_',run,'*_events.tsv')));
    if isempty(onset_glob); continue; end
    onset_fname = fullfile(onset_glob.folder, onset_glob.name);
    runtype = extractBetween(onset_fname, 'runtype-', '_');
    if ~strcmp(runtype{1}, 'pain'); continue; end          % pain runs only (drop for all tasks)
    events = struct2table(tdfread(onset_fname));

    % ---- 9-condition onset design (spike vectors, 872 TRs) -------------------
    isH = strcmp(events.pmod_cuetype, 'high_cue');  isL = strcmp(events.pmod_cuetype, 'low_cue');
    isSH = strcmp(events.pmod_stimtype, 'high_stim'); isSM = strcmp(events.pmod_stimtype, 'med_stim'); isSL = strcmp(events.pmod_stimtype, 'low_stim');
    on = @(mask, field) round(events.(field)(mask)/TR);
    idx.cueH_stimH = on(isH & isSH, 'onset03_stim'); idx.cueL_stimH = on(isL & isSH, 'onset03_stim');
    idx.cueH_stimM = on(isH & isSM, 'onset03_stim'); idx.cueL_stimM = on(isL & isSM, 'onset03_stim');
    idx.cueH_stimL = on(isH & isSL, 'onset03_stim'); idx.cueL_stimL = on(isL & isSL, 'onset03_stim');
    idx.rating = [round(events.onset02_ratingexpect/TR); round(events.onset04_ratingoutcome/TR)];
    idx.cueH = on(isH, 'onset01_cue');  idx.cueL = on(isL, 'onset01_cue');

    Runc = cell(1, numel(condition_labels));
    for c = 1:numel(condition_labels)
        v = zeros(872,1); ix = idx.(condition_labels{c}); ix = ix(ix>=1 & ix<=872); v(ix) = 1; Runc{c} = v;
    end

    % ---- load BOLD once ------------------------------------------------------
    func = fullfile(fmriprep_dir, sub, ses, 'func', ...
        strcat(sub,'_',ses,'_task-social_acq-mb8_',run01,'_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'));
    if ~exist(func, 'file'); warning('missing %s', func); continue; end
    fmridata = fmri_data(func);

    % ---- for each signature: pattern-expression timeseries -> FIR ------------
    dataTables = {};
    for s = 1:numel(signames)
        key = signames{s};
        w = resample_space(fmri_data(sig.(key)), fmridata);
        sig_ts = apply_mask(fmridata, w, 'pattern_expression', 'ignore_missing');  % T x 1 per TR
        Tvec = repmat(T, 1, numel(Runc));   % per-condition window (Fit_sFIR_epochmodulation indexes T(i))
        [h, ~, ~, ~] = hrf_fit_one_voxel(sig_ts, TR, Runc, Tvec, 'FIR', 0);       % 42 x nCond
        data = h';                                                                % nCond x 42
        n = size(data,1);
        meta = table(repmat(string(sub),n,1), repmat(string(ses),n,1), repmat(string(run),n,1), ...
                     repmat(string(runtype{1}),n,1), repmat(string(key),n,1), condition_labels(1:n)', ...
                     'VariableNames', {'sub','ses','run','runtype','signature','condition'});
        trtab = array2table(data, 'VariableNames', compose('tr%d', 1:size(data,2)));
        dataTables{end+1} = [meta trtab]; %#ok<AGROW>
    end
    stacked = vertcat(dataTables{:});
    save_fname = fullfile(save_dir, sub, strcat(sub,'_',ses,'_',run,'_runtype-',runtype{1},'_signature-fir_tr-42.csv'));
    writetable(stacked, save_fname);
    fprintf('wrote %s\n', save_fname);
end
end
