% %%%%%%%% OUTLINE
% load TR event files
% extract onset time per condition
% load brain data
% plot HRF
% TODO: save plot
% TODO: save extracted values per subject, session, run, runtype, ROI
% %%%%%%%%

function FIR_spm_ttl2_parallel_pervoxel(sub, onset_dir, main_dir, fmriprep_dir, badruns_json, save_dir, key)
disp(strcat('--------------------',sub,'----------------'));
addpath(genpath(fullfile(fmriprep_dir, sub)));
TR = 0.46;
T = 20;
mode = 0;
atlas_obj = load_atlas('canlab2018_2mm');
labels = atlas_obj.labels;
% keyword = 'TPJ';
array = getROIArray(key);
% disp(tpjArray);
% dictionary _________

% Create a structure similar to the Python dictionary
rois.PHG = [251,252,309,310,253,254]; %[126, 155, 127];
rois.V1 = [1,2];%[1];
rois.SM =[15,16,17,18,101,102,103,104,105,106];%[8,9,51,52,53];
rois.MT = [3,4,45,46]; %[2,23];
rois.RSC =[27,28];%[14];
% rois.LO_DEP = [] %[20,21,159,156,157];
rois.LOC = [279,280,281,282,313,314,311,312,317,318,3,4,45,46]; %[140,141,157,156,159,2,23];
rois.FFC= [35,37];%[18];
rois.PIT= [43,44]; %[22];
rois.TPJ= [277,278,279,280,281,282];%[139,140,141];
rois.pSTS= [55,56,277,278]; %[28,139];
rois.AIP= [233,234,231,232,295,296,293,294]; %[117, 116, 148, 147];
rois.premotor= [155,156,159,160]; %[78,80];
rois.rINS = [216,218,226];
rois.dACC = [82,115,116];

% events_fname = '/Users/h/Documents/projects_local/sandbox/fmriprep_bold/sub-0002/ses-01/onset/sub-0002_ses-01_task-cue_run-01_runtype-pain_events.tsv';
% events_fname = fullfile(onset_dir, sub, ses, )

if ~exist(fullfile(save_dir, sub), 'dir')
    mkdir(fullfile(save_dir, sub))
end
% find nifti files
niilist = dir(fullfile(fmriprep_dir, sub,  '*/func/*task-social*_bold.nii'));
nT = struct2table(niilist); % convert the struct array to a table
sortedT = sortrows(nT, 'name'); % sort the table by 'DOB'
disp(sortedT);
sortedT.sub_num(:) = str2double(extractBetween(sortedT.name, 'sub-', '_'));
sortedT.ses_num(:) = str2double(extractBetween(sortedT.name, 'ses-', '_'));
sortedT.run_num(:) = str2double(extractBetween(sortedT.name, 'run-', '_'));

nii_col_names = sortedT.Properties.VariableNames;
nii_num_column = nii_col_names(endsWith(nii_col_names, '_num'));

% find onset files
onsetlist = dir(fullfile(onset_dir, sub, '*', strcat(sub, '_*_task-cue_*_events.tsv')));
onsetT = struct2table(onsetlist);
sortedonsetT = sortrows(onsetT, 'name');

sortedonsetT.sub_num(:) = str2double(extractBetween(sortedonsetT.name, 'sub-', '_'));
sortedonsetT.ses_num(:) = str2double(extractBetween(sortedonsetT.name, 'ses-', '_'));
sortedonsetT.run_num(:) = str2double(extractBetween(sortedonsetT.name, 'run-', '_'));

onset_col_names = sortedonsetT.Properties.VariableNames;
onset_num_column = onset_col_names(endsWith(onset_col_names, '_num'));
disp(onset_num_column)

% load badruns from json _________________________________________________________________
bad_runs_table = readBadRunsFromJSON(badruns_json);
json_col_names = bad_runs_table.Properties.VariableNames;
json_num_colomn = json_col_names(endsWith(json_col_names, '_num'));
disp(bad_runs_table);

[~, ia] = ismember(sortedT(:, nii_num_column), bad_runs_table(:,json_num_colomn), 'rows');
intersectRuns = sortedT(setdiff(1:size(sortedT, 1), ia), :);
intersect_col_names = intersectRuns.Properties.VariableNames;
inter_num_column = intersect_col_names(endsWith(intersect_col_names, '_num'));


