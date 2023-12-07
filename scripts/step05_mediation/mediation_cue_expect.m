df = readtable('/Users/h/Desktop/cleanmerge_NPS_pain.csv');
sub_list = unique(df.sub);

%% base model with cue -> expect rating -> NPS with stim as covariate is Non-signficant
% construct X Y M
for i= 1:1:length(sub_list)
    index = find(df.sub ==sub_list(i));
    model1_X{i} = df.CUE_high_gt_low(index);  %
    model1_M{i} = df.RATING_expectation(index); 
    model1_Y{i} = df.NPSpos(index); 
    cov_mediation_paincue{i} = [ df.stim(index) ];
    
end
% remove 3 sd
wh_outlier = cellfun(@(x) abs(x - mean(x)) > 3*std(x), model1_M, 'UniformOutput', false);

for i= 1:1:length(sub_list)
model1_Mremovedpts{i} = model1_M{i}(wh_outlier{i});
model1_Mtrimmed{i} = model1_M{i}(~wh_outlier{i});
model1_Xtrimmed{i} = model1_X{i}(~wh_outlier{i});
model1_Ytrimmed{i} = model1_Y{i}(~wh_outlier{i});
cov_mediation_paincue_trimmed{i} = cov_mediation_paincue{i}(~wh_outlier{i});
end

% remove trials less than 10
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

meanx = cellfun(@nanmean, model1_X)';
meany = cellfun(@nanmean, model1_Y)';
meanm = cellfun(@nanmean, model1_M)';
moderator = scale(meanm, 1); 
[paths_M_tolerance, stats_M_tolerance] = mediation(model1_Xtrimmed, model1_Ytrimmed, model1_Mtrimmed,'covs', cov_mediation_paincue_trimmed ,  'boot', 'verbose','plots', ...
    'names', {'Pain_Cue' 'NPS (pos)' 'Expectation rating'},'bootsamples', 10000, 'L2M', moderator);


%% SfN Stim -> NPS -> OUtcome
%% base model with cue -> expect rating -> NPS with stim as covariate is Non-signficant
% construct X Y M
for i= 1:1:length(sub_list)
    index = find(df.sub ==sub_list(i));
    model1_X{i} = df.stim(index);  %
    model1_M{i} = df.NPSpos(index); 
    model1_Y{i} = df.RATING_outcome(index); 
    cov_mediation_paincue{i} = [ df.RATING_expectation(index) ];
    
end
% remove 3 sd
wh_outlier = cellfun(@(x) abs(x - mean(x)) > 3*std(x), model1_M, 'UniformOutput', false);

for i= 1:1:length(sub_list)
model1_Mremovedpts{i} = model1_M{i}(wh_outlier{i});
model1_Mtrimmed{i} = model1_M{i}(~wh_outlier{i});
model1_Xtrimmed{i} = model1_X{i}(~wh_outlier{i});
model1_Ytrimmed{i} = model1_Y{i}(~wh_outlier{i});
cov_mediation_paincue_trimmed{i} = cov_mediation_paincue{i}(~wh_outlier{i});
end

% remove trials less than 10
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

meanx = cellfun(@nanmean, model1_X)';
meany = cellfun(@nanmean, model1_Y)';
meanm = cellfun(@nanmean, model1_M)';
moderator = scale(meanm, 1); 
[paths_M_tolerance, stats_M_tolerance] = mediation(model1_Xtrimmed, model1_Ytrimmed, model1_Mtrimmed,'covs', cov_mediation_paincue_trimmed ,  'boot', 'verbose','plots', ...
    'names', {'Stim' 'Outcome rating' 'NPS (pos)'},'bootsamples', 10000, 'L2M', moderator);


%% SfN expect -> NPS -> outcome
%% SfN Stim -> NPS -> OUtcome
%% base model with cue -> expect rating -> NPS with stim as covariate is Non-signficant
% construct X Y M
for i= 1:1:length(sub_list)
    index = find(df.sub ==sub_list(i));
    model1_X{i} = df.RATING_expectation(index);  %
    model1_M{i} = df.NPSpos(index); 
    model1_Y{i} = df.RATING_outcome(index); 
    cov_mediation_paincue{i} = [ df.stim(index) ];
    
