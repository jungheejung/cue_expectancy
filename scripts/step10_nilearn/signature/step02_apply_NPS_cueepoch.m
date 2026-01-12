% function step02_apply_NPS()
%% Data directories and parameters setup

main_dir = '/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/deriv01_signature/rampup_plateau_canlab';
singletrial_dir = fullfile('/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupplateau');

d = dir(singletrial_dir);
dfolders = d([d(:).isdir]);
dfolders = dfolders(~ismember({dfolders(:).name},{'.','..','archive','beh','sub-0000'}));
% Further filter to include only folders that start with "sub-"
dfolders_remove = dfolders(startsWith({dfolders.name}, 'sub-'));

key = 'cue';
sub_list = {dfolders_remove.name};
key_list = {'cue'}; % Add 'cue' to this list if needed

%% Initialize a table to store the results
resultTable = table();

% Define region names once (these should be consistent across all subjects)
posnames = {'vermis', 'rIns', 'rV1', 'rThal', 'lIns', 'rdpIns', 'rS2_Op', 'dACC'};
negnames = {'rLOC', 'lLOC', 'rpLOC', 'pgACC', 'lSTS', 'rIPL', 'PCC'};

for sub_ind = 61:101%length(sub_list)
    sub = sub_list{sub_ind};
    fprintf('Processing subject %d of %d: %s\n', sub_ind, length(sub_list), sub);

    %% Process each file
    ses = '*';    run = '*';    runtype = 'pain';    event = 'cue';
    fname_template = fullfile(singletrial_dir, sub, ...
        strcat(sub, '_', ses, '_', run, '_runtype-', runtype, '_event-', event,'*.nii.gz'));
    fname_list = dir(fname_template);
    
    if isempty(fname_list)
        fprintf('Warning: No files found for %s\n', sub);
        continue;
    end

    % Apply NPS
    dataobj = fmri_data(filenames(fname_template));
    [nps_values, image_names, ~, npspos_exp_by_region, npsneg_exp_by_region, npspos, npsneg] = apply_nps(dataobj);

    %% Extract data from potentially wrapped cell arrays
    % nps_values might be {1x1 cell} containing {Nx1 double}
    if iscell(nps_values) && numel(nps_values) == 1
        nps_values = nps_values{1};
    end
    
    %% Determine number of trials from the actual data
    % The number of trials is the length of nps_values (after unwrapping)
    num_trials = length(nps_values);
    fprintf('  Found %d trials\n', num_trials);
    
    %% Extract filenames from character matrix or cell array
    fname_cell = cell(num_trials, 1);
    
    % image_names might be wrapped in a cell - unwrap if needed
    if iscell(image_names) && numel(image_names) == 1 && ischar(image_names{1})
        % It's a single cell containing a char matrix
        image_names = image_names{1};
    end
    
    for i = 1:num_trials
        % Handle both cell array and char matrix
        if iscell(image_names)
            fname_raw = image_names{i};
        else
            fname_raw = strtrim(image_names(i, :));
        end
        
        % Ensure it's a char array
        if iscell(fname_raw)
            fname_raw = fname_raw{1};
        end
        fname_raw = char(fname_raw);
        
        % Extract just filename if it's a full path
        if any(fname_raw == '/' | fname_raw == '\')
            [~, fname_only, ext] = fileparts(fname_raw);
            if strcmp(ext, '.gz')
                [~, fname_only, ~] = fileparts(fname_only);
                fname_cell{i} = [fname_only, '.nii.gz'];
            else
                fname_cell{i} = [fname_only, ext];
            end
        else
            fname_cell{i} = fname_raw;
        end
    end
    
    %% Extract region values for each trial
    % npspos and npsneg are arrays of region objects
    % Each region object has a .dat field with num_trials values
    pos_matrix = zeros(num_trials, length(posnames));
    neg_matrix = zeros(num_trials, length(negnames));
    
    for i = 1:length(npspos)
        pos_matrix(:, i) = npspos(i).dat;
    end
    
    for i = 1:length(npsneg)
        neg_matrix(:, i) = npsneg(i).dat;
    end
    
    % Calculate NPSpos and NPSneg as sum of regions
    npspos_sum = sum(pos_matrix, 2);  % Sum across columns for each row
    npsneg_sum = sum(neg_matrix, 2);
    
    %% Build table using table() constructor with explicit column names
    % This is the most reliable way to ensure proper structure
    subtable = table(fname_cell, nps_values, npspos_sum, npsneg_sum, ...
        pos_matrix(:,1), pos_matrix(:,2), pos_matrix(:,3), pos_matrix(:,4), ...
        pos_matrix(:,5), pos_matrix(:,6), pos_matrix(:,7), pos_matrix(:,8), ...
        neg_matrix(:,1), neg_matrix(:,2), neg_matrix(:,3), neg_matrix(:,4), ...
        neg_matrix(:,5), neg_matrix(:,6), neg_matrix(:,7), ...
        'VariableNames', ...
        {'singletrial_fname', 'NPS', 'NPSpos', 'NPSneg', ...
         posnames{1}, posnames{2}, posnames{3}, posnames{4}, ...
         posnames{5}, posnames{6}, posnames{7}, posnames{8}, ...
         negnames{1}, negnames{2}, negnames{3}, negnames{4}, ...
         negnames{5}, negnames{6}, negnames{7}});
    
    %% Verify structure
    fprintf('  Table size: %d rows x %d columns\n', size(subtable, 1), size(subtable, 2));
    
    %% Append to the result table
    resultTable = [resultTable; subtable];
    
    %% Save individual subject file
    outfile = fullfile(main_dir, sprintf('%s_CANlab_applyNPS_singletrial_rampupplateau_epoch-%s.csv', sub, event));
    writetable(subtable, outfile);
    fprintf('  Saved: %s\n', outfile);
end

%% Save the combined result table
combined_outfile = fullfile(main_dir, sprintf('CANlab_applyNPS_singletrial_rampupplateau_epoch-%s.csv', event));
writetable(resultTable, combined_outfile);
fprintf('Saved combined file: %s\n', combined_outfile);

% end

function subFolders = getSubFolders(singletrial_dir)
d = dir(singletrial_dir);
isSub = startsWith({d.name}, 'sub-') & [d.isdir];
subFolders = {d(isSub).name};
end