% PCR
% The purpose of this script is to benchmark Wani's PCR SCR analysis
% we already have the data preprocessed in the sense that
% 1) the data is organized per onset
% 2) We downsampled the datta

%%
% THOUGHTS:
% pick up on 
% event time window for 23 seconds
% signal_m: average trial per participant, factor 1 and factor 2. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% step 1. load data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

data = readtable('/Users/h/Dropbox/projects_dropbox/social_influence_analysis/analysis/physio/physio01_SCL/group/sub-all_ses-all_run-all_runtype-pain_epochstart--1_epochend-20_samplingrate-25_ttlindex-2_physio-scltimecourse.csv');
%%
% data: D.Event_Level.data
%     y_int{i} = 
% event04_actual_angle: D.Event_Level.data{i}(:,12); % intensity
% event02_expect_angle: D.Event_Level.data{i}(:,13)
% y_unp{i} = -2*(D.Event_Level.data{i}(:,13)-50); % unpleasantless (bipolar)
%     
% data.cond: D.Event_Level.data{i}(:,16);
% data.temp D.Event_Level.data{i}(:,11);


data.temp(categorical(data.param_stimulus_type) == 'low_stim') = 48;
data.temp(categorical(data.param_stimulus_type) == 'high_stim') = 49;
data.temp(categorical(data.param_stimulus_type) == 'med_stim') = 50;
data.cond(categorical(data.param_task_name) == 'pain') = 1;
data.cue(categorical(data.param_cue_type) == 'high_cue') = 1;
data.cue(categorical(data.param_cue_type) == 'low_cue') = -1;
% for i = 1:numel(data)
% y_int = data.event04_actual_angle; % intensity
% y_unp = data.event02_expect_angle; % unpleasantless (bipolar)
% xx = [data.temp data.cond scale(data.temp .* scale(data.cond)) ];
% reg = data.cond; %data{i}(:,16);
% temp = data.temp;  %data{i}(:,11);
% end
sub_list = unique(data.src_subject_id);
sub_list_clean = sub_list(~isnan(sub_list));

for i = 1:numel(sub_list_clean)
%     subsetData = data(data.ColumnB == k, :);
    y_int{i} = data.event04_actual_angle(data.src_subject_id == sub_list_clean(i)); % D.Event_Level.data{i}(:,12); % spacetop: intensity
    y_unp{i} = data.event02_expect_angle(data.src_subject_id == sub_list_clean(i)); % unpleasantless (bipolar) -> spacetop: expectation rating
    xx{i} = [data.temp(data.src_subject_id == sub_list_clean(i)) data.cue(data.src_subject_id == sub_list_clean(i)) scale(data.temp(data.src_subject_id == sub_list_clean(i)) .* data.cue(data.src_subject_id == sub_list_clean(i)))];
    reg{i} = data.cue(data.src_subject_id == sub_list_clean(i));
    temp{i} = data.temp(data.src_subject_id == sub_list_clean(i));
end
%% calculate subject mean per condition

u_temp = unique(temp{1});
u_reg = unique(reg{1});
dat_int = {};
dat_unp = {};
for subj = 1:numel(temp)
    for i = 1:numel(u_temp)
        for j = 1:numel(u_reg)
            dat_int{i,j}(subj,1) = nanmean(y_int{subj}(temp{subj}==u_temp(i) & reg{subj}==u_reg(j)));
            dat_unp{i,j}(subj,1) = nanmean(y_unp{subj}(temp{subj}==u_temp(i) & reg{subj}==u_reg(j)));
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Step 2. Creating X: SCR data (averaged over three trials)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Assuming your table is named 'myTable'

% Specify the column names
startColumn = 'time_0';
endColumn = 'time_524';

% Get the column indices
startIndex = find(strcmp(data.Properties.VariableNames, startColumn));
endIndex = find(strcmp(data.Properties.VariableNames, endColumn));

% Grab the desired columns
% Continuousdata = data(data.src_subject_id == sub_list_clean(i), startIndex:endIndex);