%intersection of nifti and onset files
A = intersect( intersectRuns(:, inter_num_column), sortedonsetT(:, onset_num_column) );
disp(A);

%% 3. for loop "run-wise" _______________________________________________________
for run_ind = 1:size(A, 1)
    disp(strcat('______________________run', num2str(run_ind), '____________________________'));
    % [x] extract sub, ses, run info
    sub = []; ses = []; run = [];
    sub = strcat('sub-', sprintf('%04d', A.sub_num(run_ind)));
    ses = strcat('ses-', sprintf('%02d', A.ses_num(run_ind)));
    run01 = strcat('run-', sprintf('%01d', A.run_num(run_ind)));
    run = strcat('run-', sprintf('%02d', A.run_num(run_ind)));
    run_num = A.run_num(run_ind);
    % runtype = A.runtype(run_ind);
    disp(strcat('[ STEP 03 ] gunzip and saving nifti...'));
    %smooth_fname = fullfile(fmriprep_dir, sub, ses,  ...
    %    strcat('smooth-6mm_', sub, '_', ses, '_task-cue_acq-mb8_', run, '_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'));
    func = fullfile(fmriprep_dir, sub, ses, 'func',...
        strcat( sub, '_', ses, '_task-social_acq-mb8_', run01, '_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'));
    
    if ~exist(func, 'file')
        disp(strcat('ABORT [!] ', func, 'does not exist'))
        break
    end
    
    disp(strcat('[ STEP 04 ]constructing contrasts...'));
    onset_glob = dir(fullfile(onset_dir, sub, ses, strcat(sub, '_', ses, '_task-cue_', run, '*_events.tsv')));
    onset_fname = fullfile(char(onset_glob.folder), char(onset_glob.name));
    runtype = extractBetween(onset_fname, 'runtype-', '_');
    if isempty(onset_glob)
        disp('ABORT')
        break
    end
    
    disp(strcat('onset folder: ', onset_glob.folder));
    disp(strcat('onset file:   ', onset_glob.name));
    cue = struct2table(tdfread(onset_fname));
    
    % bug report: there were spaces that added to a mistmach in dataframes
    % remove spaces
    cue.pmod_cuetype = cellstr(cue.pmod_cuetype);
    cue.pmod_stimtype = cellstr(cue.pmod_stimtype);
    cue.pmod_stimtype = strtrim(cue.pmod_stimtype);
    cue.pmod_cuetype = strtrim(cue.pmod_cuetype);
    disp(cue.pmod_cuetype)
    
    keyword = extractBetween(onset_glob.name, 'run-0', '_events.tsv');
    task = char(extractAfter(keyword, '-'));
