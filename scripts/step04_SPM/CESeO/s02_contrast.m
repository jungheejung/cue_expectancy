function s02_contrast(sub, input_dir, main_dir, save_dir)

% NOTE 01 start jobs
disp('...STARTING JOBS');

rootgroup = settings; rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = 'v7.3'

if ~exist(fullfile(save_dir, sub), 'dir')
    mkdir(fullfile(save_dir, sub));
end
numscans = 56;
disacqs = 0;
disp(sub);
disp(strcat('[ STEP 01 ] setting parameters...'));

% contrast mapper _______________________________________________________
keySet = {'pain','vicarious','cognitive'};
con1 = [2 -1 -1];   con2 = [-1 2 -1];  con3 = [-1 -1 2];  con4 = [1 1 1];
con5 = [1 0 0]; con6 = [0 1 0]; con7 = [0 0 1];

m1 = containers.Map(keySet,con1);
m2 = containers.Map(keySet,con2);
m3 = containers.Map(keySet,con3);
m4 = containers.Map(keySet,con4);
m5 = containers.Map(keySet,con5);
m6 = containers.Map(keySet,con6);
m7 = containers.Map(keySet,con7);
% C E S e O  
% 1 2 3 4 5
epoch_cue               = [1,0,0,0,0];
epoch_motor             = [0,1,0,0,1];
epoch_stim              = [0,0,1,0,0];
pmod_stimXcue           = [0,0,0,1,0];


% NOTE 02 define directories _______________________________________________________
motion_dir = fullfile(main_dir, 'data', 'fmri', 'fmri02_motion');
onset_dir = fullfile(main_dir, 'data', 'fmri', 'fmri01_onset', 'onset02_SPM');

% fmriprep_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/dartmouth/fmriprep/fmriprep/'; % sub / ses
% main_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/';
% motion_dir = fullfile(main_dir, 'data', 'dartmouth', 'd05_motion');
% onset_dir = fullfile(main_dir, 'data', 'dartmouth', 'd04_EV_SPM');

% sub_num = sscanf(char(input),'%d');
disp( strcat('-----------------------',sub,'----------------------' ));
spm_fname = fullfile(input_dir, sub, 'SPM.mat');
load(spm_fname);

% NOTE 03 find intersection of nifti and onset files
paths = cellstr(SPM.xY.P);

% Get unique file paths (without slice numbers)
uniqueFilePaths = unique(cellfun(@(x) x(1:strfind(x, '.nii,')-1), paths, 'UniformOutput', false));

% Extract 'sub', 'ses', and 'run' info
numFiles = length(uniqueFilePaths);

subInfo = zeros(1, numFiles);  % Pre-allocate a matrix for efficiency
sesInfo = zeros(1, numFiles);   % We will keep these as cells since you didn't specify to change them
runInfo = zeros(1, numFiles);   % Same here

for i = 1:numFiles
    [~, fileName, ~] = fileparts(uniqueFilePaths{i});
    subInfo(i) = str2double(regexp(fileName, '(?<=sub-)\d+', 'match', 'once'));
    sesInfo(i) = str2double(regexp(fileName, '(?<=ses-)\d+', 'match', 'once'));
    runInfo(i) = str2double(regexp(fileName, '(?<=run-)\d+', 'match', 'once'));
end