% 
% for j = 1:numel(Continuousdata)      % loop through subjects
%     
%     scr =  Continuousdata; %D.Continuous.data{j};         % SCR data for each person
%     
%     ons = D.Event_Level.data{j}(:,5);   % Heat onset 
%     
%     for ii = 1:6
%         for jj = 1:3
%             signal{j}.cond{ii, jj} = [];  % pre-allocation 
%         end
%     end
%         
%     for i = 1:numel(ons)
%         temp_lev = D.Event_Level.data{j}(i,11)-43;  % temperature level 1-6
%         reg_lev = D.Event_Level.data{j}(i,16)+2;    % regulation level 1-3
% %         a = round((ons(i)-3)*25);                   % onset in 25 Hz
%     end
% end
temp_list = {'low_stim', 'med_stim', 'high_stim'};
cue_list = {'low_cue', 'high_cue'};
% for j = numel(sub_list_clean)
%     for t  = length(temp_list)
%         for c = length(cue_list)
%             signal{j}.cond{t, c} = [];  % pre-allocation
%         end
%     end
% end
% Specify the number of subjects
numSubjects = length(sub_list_clean); % Update with the actual number of subjects
signal = cell(1, numSubjects);
% Loop over subjects
for i = 1:numSubjects
    % Initialize the cond structure for each subject
    signal{i}.cond = cell(3, 2);
end


for j =  1:numel(sub_list_clean)
    for t  = 1:length(temp_list)
        for c = 1:length(cue_list)
      
            signal{1,j}.cond{t, c}(:,:) =  table2array(data(data.src_subject_id == sub_list_clean(j) &  strcmp(data.param_cue_type,cue_list(c)) &  strcmp(data.param_stimulus_type,temp_list(t)), startIndex:endIndex));
            % get data for 23 seconds
        end
    end
end
%% 
clear signal_m;
k = 0;

% snipping out 23 seconds in total. 0 is the onset of occurrence; the first
% 3 seconds are used for baseline.
% They use the first 3 seconds as baseline. calculate the mean within
% subject per condition and subtract
% NOTE 06/02/2023: for now, ignoring this because we baseline corrected
% when extracting the signals (e.g. fixation average subtracted from pain
% eda signal)
% for i = 1:length(temp_list) % temperature
%     for j = 1:length(cue_list) % cue condition
%         k = k + 1;
%         for subj = 1:numel(signal)
%             signal_m{i,j}(subj,:) = nanmean(signal{subj}.cond{i,j} - repmat(mean(signal{subj}.cond{i,j}(:,1:25),2), 1, size(signal{subj}.cond{i,j},2))); % subtract from first 1 second - change it to 75 if using 3 sceonds signal{subj}.cond{i,j}(:,1:25)
%                                                      % subtracting the baseline, and then average
%         end
%     end
% end

for i = 1:length(temp_list) % temperature
    for j = 1:length(cue_list) % cue condition
        k = k + 1;
        for subj = 1:numel(signal)
            signal_m{i,j}(subj,:) = nanmean(signal{subj}.cond{i,j}); % subtract from first 1 second - change it to 75 if using 3 sceonds signal{subj}.cond{i,j}(:,1:25)
                                                     % subtracting the baseline, and then average
        end
    end
end


%% Step 3. Running PCR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3-1. Determining the number of components of the model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('/Users/clinpsywoo/github/canlabrepo/CanlabCore/CanlabCore/External/lasso');

for i = 1:length(temp_list)
    for j = 1:length(cue_list)
        subjs{i,j} = (1:size(dat_int{i,j},1))';  % ready for leave-one-participant-out (LOPO) cross-validation
    end
end
% NOTE: in our case, dat_int{:,1} is low cue and dat_int{:,2} is high cue
% dat_int: 41 subjects, 6 x 3 cell
dat.int = fmri_data;                                 % to use fmri_data.predict function, 
                                                 % put the data in fmri_data object