end
% remove 3 sd
wh_outlier = cellfun(@(x) abs(x - mean(x)) > 3*std(x), model1_M, 'UniformOutput', false);

for i= 1:1:length(sub_list)
model1_Mremovedpts{i} = model1_M{i}(wh_outlier{i});
model1_Mtrimmed{i} = model1_M{i}(~wh_outlier{i});
model1_Xtrimmed{i} = model1_X{i}(~wh_outlier{i});
model1_Ytrimmed{i} = model1_Y{i}(~wh_outlier{i});
cov_mediation_paincue_trimmed{i} = cov_mediation_paincue{i}(~wh_outlier{i});
end

% remove trials less than 10
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

meanx = cellfun(@nanmean, model1_X)';
meany = cellfun(@nanmean, model1_Y)';
meanm = cellfun(@nanmean, model1_M)';
moderator = scale(meanm, 1); 
[paths_M_tolerance, stats_M_tolerance] = mediation(model1_Xtrimmed, model1_Ytrimmed, model1_Mtrimmed,'covs', cov_mediation_paincue_trimmed ,  'boot', 'verbose','plots', ...
    'names', {'Stim' 'Outcome rating' 'NPS (pos)'},'bootsamples', 10000, 'L2M', moderator);


%% additional model with cue -> expect rating -> NPS -> with stim AND outcome rating as covariate shows a full mediation effect
for i= 1:1:length(sub_list)
    index = find(df.sub ==sub_list(i));
    X_mediation{i} = df.CUE_high_gt_low(index);  %
    M_mediation{i} = df.RATING_expectation(index); 
    Y_mediation{i} = df.NPSpos(index); 
    cov_mediation_paincue{i} = [df.stim(index) df.RATING_outcome(index) ];
    
end

[paths_M_tolerance, stats_M_tolerance] = mediation(X_mediation, Y_mediation, M_mediation,'covs', cov_mediation_paincue ,  'boot', 'verbose','plots', ...
    'names', {'Pain_Cue' 'NPS (pos)' 'Expectation rating'},'bootsamples', 10000);

%% updated model with cue -> expect rating -> NPS -> with stim AND outcome rating as covariate shows a full mediation effect
for i= 1:1:length(sub_list)
    index = find(df.sub ==sub_list(i));
    X_mediation{i} = df.stim(index);  %
    M_mediation{i} = df.NPSpos(index); 
    Y_mediation{i} = df.RATING_outcome(index); 
    cov_mediation_paincue{i} = [df.CUE_high_gt_low(index) df.RATING_expectation(index) ]; %CUE_high_gt_low RATING_expectation
    
end

[paths_M_tolerance, stats_M_tolerance] = mediation(X_mediation, Y_mediation, M_mediation,'covs', cov_mediation_paincue ,  'boot', 'verbose','plots', ...
    'names', {'Stim'  'Outcome rating' 'NPSpos'},'bootsamples', 10000);



%%
%% with expect rating -> NPS -> outcome rating with stim as covariate is Non-signficant
for i= 1:1:length(sub_list)
    index = find(df.sub ==sub_list(i));
    model1_X{i} = df.RATING_expectation(index);  %
    model1_M{i} = df.NPSpos(index); 
    model1_Y{i} = df.RATING_outcome(index); 
    cov_mediation_paincue{i} = [ df.stim(index) ];
    
end

[paths_M_tolerance, stats_M_tolerance] = mediation(model1_X, model1_Y, model1_M,'covs', cov_mediation_paincue ,  'boot', 'verbose','plots', ...
    'names', {'Expectation' 'Outcome rating' 'NPSpos'},'bootsamples', 10000);


%%
wh_outlier = cellfun(@(x) abs(x - mean(x)) > 3*std(x), model1_M, 'UniformOutput', false);