% create a table. Aftereward, find the corresponding run-type info
sortedT = table(subInfo', sesInfo', runInfo', 'VariableNames', {'sub_num', 'ses_num', 'run_num'});

% NOTE 03 find intersection of nifti and onset files
% find nifti files
nii_col_names = sortedT.Properties.VariableNames;
nii_num_column = nii_col_names(endsWith(nii_col_names, '_num'));

% find onset files
onsetlist = dir(fullfile(onset_dir, sub, '*', strcat(sub, '_*_task-cue_*_events.tsv')));
onsetT = struct2table(onsetlist);
sortedonsetT = sortrows(onsetT, 'name');

sortedonsetT.sub_num(:) = str2double(extractBetween(sortedonsetT.name, 'sub-', '_'));
sortedonsetT.ses_num(:) = str2double(extractBetween(sortedonsetT.name, 'ses-', '_'));
sortedonsetT.run_num(:) = str2double(extractBetween(sortedonsetT.name, 'run-', '_'));
sortedonsetT.runtype(:) = extractBetween(sortedonsetT.name, 'runtype-', '_events.tsv');

onset_col_names = sortedonsetT.Properties.VariableNames;
onset_num_column = onset_col_names(endsWith(onset_col_names, '_num'));
disp(onset_num_column)
%intersection of nifti and onset files

% Use innerjoin to find the intersection and retain runtype info
A = innerjoin(sortedT, sortedonsetT, 'Keys', {'sub_num', 'ses_num', 'run_num'});


% C E S e O  
% 1 2 3 4 5
epoch_cue               = [1,0,0,0,0];
epoch_motor             = [0,1,0,0,1];
epoch_stim              = [0,0,1,0,0];
pmod_stimXcue           = [0,0,0,1,0];

% NOTE 04 define contrast
contrast_name = {
    'P_VC_epoch_cue', 'V_PC_epoch_cue', 'C_PV_epoch_cue',...
    'P_VC_epoch_stim', 'V_PC_epoch_stim', 'C_PV_epoch_stim',...
    'P_VC_pmod_stimXcue', 'V_PC_pmod_stimXcue', 'C_PV_pmod_stimXcue',...

    'motor',...

    'P_simple_epoch_cue', 'V_simple_epoch_cue', 'C_simple_epoch_cue',...
    'P_simple_epoch_stim', 'V_simple_epoch_stim', 'C_simple_epoch_stim',...
    'P_simple_pmod_stimXcue', 'V_simple_pmod_stimXcue', 'C_simple_pmod_stimXcue',...

};

    
c01 = []; c02 = []; c03 = []; c04 = []; c05 = []; c06 = []; c07 = []; c08 = []; c09 = []; c10 = [];
c11 = []; c12 = []; c13 = []; c14 = []; c15 = []; c16 = []; c17 = []; c18 = []; c19 = []; 


matlabbatch = cell(1,1);
runlength = size(A,1);
numRegressorsPerRun = arrayfun(@(x) length(x.col), SPM.Sess);
runtype_counts = tabulate(A.runtype)

for run_ind = 1: runlength
    disp(strcat('run', num2str(run_ind)));
    sub = strcat('sub-', sprintf('%04d', A.sub_num(run_ind)));
    ses = strcat('ses-', sprintf('%02d', A.ses_num(run_ind)));
    run = strcat('run-', sprintf('%01d', A.run_num(run_ind)));
    task = A.runtype{run_ind};
    % Extract the frequency for the 'cognitive' runtype
    task_idx = strcmp(runtype_counts(:, 1), task);
    task_freq = runtype_counts{task_idx, 2};
    disp('identify covariates');
    covariate = zeros(1, size(SPM.Sess(run_ind).C.name,2));

    disp(strcat('[ STEP 04 ]constructing contrasts...'));
    onset_glob    = dir(fullfile(onset_dir, sub, ses, strcat(sub, '_', ses, '_task-cue_',strcat('run-', sprintf('%02d', A.run_num(run_ind))), '_*_events.tsv')));
    onset_fname   = fullfile(char(onset_glob.folder), char(onset_glob.name));
    if isempty(onset_glob)
      disp('ABORT')
      break
    end
    disp(strcat('onset folder: ', onset_glob.folder));
    disp(strcat('onset file:   ', onset_glob.name));
    social        = struct2table(tdfread(onset_fname));
    keyword       = extractBetween(onset_glob.name, 'run-0', '_events.tsv');
    task          = char(extractAfter(keyword, '-'));

    P_VC_epoch_cue               = [ (m1(task)*epoch_cue)/task_freq, zeros(1, numRegressorsPerRun(run_ind) - size((m1(task)*epoch_cue),2)) ]; 
    V_PC_epoch_cue               = [ (m2(task)*epoch_cue)/task_freq, zeros(1, numRegressorsPerRun(run_ind) - size((m2(task)*epoch_cue),2)) ]; 
    C_PV_epoch_cue               = [ (m3(task)*epoch_cue)/task_freq, zeros(1, numRegressorsPerRun(run_ind) - size((m3(task)*epoch_cue),2)) ]; 
    
    P_VC_epoch_stim              = [ (m1(task)*epoch_stim)/task_freq, zeros(1, numRegressorsPerRun(run_ind) - size((m1(task)*epoch_cue),2)) ]; 
    V_PC_epoch_stim              = [ (m2(task)*epoch_stim)/task_freq, zeros(1, numRegressorsPerRun(run_ind) - size((m2(task)*epoch_cue),2)) ]; 
    C_PV_epoch_stim              = [ (m3(task)*epoch_stim)/task_freq, zeros(1, numRegressorsPerRun(run_ind) - size((m3(task)*epoch_cue),2)) ]; 
    
    P_VC_pmod_stimXcue           = [ (m1(task)*pmod_stimXcue)/task_freq, zeros(1, numRegressorsPerRun(run_ind) - size((m1(task)*pmod_stimXcue),2)) ]; 
    V_PC_pmod_stimXcue           = [ (m2(task)*pmod_stimXcue)/task_freq, zeros(1, numRegressorsPerRun(run_ind) - size((m2(task)*pmod_stimXcue),2)) ]; 
    C_PV_pmod_stimXcue           = [ (m3(task)*pmod_stimXcue)/task_freq, zeros(1, numRegressorsPerRun(run_ind) - size((m3(task)*pmod_stimXcue),2)) ]; 
    
    motor                        = [ epoch_motor,covariate ];
    
    P_simple_epoch_cue               = [ (m5(task)*epoch_cue)/task_freq, zeros(1, numRegressorsPerRun(run_ind) - size((m5(task)*epoch_cue),2)) ];
    V_simple_epoch_cue               = [ (m6(task)*epoch_cue)/task_freq, zeros(1, numRegressorsPerRun(run_ind) - size((m6(task)*epoch_cue),2)) ];
    C_simple_epoch_cue               = [ (m7(task)*epoch_cue)/task_freq, zeros(1, numRegressorsPerRun(run_ind) - size((m7(task)*epoch_cue),2)) ];
    
    P_simple_epoch_stim              = [ (m5(task)*epoch_stim)/task_freq, zeros(1, numRegressorsPerRun(run_ind) - size((m5(task)*epoch_stim),2)) ];
    V_simple_epoch_stim              = [ (m6(task)*epoch_stim)/task_freq, zeros(1, numRegressorsPerRun(run_ind) - size((m6(task)*epoch_stim),2)) ];
    C_simple_epoch_stim              = [ (m7(task)*epoch_stim)/task_freq, zeros(1, numRegressorsPerRun(run_ind) - size((m7(task)*epoch_stim),2)) ];
    
    P_simple_pmod_stimXcue           = [ (m5(task)*pmod_stimXcue)/task_freq, zeros(1, numRegressorsPerRun(run_ind) - size((m5(task)*pmod_stimXcue),2)) ];
    V_simple_pmod_stimXcue           = [ (m6(task)*pmod_stimXcue)/task_freq, zeros(1, numRegressorsPerRun(run_ind) - size((m6(task)*pmod_stimXcue),2)) ];
    C_simple_pmod_stimXcue           = [ (m7(task)*pmod_stimXcue)/task_freq, zeros(1, numRegressorsPerRun(run_ind) - size((m7(task)*pmod_stimXcue),2)) ]; 
    

    c01 = [c01, P_VC_epoch_cue];          c02 = [c02, V_PC_epoch_cue];          c03 = [c03, C_PV_epoch_cue];
    c04 = [c04, P_VC_epoch_stim];         c05 = [c05, V_PC_epoch_stim];         c06 = [c06, C_PV_epoch_stim];
    c07 = [c07, P_VC_pmod_stimXcue];      c08 = [c08, V_PC_pmod_stimXcue];      c09 = [c09, C_PV_pmod_stimXcue];

    c10 = [c10, motor];
    c11 = [c11, P_simple_epoch_cue];          c12 = [c12, V_simple_epoch_cue];          c13 = [c13, C_simple_epoch_cue];
    c14 = [c14, P_simple_epoch_stim];         c15 = [c15, V_simple_epoch_stim];         c16 = [c16, C_simple_epoch_stim];
    c17 = [c17, P_simple_pmod_stimXcue];      c18 = [c18, V_simple_pmod_stimXcue];      c19 = [c19, C_simple_pmod_stimXcue];

    
    disp(strcat('task: ', task));

 end

contrast_vector{1} = c01/norm(c01); contrast_vector{2} = c02/norm(c02);
contrast_vector{3} = c03/norm(c03); contrast_vector{4} = c04/norm(c04);
contrast_vector{5} = c05/norm(c05); contrast_vector{6} = c06/norm(c06);
contrast_vector{7} = c07/norm(c07); contrast_vector{8} = c08/norm(c08);
contrast_vector{9} = c09/norm(c09); contrast_vector{10} = c10/norm(c10);
contrast_vector{11} = c11/norm(c11); contrast_vector{12} = c12/norm(c12);
contrast_vector{13} = c13/norm(c13); contrast_vector{14} = c14/norm(c14);
contrast_vector{15} = c15/norm(c15); contrast_vector{16} = c16/norm(c16);
contrast_vector{17} = c17/norm(c17); contrast_vector{18} = c18/norm(c18);
contrast_vector{19} = c19/norm(c19); 


%% 1. contrast batch _______________________________________________________
for con_num = 1: length(contrast_name)

    matlabbatch{1}.spm.stats.con.spmmat = cellstr( spm_fname );
    matlabbatch{1}.spm.stats.con.consess{con_num}.tcon.name = contrast_name{con_num};
    matlabbatch{1}.spm.stats.con.consess{con_num}.tcon.convec = contrast_vector{con_num};
    matlabbatch{1}.spm.stats.con.consess{con_num}.tcon.sessrep = 'none';

end

matlabbatch{1}.spm.stats.con.delete = 1; % delete previous contrast

con_batch = fullfile(save_dir, sub, 'contrast_estimation.mat' );
save( con_batch  ,'matlabbatch');

% 2. Run ___________________________________________________________________
spm_jobman('run',matlabbatch);
clearvars matlabbatch

end