dat.int.Y = cat(1,dat_int{:,1});    %cat(1,dat_int{:,2});                     % add concatenated intensity ratings in dat.Y
dat.int.dat = cat(1,signal_m{:,1})'; %cat(1,signal_m{:,2})';                 % add concatenated epoch data in dat.dat: [ 25*20sec SCR X 41*6condition ]
                                                 % **For the training, we only used passive experience runs.**
dat.int.dat = dat.int.dat(26:375,:); %dat.int.dat(76:575,:);                     % Stimulus-locked 20 seconds epoch 
whfolds = cat(1,subjs{:,1});  %cat(1,subjs{:,2});                     % cross-validaion folds (LOPO CV) [ rep(41sub x 6conditions) ]

dat.unp = dat.int;
dat.unp.Y = cat(1,dat_unp{:,1});%cat(1,dat_unp{:,2});  
datdir = '/Users/h/Desktop';
% savename = fullfile(datdir, 'SCR_prediction_dat_112816.mat');
% save(savename, '-append', 'dat', 'whfolds', 'dat_int', 'dat_unp', 'signal_m');
% 
% clear rmse pred_outcome_r;

for i = 2:10
    if i == 2, disp('SCR predictive model for intensity ratings'); end
    [~, stats_int, ~] = predict(dat.int, 'algorithm_name', 'cv_pcr', 'nfolds', whfolds, 'numcomponents', i, 'verbose', 0);
    rmse.int(i-1) = stats_int.rmse;
    
    for j = unique(whfolds)'
        por_subj(j) = corr(stats_int.Y(whfolds==j), stats_int.yfit(whfolds==j));
    end
    
    pred_outcome_r.int(i-1) = mean(por_subj);
    fprintf('\n #component = %d, rmse = %1.4f, pred_outcome_r = %1.4f', i, stats_int.rmse, mean(por_subj));
end
clear por_subj;

for i = 2:10
    if i == 2, disp('SCR predictive model for unpleasantness ratings'); end
    [~, stats_unp, ~] = predict(dat.unp, 'algorithm_name', 'cv_pcr', 'nfolds', whfolds, 'numcomponents', i, 'verbose', 0);
    rmse.unp(i-1) = stats_unp.rmse;
    
    for j = unique(whfolds)'
        por_subj(j) = corr(stats_unp.Y(whfolds==j), stats_unp.yfit(whfolds==j));
    end
    
    pred_outcome_r.unp(i-1) = mean(por_subj);
    fprintf('\n #component = %d, rmse = %1.4f, pred_outcome_r = %1.4f', i, stats_unp.rmse, mean(por_subj));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3-2. Plot for rmse and pred_outcome_r for different numbers of components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

savefig = 0;

[~, x] = max(-scale(rmse.int)+scale(pred_outcome_r.int));

create_figure('por'); 

% [hAx,hLine1,hLine2] = plotyy(2:10, pred_outcome_r.int, 2:10, rmse.int);
% 
% hLine1.LineWidth = 2.5;
% hLine2.LineWidth = 2.5;
% 
% set(gca, 'box', 'off', 'tickdir', 'out', 'tickLength', [.02 .02]);
% set(gcf, 'Position', [360   238   694   460]);
% set(hAx(1), 'FontSize', 22, 'LineWidth', 1.5, 'xlim', [1.5 10.5], 'ylim', [.48 .56], 'ytick', .48:.02:.56);
% set(hAx(2), 'tickdir', 'out', 'tickLength', [.018 .018], 'FontSize', 22, 'LineWidth', 1.5, 'xlim', [1.5 10.5], 'ylim', [10.8 11.6], 'ytick', 10.8:.2:11.6);

plot(2:10, pred_outcome_r.int, 'color', 'k', 'linewidth', 2);
if ~savefig
    xlabel('The number of principal components', 'fontsize', 20);
    ylabel('Prediction-outcome correlation', 'fontsize', 20);
end

y = pred_outcome_r.int(x);

