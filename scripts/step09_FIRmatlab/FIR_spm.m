% %%%%%%%% OUTLINE
% load TR event files
% extract onset time per condition
% load brain data
% plot HRF
% TODO: save plot
% TODO: save extracted values per subject, session, run, runtype, ROI
% %%%%%%%% 

function FIR_spm(sub, onset_dir, main_dir, fmriprep_dir, badruns_json, save_dir)
disp(strcat('--------------------',sub,'----------------'));
TR = 0.46;
T = 20;
mode = 0;
atlas_obj = load_atlas('canlab2018_2mm');
labels = atlas_obj.labels;

% dictionary _________

% Create a structure similar to the Python dictionary
rois.PHG = [126, 155, 127];
rois.V1 = [1];
rois.SM = [8,9,51,52,53];
rois.MT = [2,23];
rois.RSC = [14];
rois.LO_DEP = [20,21,159,156,157]
rois.LOC = [140,141,157,156,159,2,23]
rois.FFC= [18]
rois.PIT= [22]
rois.TPJ= [139,140,141]
rois.pSTS= [28,139]
rois.AIP= [117, 116, 148, 147]
rois.premotor= [78,80]
% Add other keys and arrays...

% Define a function that takes a key and array as input
function_name = @(key, array) disp(['Key: ' key ', Array: ' mat2str(array)]);

% Loop through the structure fields and call the function for each key-value pair
fields = fieldnames(rois);
for i = 1:length(fields)
    key = fields{i};
    array = rois.(key);
    function_name(key, array);
end
% events_fname = '/Users/h/Documents/projects_local/sandbox/fmriprep_bold/sub-0002/ses-01/onset/sub-0002_ses-01_task-cue_run-01_runtype-pain_events.tsv';
% events_fname = fullfile(onset_dir, sub, ses, )

if ~exist(fullfile(save_dir, sub), 'dir')
    mkdir(fullfile(save_dir, sub))
end
% find nifti files
niilist = dir(fullfile(fmriprep_dir, sub,  '*/func/*task-social*_bold.nii'));
nT = struct2table(niilist); % convert the struct array to a table
sortedT = sortrows(nT, 'name'); % sort the table by 'DOB'

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
    highcue = strcmp(cue.pmod_cuetype,'high_cue');
    lowcue = strcmp(cue.pmod_cuetype,'low_cue');
    highstim = strcmp(cue.pmod_stimtype, 'high_stim');
    medstim = strcmp(cue.pmod_stimtype, 'med_stim');
    lowstim = strcmp(cue.pmod_stimtype, 'low_stim');

    keyword = extractBetween(onset_glob.name, 'run-0', '_events.tsv');
    task = char(extractAfter(keyword, '-'));

    if strcmp(task,'pain')
        test = dir(fullfile(onset_glob.folder, strcat(sub, '_', ses, '_task-cue_',run, '*_events_ttl.tsv')));
        if ~isempty(test)
            onset_fname = fullfile(char(test.folder), char(test.name));
            disp(strcat('this is a pain run with a ttl file: ', onset_fname))
        else
            disp(strcat('this is a pain run without a ttl file'))
        end
    end
    
    disp(strcat('task: ', task));
    disp(strcat('[ STEP 05 ]creating motion covariate text file...'));



events = readtable(onset_fname, "FileType","delimitedtext");

% [sub, ses, task, run, runtype] = extract_bids(filename);

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

onset_cueH_stimH_Time = zeros(872,1);   onset_cueH_stimH_Time(onset_cueH_stimH)=1;
onset_cueL_stimH_Time = zeros(872,1);   onset_cueL_stimH_Time(onset_cueL_stimH)=1;
onset_cueH_stimM_Time = zeros(872,1);   onset_cueH_stimM_Time(onset_cueH_stimM)=1;
onset_cueL_stimM_Time = zeros(872,1);   onset_cueL_stimM_Time(onset_cueL_stimM)=1;
onset_cueH_stimL_Time = zeros(872,1);   onset_cueH_stimL_Time(onset_cueH_stimL)=1;
onset_cueL_stimL_Time = zeros(872,1);   onset_cueL_stimL_Time(onset_cueL_stimL)=1;

Runc = {onset_cueH_stimH_Time  onset_cueL_stimH_Time onset_cueH_stimM_Time onset_cueL_stimM_Time onset_cueH_stimL_Time onset_cueL_stimL_Time};

% load fmri data

fmriprep_fname = fullfile(fmriprep_dir, sub, ses, 'func', strcat(sub, '_', ses, '_task-social_acq-mb8_',run01, '_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'));
% '/Users/h/Documents/projects_local/sandbox/fmriprep_bold/sub-0002/ses-01/func/sub-0002_ses-01_task-social_acq-mb8_run-1_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'
fmridata = fmri_data(fmriprep_fname);
[parcel_means, parcel_pattern_expression, parcel_valence, ~, ~, voxel_count]=apply_parcellation(fmridata, atlas_obj);
% timeseries_parcel = reshape(parcel_means, [1, size(parcel_means)]);
disp("------loaded fmriprep image and parcellation! --------")
% for i=1:length(atlas_obj.labels)



