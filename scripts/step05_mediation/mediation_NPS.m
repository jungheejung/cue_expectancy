% load NPS data
fname = '/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/deriv01_signature/rampup_plateau/signature-NPS_sub-all_runtype-pvc_event-stimulus.tsv'
npsdf = readtable(fname);
% load behavioral data

beh_df = readtable('/Users/h/Documents/projects_local/cue_expectancy/data/beh/sub-all_task-all_events.tsv','Delimiter', '\t');


%% trim subjects
% Count trials and select subjects
ntrials_trimmed = cellfun(@length, model1_Mtrimmed);

create_figure('ntrials', 1, 2); 
hist(ntrials_trimmed, 30)
title('Number of trials')
xlabel('Number of trials'); ylabel('Num. Subjects')

wh_remove = ntrials_trimmed < 10;
disp('removing:')
sum(wh_remove)

model1_X(wh_remove) = [];
model1_Xtrimmed(wh_remove) = [];
model1_Y(wh_remove) = [];
model1_Ytrimmed(wh_remove) = [];
model1_M(wh_remove) = [];
model1_Mtrimmed(wh_remove) = [];

cov_mediation_paincue_trimmed(wh_remove) = [];

subplot(1, 2, 2); hist(ntrials_trimmed, 30)
title('Number of trials')
xlabel('Number of trials'); ylabel('Num. Subjects')


%% colors
colors = seaborn_colors(length(model1_X))';

create_figure('X', 2, 1); 
barplot_columns(model1_X, 'nofig', 'noviolin', 'plotout', 'nostars', 'notable', 'colors', colors, 'nobars');
title('Expectancy');
subplot(2, 1, 2);
barplot_columns(model1_Xtrimmed, 'nofig', 'noviolin', 'nostars', 'notable', 'colors', colors, 'nobars');
drawnow, snapnow

create_figure('Y', 2, 1); 
barplot_columns(model1_Y, 'nofig', 'noviolin', 'plotout', 'nostars', 'notable', 'colors', colors, 'nobars');
title('Outcome (pain)');
subplot(2, 1, 2);
barplot_columns(model1_Ytrimmed, 'nofig', 'noviolin', 'nostars', 'notable', 'colors', colors, 'nobars');
drawnow, snapnow