hold on;
line([x+1 x+1], [0.35 y], 'linestyle', '--', 'color', [.4 .4 .4], 'linewidth', 1.5);
scatter(x+1, y, 150, 'r', 'marker', 's', 'markerfacecolor', 'r', 'markeredgecolor', 'k');
set(gca, 'tickDir', 'out', 'tickLength', [.02 .02], 'linewidth', 2, 'ylim', [-.840 .84], 'xlim', [1.5, 10.5], 'fontsize', 20);
if ~savefig
    set(gcf, 'position', [360   318   516   380]);
else
    set(gcf, 'position', [360   455   338   243]);
end

if savefig
    savename = fullfile(figdir, 'prediction_outcome_int_ncomp.pdf');
    pagesetup(gcf);
    saveas(gcf, savename);
    
    pagesetup(gcf);
    saveas(gcf, savename);
end

%% 
% Similar results for RMSE.. decided not to put this figure in the paper.
%%
% close all;
create_figure('rmse'); 
plot(2:10, rmse.int, 'color', 'k', 'linewidth', 2);
xlabel('The number of principal components', 'fontsize', 22);
ylabel('RMSE', 'fontsize', 22);

hold on;

y = rmse.int(x);

line([x+1 x+1], [10.8 y], 'linestyle', '--', 'color', [.4 .4 .4], 'linewidth', 1.5);
scatter(x+1, y, 80, 'r', 'marker', 's', 'markerfacecolor', 'r', 'markeredgecolor', 'k');

set(gca, 'tickDir', 'out', 'tickLength', [.02 .02], 'linewidth', 2, 'fontsize', 20, 'xlim', [1.5 10.5]);

% figdir = '/Users/clinpsywoo/Dropbox (CANLAB)/c_crb_analysis/analysis_n25/figure';
% savename = fullfile(figdir, 'rmse_int_ncomp.pdf');
% try
%     pagesetup(gcf);
%     saveas(gcf, savename);
% catch
%     pagesetup(gcf);
%     saveas(gcf, savename);
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3-3. PCR model for intensity ratings with NCOMP = 6, bootstrapping 10000
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[~, pcr_stats.int, ~] = predict(dat.int, 'algorithm_name', 'cv_pcr', 'nfolds', whfolds, 'numcomponents', 9, 'bootweights', 'bootsamples', 10000); % run it again
[~, pcr_stats.unp, ~] = predict(dat.unp, 'algorithm_name', 'cv_pcr', 'nfolds', whfolds, 'numcomponents', 9, 'bootweights', 'bootsamples', 10000); % run it again

save(fullfile(datdir, 'SCR_prediction_dat_112816.mat'), '-append', 'pcr_stats', 'pred_outcome_r', 'rmse');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3-4-1. Plot for intensity 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% close all;
% 
% load(fullfile(datdir, 'SCR_prediction_dat_112816.mat'));

x = 1:500;
create_figure('PCR weights');

for i = (5:5:20)*25
    line([i i], [-.3 1], 'col', [.8 .8 .8], 'linewidth', 1);
end

sig_idx = pcr_stats.int.WTS.wP<getFDR(pcr_stats.int.WTS.wP, .05);
% significant time points = [67:215 282:500]
idx{1} = 1:67;
idx{2} = 216:282;
idx{3} = 67:216;
idx{4} = 282:500;
% NOTE: not sure what other_output is and how it differs from
% other_output_cv. 
% I do see the description differnce, but don't understand the conceptual
% difference as to how this was obtained: "['Other output from algorithm -
% trained on all data (these depend on algorithm)']"
for i = 1:2, plot(x(idx{i}), pcr_stats.int.other_output{1}(idx{i}), 'color', [.3 .3 .3], 'linewidth', 3); end
for i = 3:4, plot(x(idx{i}), pcr_stats.int.other_output{1}(idx{i}), 'color', [0.8431    0.1882    0.1216], 'linewidth', 3); end