%    onset_fname = fullfile(char(test.folder), char(test.name));
    % if strcmp(task,'pain')
    %     test = dir(fullfile(onset_glob.folder, strcat(sub, '_', ses, '_task-cue_',run, '*_events_ttl.tsv')));
    %     if ~isempty(test)
    %         onset_fname = fullfile(char(test.folder), char(test.name));
    %         disp(strcat('this is a pain run with a ttl file: ', onset_fname))
    %     else
    %         disp(strcat('this is a pain run without a ttl file'))
    %     end
    % end
    
    disp(strcat('task: ', task));
    disp(strcat('[ STEP 05 ]creating motion covariate text file...'));
    
    
    events = readtable(onset_fname, "FileType","delimitedtext");
    
    cueH_stimH = events(strcmp(events.pmod_cuetype , 'high_cue') & strcmp(events.pmod_stimtype , 'high_stim'), :);
    cueL_stimH = events(strcmp(events.pmod_cuetype , 'low_cue') & strcmp(events.pmod_stimtype , 'high_stim'), :);
    
    cueH_stimM = events(strcmp(events.pmod_cuetype , 'high_cue') & strcmp(events.pmod_stimtype , 'med_stim'), :);
    cueL_stimM = events(strcmp(events.pmod_cuetype , 'low_cue') & strcmp(events.pmod_stimtype , 'med_stim'), :);
    
    cueH_stimL = events(strcmp(events.pmod_cuetype , 'high_cue') & strcmp(events.pmod_stimtype , 'low_stim'), :);
    cueL_stimL = events(strcmp(events.pmod_cuetype , 'low_cue') & strcmp(events.pmod_stimtype , 'low_stim'), :);
    
    TR = 0.46;
    Time_Index=1:4;
    ones(1,length(Time_Index));
    onset_cueH_stimH = round(cueH_stimH.onset03_stim/TR);
    onset_cueL_stimH = round(cueL_stimH.onset03_stim/TR);
    onset_cueH_stimM = round(cueH_stimM.onset03_stim/TR);
    onset_cueL_stimM = round(cueL_stimM.onset03_stim/TR);
    onset_cueH_stimL = round(cueH_stimL.onset03_stim/TR);
    onset_cueL_stimL = round(cueL_stimL.onset03_stim/TR);
    onset_rating     = [round(events.onset02_ratingexpect/TR); round(events.onset04_ratingoutcome/TR)];
    onset_cue        = round(events.onset01_cue/TR);
    
    onset_cueH_stimH_Time = zeros(872,1);   onset_cueH_stimH_Time(onset_cueH_stimH)=1;
    onset_cueL_stimH_Time = zeros(872,1);   onset_cueL_stimH_Time(onset_cueL_stimH)=1;
    onset_cueH_stimM_Time = zeros(872,1);   onset_cueH_stimM_Time(onset_cueH_stimM)=1;
    onset_cueL_stimM_Time = zeros(872,1);   onset_cueL_stimM_Time(onset_cueL_stimM)=1;
    onset_cueH_stimL_Time = zeros(872,1);   onset_cueH_stimL_Time(onset_cueH_stimL)=1;
    onset_cueL_stimL_Time = zeros(872,1);   onset_cueL_stimL_Time(onset_cueL_stimL)=1;
    onset_rating_Time     = zeros(872,1);   onset_rating_Time(onset_rating)=1;
    onset_cue_Time        = zeros(872,1);   onset_cue_Time(onset_cue)=1;
    
    Runc = {onset_cueH_stimH_Time  onset_cueL_stimH_Time onset_cueH_stimM_Time onset_cueL_stimM_Time onset_cueH_stimL_Time onset_cueL_stimL_Time onset_rating_Time onset_cue_Time};
    
    % load fmri data
    
    fmriprep_fname = fullfile(fmriprep_dir, sub, ses, 'func', strcat(sub, '_', ses, '_task-social_acq-mb8_',run01, '_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'));
    % '/Users/h/Documents/projects_local/sandbox/fmriprep_bold/sub-0002/ses-01/func/sub-0002_ses-01_task-social_acq-mb8_run-1_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'
    fmridata = fmri_data(fmriprep_fname);
    % confounds = TODO
    tr = 0.46;
       %% TODO
    [preproc_dat]=canlab_connectivity_preproc(fmridata, confounds, 'hpf', .007, tr, 'average_over', 'no_plots');
    %% TODO
    [parcel_means, parcel_pattern_expression, parcel_valence, ~, ~, voxel_count]=apply_parcellation(preproc_dat, atlas_obj);
    disp("------loaded fmriprep image and parcellation! --------")
    num_conditions = size(Runc,2);
    
    dataTables = cell(1, numel(array));
    tc = parcel_means(:,array);% timeseries_parcel(sub,:,[8,9,51,52,53])';
    for col_idx = 1:numel(array)
        col = array(col_idx);
        tc = parcel_means(:, col);
        [h, fit, e, param] = hrf_fit_one_voxel(tc, TR, Runc, T, 'FIR', 0);
            % Create data and additional columns as before
       % Create a sample 6x20 double array
       data = h';
       disp(strcat("runtype: ", runtype));
       
       % Create values for the additional columns to be appended
       sub_col = repmat(sub, num_conditions, 1);    ses_col = repmat(ses, num_conditions, 1);
       run_col = repmat(run, num_conditions, 1);    runtype_col = repmat(runtype, num_conditions, 1);
       ROI_col = repmat(key, num_conditions, 1);    condition_col = {"cueH_stimH";  "cueL_stimH"; "cueH_stimM"; "cueL_stimM" ;"cueH_stimL" ;"cueL_stimL"; "rating"; "cue"};
       ROIindex_col = repmat(array(col_idx), num_conditions, 1);
       disp(sub_col);
       disp(size(sub_col)); disp(size(data));
       % Combine the data and additional columnsi
       combinedDataCell = [];
       combinedDataCell = [cellstr(sub_col), cellstr(ses_col), cellstr(run_col), ...
           cellstr(runtype_col), cellstr(ROI_col), num2cell(ROIindex_col), cellstr(condition_col), ...
           num2cell(data)]; % Convert data to cell array along rows
       
        % Combine the data and additional columns
        combinedDataCell = [cellstr(sub_col), cellstr(ses_col), cellstr(run_col), ...
            cellstr(runtype_col), cellstr(ROI_col), num2cell(ROIindex_col), cellstr(condition_col), ...
            num2cell(data)];
        
        % Create a table from the combined data
        dataTable = cell2table(combinedDataCell, ...
            'VariableNames', {'sub', 'ses', 'run', 'runtype', 'ROI', 'ROIindex', 'condition', ...
            'tr1', 'tr2', 'tr3', 'tr4', 'tr5', 'tr6', 'tr7', 'tr8', 'tr9', 'tr10', ...
            'tr11', 'tr12', 'tr13', 'tr14', 'tr15', 'tr16', 'tr17', 'tr18', 'tr19', 'tr20', ...
            'tr21', 'tr22', 'tr23', 'tr24', 'tr25', 'tr26', 'tr27', 'tr28', 'tr29', 'tr30', ...
            'tr31', 'tr32', 'tr33', 'tr34', 'tr35', 'tr36', 'tr37', 'tr38', 'tr39', 'tr40', 'tr41', 'tr42'});
        
        % Store the current dataTable in the cell array
        dataTables{col_idx} = dataTable;
    end
    % [h, fit, e, param]=hrf_fit_one_voxel(tc,TR,Runc,T,'FIR',0); % 0: non-smooth, 1: smooth
    
    % % Create a sample 6x20 double array
    % data = h';
    % disp(strcat("runtype: ", runtype));
    
    % % Create values for the additional columns to be appended
    % sub_col = repmat(sub, num_conditions, 1);    ses_col = repmat(ses, num_conditions, 1);
    % run_col = repmat(run, num_conditions, 1);    runtype_col = repmat(runtype, num_conditions, 1);
    % ROI_col = repmat(key, num_conditions, 1);    condition_col = {"cueH_stimH";  "cueL_stimH"; "cueH_stimM"; "cueL_stimM" ;"cueH_stimL" ;"cueL_stimL"; "rating"; "cue"};
    % disp(sub_col);
    % disp(size(sub_col)); disp(size(data));
    % % Combine the data and additional columnsi
    % combinedDataCell = [];
    % combinedDataCell = [cellstr(sub_col), cellstr(ses_col), cellstr(run_col), ...
    %     cellstr(runtype_col), cellstr(ROI_col), cellstr(condition_col), ...
    %     num2cell(data)]; % Convert data to cell array along rows
    
    % % Create a table from the combined data
    % dataTable = cell2table(combinedDataCell, ...
    %     'VariableNames', {'sub', 'ses', 'run', 'runtype', 'ROI', 'condition', 'tr1', 'tr2', 'tr3', 'tr4', 'tr5', 'tr6', 'tr7', 'tr8', 'tr9', 'tr10', ...
    %     'tr11', 'tr12', 'tr13', 'tr14', 'tr15', 'tr16', 'tr17', 'tr18', 'tr19', 'tr20', 'tr21', 'tr22', 'tr23', 'tr24', 'tr25', 'tr26', 'tr27', 'tr28', 'tr29', 'tr30',...
    %     'tr31', 'tr32', 'tr33', 'tr34', 'tr35', 'tr36', 'tr37', 'tr38', 'tr39', 'tr40', 'tr41', 'tr42'});
    % Initialize an empty data table to store the concatenated result
    stackedDataTable = dataTables{1}; % Start with the first data table

    % Loop through the remaining data tables in the cell array and stack them
    for i = 2:numel(dataTables)
        stackedDataTable = vertcat(stackedDataTable, dataTables{i});
    end
    % Display the resulting table
    disp(stackedDataTable);
    disp(strcat(sub, ses, run, runtype{1}, key));
    save_fname = fullfile(save_dir, sub, strcat(sub,'_',ses,'_',run,'_runtype-',runtype{1},'_roi-',key,'_tr-42.csv' ));
    writetable(stackedDataTable, save_fname);
    
    plot(h(:,1), 'color', 'red', 'LineStyle', '-');
    hold on;
    plot(h(:,2), 'color', 'red', 'LineStyle', '--');
    plot(h(:,3), 'color', 'black', 'LineStyle', '-');
    plot(h(:,4), 'color', 'black', 'LineStyle', '--');
    plot(h(:,5), 'color', 'blue', 'LineStyle', '-');
    plot(h(:,6), 'color', 'blue', 'LineStyle', '--');
    %     save TODO:
    save_plotname = fullfile(save_dir, sub, strcat(sub,'_',ses,'_',run,'_runtype-',runtype{1},'_roi-',key,'_tr-42.png' ));
    saveas(gcf, save_plotname, 'png');
    hold off;
    
    