for i= 1:1:length(sub_list)
% model1_Mtrimmed{i} = model1_M{i};
model1_Mremovedpts{i} = model1_M{i}(wh_outlier{i});
% model1_Mtrimmed{i}(wh_outlier{i}) = [];
model1_Mtrimmed{i} = model1_M{i}(~wh_outlier{i});
model1_Xtrimmed{i} = model1_X{i}(~wh_outlier{i});
model1_Ytrimmed{i} = model1_Y{i}(~wh_outlier{i});
cov_mediation_paincue_trimmed{i} = cov_mediation_paincue{i}(~wh_outlier{i});

end

% figure; barplot_columns(model1_Mremovedpts, 'nofig', 'title', 'NPSpos trimmed', 'noviolin');

[paths_M_tolerance, stats_M_tolerance] = mediation(model1_Xtrimmed, model1_Ytrimmed, model1_Mtrimmed,'covs', cov_mediation_paincue_trimmed ,  'boot', 'verbose','plots', ...
    'names', {'Expectation' 'Outcome rating' 'NPSpos'},'bootsamples', 10000);


%% full data 109 participants
df = readtable('/Users/h/Desktop/cleanmerge_NPS.csv');
sub_list = unique(df.sub);

for i= 1:length(sub_list)
    index = find(df.sub ==sub_list(i));
    model1_X{i} = df.RATING_expectation(index);  %
    model1_M{i} = df.NPSpos(index); 
    model1_Y{i} = df.RATING_outcome(index); 
    cov_mediation_paincue{i} = [ df.stim(index) ];
    fop(i) =df.composite_score(index(1));
    
end
wh_outlier = cellfun(@(x) abs(x - mean(x)) > 3*std(x), model1_M, 'UniformOutput', false);


for i= 1:length(sub_list)
% model1_Mtrimmed{i} = model1_M{i};
model1_Mremovedpts{i} = model1_M{i}(wh_outlier{i});
% model1_Mtrimmed{i}(wh_outlier{i}) = [];
model1_Mtrimmed{i} = model1_M{i}(~wh_outlier{i});
model1_Xtrimmed{i} = model1_X{i}(~wh_outlier{i});
model1_Ytrimmed{i} = model1_Y{i}(~wh_outlier{i});
cov_mediation_paincue_trimmed{i} = cov_mediation_paincue{i}(~wh_outlier{i});
% fop_trimmed(i) = %fop(~wh_outlier(i));

% fop(i) = unique(model1_Y{i}(~wh_outlier{i}));
% fop(i) = unique(model1_Y{i}(~wh_outlier{i}));
end


save model1_mediation_N-109_X-expect_M-NPS_Y-outcome model1* cov* fop*


% figure; barplot_columns(model1_Mremovedpts, 'nofig', 'title', 'NPSpos trimmed', 'noviolin');

[paths_M_tolerance, stats_M_tolerance] = mediation(model1_Xtrimmed, model1_Ytrimmed, model1_Mtrimmed,'covs', cov_mediation_paincue_trimmed ,  'boot', 'verbose','plots', ...
    'names', {'Expectation' 'Outcome rating' 'NPSpos'},'bootsamples', 10000);

%% check dataframe
% Let's assume your cell arrays are named A, B, C, and D
df = readtable('/Users/h/Desktop/pain_withinbetween.csv');
% Check if the cell arrays are the same size
sameCellSize = isequal(size(model1_Mtrimmed), size(model1_Xtrimmed), size(model1_Ytrimmed), size(cov_mediation_paincue));
A = model1_Mtrimmed;
B = model1_Xtrimmed;
C = model1_Ytrimmed;
D = cov_mediation_paincue;
if sameCellSize
    % If the cell arrays are the same size, check each cell's contents
    sameContentsSize = true; % Initialize to true
    for i = 1:numel(A) % Loop through each cell (linear indexing)
        if ~isequal(size(A{i}), size(B{i}), size(C{i}), size(D{i}))
            sameContentsSize = false; % Set to false if any size mismatch is found
            break; % No need to continue if a mismatch is found
        end
    end
