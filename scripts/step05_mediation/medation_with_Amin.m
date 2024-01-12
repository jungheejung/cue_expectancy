df = readtable('/Users/h/Desktop/cleanmerge_NPS_RL.csv');
sub_list = unique(df.sub);
% mapped_values = zeros(size(cue_array));

% Assign new values based on the content of each cell

for i= 1:1:length(sub_list)
    index = find(df.sub ==sub_list(i));
    X_mediation{i} = df.CUE_high_gt_low(index); %[df(index,col_x_mediation)];  %
    M_mediation{i} = df.RATING_expectation(index); %[df(index,col_M_mediation)];  % Guess temp as mediator
    Y_mediation{i} = df.NPSpos(index); %df.RATING_outcome(index); %[mediation_data_pain_guess(index,col_Y_mediation)];   %
    cov_mediation_paincue{i} = [df.stim(index) df.RATING_outcome(index) ];%df.ses(index) df.run(index)]; %[df.ses(index)]
    
end

[paths_M_tolerance, stats_M_tolerance] = mediation(X_mediation, Y_mediation, M_mediation,'covs', cov_mediation_paincue ,  'boot', 'verbose','plots', ...
    'names', {'Pain_Cue' 'NPS (pos)' 'Expectation rating (Jepma)'},'bootsamples', 10000);