end

disp("------------------COMPLETE------------------");

    function [sub, ses, task, run, runtype] = extract_bids(filename)

        
        pattern = '/sub-(\w+)_ses-(\w+)_task-(\w+)_run-(\d+)_runtype-(\w+)_events\.tsv';
        matches = regexp(filename, pattern, 'tokens');
        
        if ~isempty(matches)
            sub = ['sub-', matches{1}{1}];
            ses = ['ses-', matches{1}{2}];
            task = ['task-', matches{1}{3}];
            run = ['run-', matches{1}{4}];
            runtype = matches{1}{5};
            
            disp(['Subject: ', sub]);
            disp(['Session: ', ses]);
            disp(['Task: ', task]);
            disp(['Run: ', run]);
            disp(['Runtype: ', runtype]);
        else
            disp('No matches found.');
        end
    end

    function roiArray = getROIArray(keyword)
        rois.PHG = [251,252,309,310,253,254];
        rois.V1 = [1,2];
        rois.SM =[15,16,17,18,101,102,103,104,105,106];
        rois.MT = [3,4,45,46];
        rois.RSC =[27,28];
        rois.LOC = [279,280,281,282,313,314,311,312,317,318,3,4,45,46];
        rois.FFC= [35,37];
        rois.PIT= [43,44];
        rois.TPJ= [277,278,279,280,281,282];
        rois.pSTS= [55,56,277,278];
        rois.AIP= [233,234,231,232,295,296,293,294];
        rois.premotor= [155,156,159,160];
        rois.rINS = [216,218,226];
        rois.dACC = [82,115,116];
        
        roiArray = rois.(keyword);
    end