else
    sameContentsSize = false; % If the cell arrays are not the same size
end

% Now you have two flags: sameCellSize and sameContentsSize
% If both are true, the cell arrays have identical structure
if sameCellSize && sameContentsSize
    disp('The four cell arrays have identical structure.');
else
    disp('The four cell arrays do not have identical structure.');
end

%% within subject between subject effect

df = readtable('/Users/h/Desktop/pain_withinbetween.csv');
sub_list = unique(df.sub);

for i= 1:1:length(sub_list)
    index = find(df.sub ==sub_list(i));
    model1_X{i} = df.EXPECT_demean(index);  %
    model1_M{i} = df.NPSpos(index); 
    model1_Y{i} = df.RATING_outcome(index); 
    cov_mediation_paincue{i} = [ df.stim(index) df.EXPECT_cmc(index) ];
    
end
wh_outlier = cellfun(@(x) abs(x - mean(x)) > 3*std(x), model1_M, 'UniformOutput', false);


for i= 1:1:length(sub_list)
% model1_Mtrimmed{i} = model1_M{i};
model1_Mremovedpts{i} = model1_M{i}(wh_outlier{i});
% model1_Mtrimmed{i}(wh_outlier{i}) = [];
model1_Mtrimmed{i} = model1_M{i}(~wh_outlier{i});
model1_Xtrimmed{i} = model1_X{i}(~wh_outlier{i});
model1_Ytrimmed{i} = model1_Y{i}(~wh_outlier{i});
cov_mediation_paincue_trimmed{i} = cov_mediation_paincue{i}(~wh_outlier{i});

end


save model1_mediation_N-109_X-expect_M-NPS_Y-outcome model1* cov* fop


% figure; barplot_columns(model1_Mremovedpts, 'nofig', 'title', 'NPSpos trimmed', 'noviolin');

[paths_M_tolerance, stats_M_tolerance] = mediation(model1_Xtrimmed, model1_Ytrimmed, model1_Mtrimmed,'covs', cov_mediation_paincue_trimmed ,  'boot', 'verbose','plots', ...
    'names', {'Expectation (within)' 'Outcome rating' 'NPSpos'},'bootsamples', 10000);

%%
sub_list = unique(df.sub);

for i= 1:1:length(sub_list)
    index = find(df.sub ==sub_list(i));
    model1_X{i} = df.EXPECT_cmc(index);  %
    model1_M{i} = df.NPSpos(index); 
    model1_Y{i} = df.RATING_outcome(index); 
    cov_mediation_paincue{i} = [ df.stim(index) df.EXPECT_demean(index)];
    
end
wh_outlier = cellfun(@(x) abs(x - mean(x)) > 3*std(x), model1_M, 'UniformOutput', false);


for i= 1:1:length(sub_list)
% model1_Mtrimmed{i} = model1_M{i};
model1_Mremovedpts{i} = model1_M{i}(wh_outlier{i});
% model1_Mtrimmed{i}(wh_outlier{i}) = [];
model1_Mtrimmed{i} = model1_M{i}(~wh_outlier{i});
model1_Xtrimmed{i} = model1_X{i}(~wh_outlier{i});
model1_Ytrimmed{i} = model1_Y{i}(~wh_outlier{i});
cov_mediation_paincue_trimmed{i} = cov_mediation_paincue{i}(~wh_outlier{i});

end
fop = unique(df.composite_score);



save model1_mediation_N-109_X-expect_M-NPS_Y-outcome model1* cov* fop


% figure; barplot_columns(model1_Mremovedpts, 'nofig', 'title', 'NPSpos trimmed', 'noviolin');

[paths_M_tolerance, stats_M_tolerance] = mediation(model1_Xtrimmed, model1_Ytrimmed, model1_Mtrimmed,'covs', cov_mediation_paincue_trimmed ,  'boot', 'verbose','plots', ...
    'names', {'Expectation (between)' 'Outcome rating' 'NPSpos'},'bootsamples', 10000);

