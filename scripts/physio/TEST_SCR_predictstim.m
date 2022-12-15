%% Purpose of this script
% The purpose of this script is to reshape the data extracted from spacetop-prep into matlab.
% We want to utilize Matthewson and Woo's scripts on PCR physio extraction.
close all;
task = 'cognitive';
dv = 'stim';
fname = fullfile('/Volumes/spacetop_projects_social/analysis/physio/physio01_SCL/', strcat('sub-all_condition-mean_runtype-', task, '_epochstart--1_epochend-20_samplingrate-25_ttlindex-2_physio-scltimecourse.csv'));
figdir = '/Users/h/Dropbox/projects_dropbox/social_influence_analysis/figure/physio/physio01_SCL';

T = readtable(fname);
n_subj = length(unique(T.src_subject_id));
%       lowcue   highcue
% 48,   1,1         1,2
% 49    2,1         2,2
% 50    3,1         3,2

%% dat_int{i,j}(subj,1) 
% average subject's rating for given condition i, j
% in my case 
% -- i = temp
% -- j = high/lowcue
% -- 3 x 2 cell with N number of ratings per cell
cuetype = { 'low_cue', 'high_cue'};
stimtype = {'low_stim', 'med_stim',  'high_stim',};
dat_int_TEST = cell(length(stimtype),length(cuetype));
for cue = 1:2
    for stim = 1:3
        subset = [];
        subset = T(strcmp(T.param_cue_type, cuetype{cue}) & strcmp(T.param_stimulus_type', stimtype{stim})', :);
        if subset.src_subject_id == unique(T.src_subject_id)

            dat_int_TEST{stim,cue} = repmat(stim, n_subj,1);
        end
    end
end


%% signal_m{i,j}(subj,:)
% average SCL signal per subject for given condition i, j
% in my case
% -- i = temp
% -- j = high/low cue
% -- 3 x 2 cell with N number of SCL timelines per cell
cuetype = { 'low_cue', 'high_cue'};
stimtype = {'low_stim', 'med_stim',  'high_stim',};
signal_m_TEST = cell(length(stimtype),length(cuetype));
for cue = 1:2
    for stim = 1:3
        subset = [];
        subset = T(strcmp(T.param_cue_type, cuetype{cue}) & strcmp(T.param_stimulus_type', stimtype{stim})', :);
        if subset.src_subject_id == unique(T.src_subject_id)
            signal_m_TEST{stim,cue} = subset(:, contains(subset.Properties.VariableNames, 'time_'));
        end
    end
end
for cue = 1:2
    for stim = 1:3
signal_m_TEST{stim,cue}(:,end)=[];
    end
end
%% whfolds = cat(1,subjs{:,2});  
% 246 X 1
% (N*conditions) X 1
% N*3 X 1
n_subj = length(unique(T.src_subject_id));
seq = 1:n_subj;
% whfolds = repmat(seq,1, length(stimtype)*length(cuetype))';
% whfolds = repmat(seq,1, length(stimtype))';

for i = 1:3
    for j = 1:2
        subjs{i,j} = (1:size(dat_int_TEST{i,j},1))';  % ready for leave-one-participant-out (LOPO) cross-validation
    end
end
whfolds = cat(1,subjs{:,:}); 
%       lowcue   highcue

%% fmri data object
cue_expect = fmri_data;                                 % to use fmri_data.predict function, 
                                                 % put the data in fmri_data object
cue_expect.Y = cat(1,dat_int_TEST{:,:});     % cat(1,dat_int{:,2});                 % add concatenated intensity ratings in dat.Y
cue_expect.dat = table2array(cat(1,signal_m_TEST{:,:}))';    % row: time x  participant/condition             % add concatenated epoch data in dat.dat
                                                 % **For the training, we only used passive experience runs.**
cue_expect.dat = cue_expect.dat(1:524,:);                     % Stimulus-locked 20 seconds epoch 
% whfolds = cat(1,subjs{:,2});                     % cross-validaion folds (LOPO CV)

% dat.unp = dat.int;
% dat.unp.Y = cat(1,dat_unp{:,2});  

%%

clear rmse pred_outcome_r;

for i = 2:10
    if i == 2, disp('SCR predictive model for intensity ratings'); end
    [~, stats_int, ~] = predict(cue_expect, 'algorithm_name', 'cv_pcr', 'nfolds', whfolds, 'numcomponents', i, 'verbose', 0);
    rmse.int(i-1) = stats_int.rmse;
    
    for j = unique(whfolds)'
        por_subj(j) = corr(stats_int.Y(whfolds==j), stats_int.yfit(whfolds==j));
    end
    
    pred_outcome_r.int(i-1) = mean(por_subj);
    fprintf('\n #component = %d, rmse = %1.4f, pred_outcome_r = %1.4f', i, stats_int.rmse, mean(por_subj));
end


%% 
% 3-2. Plot for rmse and pred_outcome_r for different numbers of components
%%
savefig = 1;

[~, x] = max(-scale(rmse.int)+scale(pred_outcome_r.int));

create_figure('por'); 


plot(2:10, pred_outcome_r.int, 'color', 'k', 'linewidth', 2);
if ~savefig
    xlabel('The number of principal components', 'fontsize', 20);
    ylabel('Prediction-outcome correlation', 'fontsize', 20);
end

y = pred_outcome_r.int(x);

hold on;
% line([x+1 x+1], [0.35 y], 'linestyle', '--', 'color', [.4 .4 .4], 'linewidth', 1.5);
scatter(x+1, y, 150, 'r', 'marker', 's', 'markerfacecolor', 'r', 'markeredgecolor', 'k');
set(gca, 'tickDir', 'out', 'tickLength', [.02 .02], 'linewidth', 2, 'ylim', [0 .84], 'xlim', [1.5, 10.5], 'fontsize', 20);
if ~savefig
    set(gcf, 'position', [360   318   516   380]);
else
    set(gcf, 'position', [360   455   338   243]);
end

if savefig
    savename = fullfile(figdir, strcat(task,'_prediction-', dv,'_outcome_int_ncomp.png'));
    pagesetup(gcf);
    saveas(gcf, savename);
    
    pagesetup(gcf);
    saveas(gcf, savename);
end


%% 
% Similar results for RMSE.. decided not to put this figure in the paper.
%%
close all;
create_figure('rmse'); 
plot(2:10, rmse.int, 'color', 'k', 'linewidth', 2);
xlabel('The number of principal components', 'fontsize', 22);
ylabel('RMSE', 'fontsize', 22);

hold on;

y = rmse.int(x);

line([x+1 x+1], [10.8 y], 'linestyle', '--', 'color', [.4 .4 .4], 'linewidth', 1.5);
scatter(x+1, y, 80, 'r', 'marker', 's', 'markerfacecolor', 'r', 'markeredgecolor', 'k');

set(gca, 'tickDir', 'out', 'tickLength', [.02 .02], 'linewidth', 2, 'fontsize', 20, 'xlim', [1.5 10.5]);


%% 
% 3-3. PCR model for intensity ratings with NCOMP = 2, bootstrapping 10000
%%

[~, pcr_stats.int, ~] = predict(cue_expect, 'algorithm_name', 'cv_pcr', 'nfolds', whfolds, 'numcomponents', 3, 'bootweights', 'bootsamples', 10000); % run it again

save(fullfile(figdir, strcat('SCR_', task, '_prediction-', dv, '_dat_12062022.mat')),  'pcr_stats', 'pred_outcome_r', 'rmse');

%% 
% 3-4. See weights, significant time points
% 
% 3-4-1. Plot for intensity 
%%
close all;

load(fullfile(figdir, strcat('SCR_', task, '_prediction-', dv, '_dat_12062022.mat')));

x = 1:524;
create_figure('PCR weights');

for i = (5:5:25)*25
    line([i i], [-.3 1], 'col', [.8 .8 .8], 'linewidth', 1);
end

sig_idx = pcr_stats.int.WTS.wP<getFDR(pcr_stats.int.WTS.wP, .05);
% significant time points = [67:215 282:500]
idx{1} = 1:67;
idx{2} = 216:282;
idx{3} = 67:216;
idx{4} = 282:500;
plot(x, pcr_stats.int.other_output{1}, 'color', [.3 .3 .3], 'linewidth', 3); %end
% for i = 1:2, plot(x(idx{i}), pcr_stats.int.other_output{1}(idx{i}), 'color', [.3 .3 .3], 'linewidth', 3); end
% for i = 3:4, plot(x(idx{i}), pcr_stats.int.other_output{1}(idx{i}), 'color', [0.8431    0.1882    0.1216], 'linewidth', 3); end

set(gcf, 'position', [50   208   423   242]);
set(gca, 'ylim', [-.1, .12], 'xlim', [0 525], 'linewidth', 1.5, 'TickDir', 'out', 'TickLength', [.02 .02], 'Xtick', (0:5:24)*25, 'ytick', -.05:.05:.12);
set(gca, 'XTickLabel', get(gca, 'XTick')./25);
set(gca, 'fontSize', 22);

savename = fullfile(figdir, strcat('SCR_', task, '_intensity_predictive_weights-', dv,'.png'));

pagesetup(gcf);
saveas(gcf, savename);

pagesetup(gcf);
saveas(gcf, savename);
