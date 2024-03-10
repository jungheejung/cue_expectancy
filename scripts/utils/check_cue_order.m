
% load SPM
% subset SPM
session = 1;
% run = matlabbatch{1,1}.spm.stats.fmri_spec.sess(session).cond;
run = SPM.Sess(session).U;

%%%%%%%%%%%%%%%%%%%%%%
% CUE epoch
%%%%%%%%%%%%%%%%%%%%%%
disp('CUE epoch')
% Loop through the structure array to find a match
for i = 1:length(run)
    if strcmp(run(i).name, 'CUE_cue-high')
        fprintf('Match found at index %d\n', i);
        cuehighIndex = i;
        break; % Exit the loop once the match is found
    end
end

for i = 1:length(run)
    if strcmp(run(i).name, 'CUE_cue-low')
        fprintf('Match found at index %d\n', i);
        cuelowIndex = i;
        break; % Exit the loop once the match is found
    end
end

high_onset = run(cuehighIndex).ons;
low_onset = run(cuelowIndex).ons;

% Create "cue" array with appropriate labels
cue_high = repmat({'high'}, length(high_onset), 1);
cue_low = repmat({'low'}, length(low_onset), 1);
cue = [cue_high; cue_low];

% Combine the onsets
onset = [high_onset; low_onset];
onset_table = table(cue, onset);
sorted_onset_table = sortrows(onset_table, 'onset');
disp(sorted_onset_table);

%%%%%%%%%%%%%%%%%%%%%%
% CUE-modulated STIM epoch
%%%%%%%%%%%%%%%%%%%%%%
disp('CUE-modulated STIM epoch');
cueH_stimH_ind = findIndex(run, 'STIM_cue-high_stim-high');
cueH_stimM_ind = findIndex(run, 'STIM_cue-high_stim-med');
cueH_stimL_ind = findIndex(run, 'STIM_cue-high_stim-low');
cueL_stimH_ind = findIndex(run, 'STIM_cue-low_stim-high');
cueL_stimM_ind = findIndex(run, 'STIM_cue-low_stim-med');
cueL_stimL_ind = findIndex(run, 'STIM_cue-low_stim-low');

cueH_stimH_ons = run(cueH_stimH_ind).ons;
cueH_stimM_ons = run(cueH_stimM_ind).ons;
cueH_stimL_ons = run(cueH_stimL_ind).ons;
cueL_stimH_ons = run(cueL_stimH_ind).ons;
cueL_stimM_ons = run(cueL_stimM_ind).ons;
cueL_stimL_ons = run(cueL_stimL_ind).ons;

cueH_stimH_label = repmat({'high'}, length(cueH_stimH_ons), 1);
cueH_stimM_label = repmat({'high'}, length(cueH_stimM_ons), 1);
cueH_stimL_label = repmat({'high'}, length(cueH_stimL_ons), 1);
cueL_stimH_label = repmat({'low'}, length(cueL_stimH_ons), 1);
cueL_stimM_label = repmat({'low'}, length(cueL_stimM_ons), 1);
cueL_stimL_label = repmat({'low'}, length(cueL_stimL_ons), 1);

label_6cond = [cueH_stimH_label; cueH_stimM_label; cueH_stimL_label; cueL_stimH_label; cueL_stimM_label; cueL_stimL_label];
onset_6cond = [cueH_stimH_ons;cueH_stimM_ons; cueH_stimL_ons; cueL_stimH_ons; cueL_stimM_ons; cueL_stimL_ons];
table_6cond = table(label_6cond, onset_6cond);
sorted_6cond = sortrows(table_6cond, 'onset_6cond');
disp(sorted_6cond);

function returnIndex = findIndex(run, key)
    % Initialize the index variable to indicate no match found (optional)
    returnIndex = -1; % Use -1 or another indicator value to represent no match found
    
    for i = 1:length(run)
        if strcmp(run(i).name, key)
            fprintf('Match found at index %d\n', i);
            returnIndex = i;
            break; % Exit the loop once the match is found
        end
    end
    
    % Optionally, handle the case where no match is found
    if returnIndex == -1
        fprintf('No match found for CUE_cue-low.\n');
    end
end