set(gcf, 'position', [50   208   423   242]);
set(gca, 'ylim', [-.08 .12], 'xlim', [0 500], 'linewidth', 1.5, 'TickDir', 'out', 'TickLength', [.02 .02], 'Xtick', (0:5:24)*25, 'ytick', -.05:.05:.12);
set(gca, 'XTickLabel', get(gca, 'XTick')./25);
set(gca, 'fontSize', 22);

savename = fullfile(figdir, 'SCR_intensity_predictive_weights.pdf');

pagesetup(gcf);
saveas(gcf, savename);

pagesetup(gcf);
saveas(gcf, savename);

%% 
% 3-4-2. Plot for expectation
%%
% close all;

x = 1:500;
create_figure('PCR weights');

for i = (5:5:20)*25
    line([i i], [-.3 1], 'col', [.8 .8 .8], 'linewidth', 1);
end

sig_idx = pcr_stats.unp.WTS.wP<getFDR(pcr_stats.unp.WTS.wP, .05);
% significant time points = [278:500]
idx{1} = 1:278;
idx{2} = 278:375;%500;
i=1; plot(x(idx{i}), pcr_stats.unp.other_output{1}(idx{i}), 'color', [.3 .3 .3], 'linewidth', 3); 
i=2; plot(x(idx{i}), pcr_stats.unp.other_output{1}(idx{i}), 'color', [0.8431    0.1882    0.1216], 'linewidth', 3); 

set(gcf, 'position', [50   208   423   242]);
set(gca, 'ylim', [-.08 .12], 'xlim', [0 500], 'linewidth', 1.5, 'TickDir', 'out', 'TickLength', [.02 .02], 'Xtick', (0:5:24)*25, 'ytick', -.05:.05:.12);
set(gca, 'XTickLabel', get(gca, 'XTick')./25);
set(gca, 'fontSize', 22);

savename = fullfile(figdir, 'SCR_expectation_predictive_weights.pdf');

pagesetup(gcf);
% saveas(gcf, savename);

pagesetup(gcf);
% saveas(gcf, savename);

fprintf('\ncorrelation between intensity and expectation weights r = %1.3f\n', corr(pcr_stats.int.other_output{1}, pcr_stats.unp.other_output{1}));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Step 4. Testing on regulation trials
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % scr = load(fullfile(datdir, 'SCR_prediction_dat_112816.mat'));
scr  = struct();
scr.signal_m = signal_m;
scr.pcr_stats = pcr_stats;
scr.dat_unp = dat_unp;
scr.dat_int = dat_int;


% Applying the model on regulation trials using leave-one-participant-out cross validation
for i = [1 3]
    for j = 1:6
        for subj = 1:size(scr.signal_m{j,i},1)
            test_scr_int{j,i}(subj,1) = scr.signal_m{j,i}(subj,26:375)*scr.pcr_stats.int.other_output_cv{subj,1} + scr.pcr_stats.int.other_output_cv{subj,2};
            test_scr_unp{j,i}(subj,1) = scr.signal_m{j,i}(subj,26:375)*scr.pcr_stats.unp.other_output_cv{subj,1} + scr.pcr_stats.unp.other_output_cv{subj,2};
        end
    end
end

temp_int = reshape(scr.pcr_stats.int.yfit, 41, 6);
temp_unp = reshape(scr.pcr_stats.unp.yfit, 41, 6);

for j = 1:6
    test_scr_int{j,2} = temp_int(:,j);
    test_scr_unp{j,2} = temp_unp(:,j);
end

% save(fullfile(datdir, 'SCR_prediction_dat_112816.mat'), '-append', 'test_scr_*');

% scatter plot
y_int = [cat(2,scr.dat_int{:,1}) cat(2,scr.dat_int{:,3})];
yfit_int = [cat(2,test_scr_int{:,1}) cat(2,test_scr_int{:,3})];

y_unp = [cat(2,scr.dat_unp{:,1}) cat(2,scr.dat_unp{:,3})];
yfit_unp = [cat(2,test_scr_int{:,1}) cat(2,test_scr_int{:,3})];