% timeseries_parcel = reshape(parcel_means, [1, size(parcel_means)]);

% for i=3%:length(labels)
for i = 1:length(fields)

    key = fields{i};
    array = rois.(key);
    function_name(key, array);


    tc = mean(parcel_means(:,array),2);% timeseries_parcel(sub,:,[8,9,51,52,53])';
    [h, fit, e, param]=hrf_fit_one_voxel(tc,TR,Runc,T,'FIR',0); % 0: non-smooth, 1: smooth

    % Create a sample 6x20 double array
    data = h';
    disp(strcat("runtype: ", runtype)); 
    % Create values for the additional columns to be appended
    sub_col = repmat(sub, 6, 1);    ses_col = repmat(ses, 6, 1);
    run_col = repmat(run, 6, 1);    runtype_col = repmat(runtype, 6, 1);
    ROI_col = repmat(key, 6, 1);    condition_col = {"cueH_stimH";  "cueL_stimH"; "cueH_stimM"; "cueL_stimM" ;"cueH_stimL" ;"cueL_stimL"};
    disp(sub_col);    
    disp(size(sub_col)); disp(size(data));
    % Combine the data and additional columnsi
    combinedDataCell = [];
    %combinedData = [sub_col, ses_col, run_col, runtype_col, ROI_col, condition_col, num2cell(data)];
    combinedDataCell = [cellstr(sub_col), cellstr(ses_col), cellstr(run_col), ...
                        cellstr(runtype_col), cellstr(ROI_col), cellstr(condition_col), ...
                        num2cell(data)]; % Convert data to cell array along rows
    
    % Create a table from the combined data
    dataTable = cell2table(combinedDataCell, ...
        'VariableNames', {'sub', 'ses', 'run', 'runtype', 'ROI', 'condition', 'tr1', 'tr2', 'tr3', 'tr4', 'tr5', 'tr6', 'tr7', 'tr8', 'tr9', 'tr10', ...
        'tr11', 'tr12', 'tr13', 'tr14', 'tr15', 'tr16', 'tr17', 'tr18', 'tr19', 'tr20', 'tr21', 'tr22', 'tr23', 'tr24', 'tr25', 'tr26', 'tr27', 'tr28', 'tr29', 'tr30',...
        'tr31', 'tr32', 'tr33', 'tr34', 'tr35', 'tr36', 'tr37', 'tr38', 'tr39', 'tr40', 'tr41', 'tr42'});
    
    % Display the resulting table
    disp(dataTable);
    disp(strcat(sub, ses, run, runtype{1}, key));
    save_fname = fullfile(save_dir, sub, strcat(sub,'_',ses,'_',run,'_runtype-',runtype{1},'-roi-',key,'_tr-42.csv' ));
    writetable(dataTable, save_fname);
    %     H_All_Reg(:,sub,i)=h(:,1);
    %     H_All_Neg(:,sub,i)=h(:,2);
    %     H_All_Neu(:,sub,i)=h(:,3);
    plot(h(:,1), 'color', 'red', 'LineStyle', '-');
    hold on;
    plot(h(:,2), 'color', 'red', 'LineStyle', '--');
    plot(h(:,3), 'color', 'black', 'LineStyle', '-');
    plot(h(:,4), 'color', 'black', 'LineStyle', '--');
    plot(h(:,5), 'color', 'blue', 'LineStyle', '-');
    plot(h(:,6), 'color', 'blue', 'LineStyle', '--');
%     save TODO:
    save_plotname = fullfile(save_dir, sub, strcat(sub,'_',ses,'_',run,'_runtype-',runtype{1},'-roi-',key,'_tr-42.png' ));
    saveas(gcf, save_plotname, 'png');
    hold off;
    %     plot(h(:,3), 'color', 'b');

%    [h1,t1,w1,w_times1,halfh1, auc1] = fir2htw2(h(:,1));
%    [h2,t2,w2,w_times2,halfh2, auc2] = fir2htw2(h(:,2));
%    [h3,t3,w3,w_times3,halfh3, auc3] = fir2htw2(h(:,3));
%    [h4,t4,w4,w_times4,halfh4, auc4] = fir2htw2(h(:,4));
%    [h5,t5,w5,w_times5,halfh5, auc5] = fir2htw2(h(:,5));
%    [h6,t6,w6,w_times6,halfh6, auc6] = fir2htw2(h(:,6));
%    Martin_Param{i,sub}=param;
%   IndexM1(sub,i,:)=[h1,t1,w1,w_times1,halfh1, auc1];
%   IndexM2(sub,i,:)=[h2,t2,w2,w_times2,halfh2, auc2];
%   IndexM3(sub,i,:)=[h3,t3,w3,w_times3,halfh3, auc3];
%   IndexM4(sub,i,:)=[h4,t4,w4,w_times4,halfh4, auc4];
%   IndexM5(sub,i,:)=[h5,t5,w5,w_times5,halfh5, auc5];
%   IndexM6(sub,i,:)=[h6,t6,w6,w_times6,halfh6, auc6];
end

end
end
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