function bad_runs_table = readBadRunsFromJSON(badruns_file)
    % Read the badruns_file and construct a table with sub_num, ses_num, and run_num
    bad_runs_table = table();

    try
        fid = fopen(badruns_file);
        json_str = fread(fid, '*char').';
        fclose(fid);
        bad_runs = jsondecode(json_str);
        
        subjects = fieldnames(bad_runs);
        num_subjects = numel(subjects);

        % Loop through each subject and their corresponding bad runs
        for i = 1:num_subjects
            sub = subjects{i};
            bad_run_list = bad_runs.(sub);
            num_bad_runs = numel(bad_run_list);
            sub_num = str2double(regexp(sub, '\d+', 'match'));
            % Extract the sub_num, ses_num, and run_num from each bad run
            for j = 1:num_bad_runs
                ses_num = str2double(extractBetween(bad_run_list{j}, 'ses-', '_run-'));
                run_num = str2double(regexp(bad_run_list{j}, 'run-(\d+)', 'tokens', 'once'));%extractBetween(bad_run_list{j}, 'ses-', '_run-');
%                 ses_num = str2double(run_info{1});
%                 run_num = str2double(run_info{2});

                % Append the data to the table
                new_row = table(sub_num, ses_num, run_num, 'VariableNames', {'sub_num', 'ses_num', 'run_num'});
                bad_runs_table = [bad_runs_table; new_row];
            end
        end

    catch
        disp('Error reading badruns JSON file.');
    end
end

end