%%
colors = [255,237,160
254,217,118
254,178,76
253,141,60
252,78,42
227,26,28
189,0,38]./255;

xlim = [-2 65];
create_figure('predicted');

clear test_por;
for i = 1:size(y_int,1)
    hold on;
    x = y_int(i,:);
    y = yfit_int(i,:);
    b = glmfit(x,y);
    test_por(i) = corr(x',y');
end

dif = 1/size(colors,1);

k = zeros(size(test_por));
for i = 1:size(colors,1)
    idx = test_por <= (dif*i+.0001) & test_por >= dif*(i-1);
    k(idx) = i;
end

marker_shapes = repmat('osd^v><', 1, 40);

for i = 1:size(y_int,1)
    hold on;
    x = y_int(i,:);
    y = yfit_int(i,:);
    b = glmfit(x,y);
    line_h(i) = line(xlim, b'*[ones(1,2); xlim], 'linewidth', 1.5, 'color', colors(k(i),:)); % cmap(round(i*1.5),:));
    scatter(x, y, 120, colors(k(i),:), 'filled', 'markerfacealpha', .8, 'marker', marker_shapes(i));
end

line(xlim, xlim, 'linewidth', 4, 'linestyle', ':', 'color', [.5 .5 .5]);

set(gcf, 'position', [360   349   371   349]);
set(gca, 'tickdir', 'out', 'TickLength', [.02 .02], 'linewidth', 1.5, 'xlim', xlim, 'ylim', [-2 100], 'fontsize', 22);

savename = fullfile(figdir, 'SCR_actual_predicted_outcomes.pdf');

pagesetup(gcf);
saveas(gcf, savename);

pagesetup(gcf);
saveas(gcf, savename);


%% 
create_figure('predicted_unp');
dif = 1/size(colors,1);

clear test_por_unp;
for i = 1:size(y_unp,1)
    hold on;
    x = y_unp(i,:);
    y = yfit_unp(i,:);
    b = glmfit(x,y);
    test_por_unp(i) = corr(x',y');
end

k = zeros(size(test_por_unp));
for i = 1:size(colors,1)
    idx = test_por_unp <= (dif*i+.0001) & test_por_unp >= dif*(i-1);
    k(idx) = i;
end

marker_shapes = repmat('osd^v><', 1, 40);

for i = 1:size(y_unp,1)
    hold on;
    x = y_unp(i,:);
    y = yfit_unp(i,:);
    b = glmfit(x,y);
    try
        line_h(i) = line(xlim, b'*[ones(1,2); xlim], 'linewidth', 1.5, 'color', colors(k(i),:)); % cmap(round(i*1.5),:));
        scatter(x, y, 120, colors(k(i),:), 'filled', 'markerfacealpha', .8, 'marker', marker_shapes(i));
    catch
        line_h(i) = line(xlim, b'*[ones(1,2); xlim], 'linewidth', 1.5, 'color', [0.1961    0.5333    0.7412]); % cmap(round(i*1.5),:));
        scatter(x, y, 120, [0.1961    0.5333    0.7412], 'filled', 'markerfacealpha', .8, 'marker', marker_shapes(i));
    end
    
end

line(xlim, xlim, 'linewidth', 4, 'linestyle', ':', 'color', [.5 .5 .5]);

set(gcf, 'position', [360   349   371   349]);
set(gca, 'tickdir', 'out', 'TickLength', [.02 .02], 'linewidth', 1.5, 'xlim', xlim, 'ylim', [-2 100], 'fontsize', 22);

savename = fullfile(figdir, 'SCR_actual_predicted_outcomes_unpleasant.pdf');

pagesetup(gcf);
saveas(gcf, savename);

pagesetup(gcf);
saveas(gcf, savename);


fprintf('\nTest results: mean prediction_outcome_r for intensity = %1.3f', mean(test_por));
fprintf('\nTest results: mean prediction_outcome_r for unpleasantness = %1.3f', mean(test_por_unp));
