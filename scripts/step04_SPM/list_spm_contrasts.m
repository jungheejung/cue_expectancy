function list_spm_contrasts(spm_path)
% ==============================================================================
% list_spm_contrasts.m
%
% Dump all contrasts from an SPM.mat so you can identify which of the 55 are the
% cue-epoch cue contrast (cueH>cueL during cue) and the stim-epoch cue contrast
% (cueL>cueH during stim). For each contrast it prints: index, con image
% filename, STAT type, name, and the NON-ZERO weighted regressor names + weights
% (the weights are what actually tell you which epoch/condition it targets).
%
% Usage (any one subject's first-level SPM.mat -- contrast defs are identical
% across subjects for the same model):
%   list_spm_contrasts('/dartfs-hpc/.../model01_6cond_highlowcue_rampplateau/sub-0002/SPM.mat')
% or point it at the model dir and it grabs the first SPM.mat it finds:
%   list_spm_contrasts('/dartfs-hpc/.../model01_6cond_highlowcue_rampplateau')
% ==============================================================================

% resolve to an SPM.mat
if isfolder(spm_path)
    hit = dir(fullfile(spm_path, '**', 'SPM.mat'));
    assert(~isempty(hit), 'no SPM.mat found under %s', spm_path);
    spm_file = fullfile(hit(1).folder, hit(1).name);
else
    spm_file = spm_path;
end
fprintf('SPM.mat: %s\n\n', spm_file);
S = load(spm_file); SPM = S.SPM;

% regressor names (columns of the design matrix)
reg = SPM.xX.name(:);
fprintf('=== %d design regressors ===\n', numel(reg));
for i = 1:numel(reg); fprintf('  col %3d: %s\n', i, reg{i}); end

% contrasts
xc = SPM.xCon;
fprintf('\n=== %d contrasts ===\n', numel(xc));
for i = 1:numel(xc)
    c = xc(i).c(:)';                         % contrast weight row
    nz = find(abs(c) > 1e-8);
    con_img = sprintf('con_%04d.nii', i);
    fprintf('\n[%2d] %-6s  %-40s  (%s)\n', i, xc(i).STAT, xc(i).name, con_img);
    for k = nz
        nm = ''; if k <= numel(reg); nm = reg{k}; end
        fprintf('        %+.3g  x  col%d  %s\n', c(k), k, nm);
    end
end

fprintf(['\nLook for: a contrast whose non-zero weights are on the CUE-epoch\n' ...
         'regressors (cue onset, split high vs low) = cue-epoch cue contrast;\n' ...
         'and one on the STIM-epoch regressors (high vs low cue during stim) =\n' ...
         'stim-epoch cue contrast. Note their [index] numbers -> con_%%04d.nii.\n']);
end
