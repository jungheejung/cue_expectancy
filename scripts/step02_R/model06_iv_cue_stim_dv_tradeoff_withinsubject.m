% read csv as table
filename = '/Users/h/Dropbox/projects_dropbox/social_influence_analysis/analysis/mixedeffect/model05_iv-cue-stim_dv-tradeoff_withinsubject/model05_iv-cue-stim_dv-tradeoff_withinsubject.csv';
T = readtable(filename);
% assign each column to cell

subject_list = unique(T.src_subject_id);
Y_DV = cell(1,length(unique(T.src_subject_id)));
X_factor = cell(1, length(unique(T.src_subject_id)));
for n = 1:length(unique(T.src_subject_id))
    % subset value per subject
    Y_DV{n} = T(T.src_subject_id==subject_list(n),:).tradeoff;
    X_factor{n} = T(T.src_subject_id==subject_list(n),:).con_num;
end

stats = glmfit_multilevel(Y_DV, X_factor, [], 'verbose', 'weighted');

% one-sample t-test, weighted by inv of btwn + within vars
stats = glmfit_multilevel(YY, XX, [], 'verbose', 'weighted');
statsg = glmfit_multilevel(y, x, covti, 'names', {'L1 Intercept' 'L1 Slope'},...
'beta_names', {'Group Average', 'L2_Covt'});