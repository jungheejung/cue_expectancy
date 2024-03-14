function s02_contrast_6cond_highlowcue(sub, input_dir, main_dir, save_dir)

    % need to scale the contrasts, other wise, missing runs may lead to greater weigthing and messed up estimation
    % PARAMETERS
    %     - STIM: CUE h x STIM h (onset03_stim)
    %     - STIM: CUE h x STIM m
    %     - STIM: CUE h x STIM l
    %     - STIM: CUE l x STIM h
    %     - STIM: CUE l x STIM m
    %     - STIM: CUE l x STIM l
    %     - CUE:  CUE h (onset01_cue)
    %             CUE l
    %     - EXPECT RATING: onset02_ratingexpect, pmod_expectRT
    %     - OUTCOME RATING: onset04_ratingoutcome, pmod_outcomeRT

    % I also scale the contrasts and filter the bad runs
% NOTE 01 start jobs
disp('...STARTING JOBS');

rootgroup = settings; rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = 'v7.3'

numscans = 56;
disacqs = 0;
disp(strcat('[ STEP 01 ] setting parameters...'));

% contrast mapper _______________________________________________________
keySet = {'pain','vicarious','cognitive'};

con1 = [2 -1 -1];   con2 = [-1 2 -1];   con3 = [-1 -1 2];   con4 = [1 1 1];
con5 = [1 0 0];     con6 = [0 1 0];     con7 = [0 0 1];
m1 = containers.Map(keySet,con1);
m2 = containers.Map(keySet,con2);
m3 = containers.Map(keySet,con3);
m4 = containers.Map(keySet,con4);
m5 = containers.Map(keySet,con5);
m6 = containers.Map(keySet,con6);
m7 = containers.Map(keySet,con7);

STIM_cue_high_gt_low         = [1,1,1,-1,-1,-1,0,0,0,0];
STIM_stimlin_high_gt_low     = [1,0,-1,1,0,-1,0,0,0,0];
STIM_stimquad_med_gt_other   = [-1,2,-1,-1,2,-1,0,0,0,0];
STIM_cue_int_stimlin         = [1,0,-1,-1,0,1,0,0,0,0];
STIM_cue_int_stimquad        = [-1,2,-1,1,-2,1,0,0,0,0];
STIM_highcue_highstim        = [1,0,0,0,0,0,0,0,0,0];
STIM_highcue_medstim         = [0,1,0,0,0,0,0,0,0,0];
STIM_highcue_lowstim         = [0,0,1,0,0,0,0,0,0,0];
STIM_lowcue_highstim         = [0,0,0,1,0,0,0,0,0,0];
STIM_lowcue_medstim          = [0,0,0,0,1,0,0,0,0,0];
STIM_lowcue_lowstim          = [0,0,0,0,0,1,0,0,0,0];
CUE_cue_high_gt_low          = [0,0,0,0,0,0,1,-1,0,0];
motor_con                    = [0,0,0,0,0,0,0,0,1,1];

% NOTE 02 define directories _______________________________________________________
motion_dir = fullfile(main_dir, 'data', 'fmri', 'fmri02_motion');
onset_dir = fullfile(main_dir, 'data', 'fmri', 'fmri01_onset', 'onset02_SPM');

disp( strcat('-----------------------',sub,'----------------------' ));
output_dir = fullfile(main_dir, 'analysis', 'fmri', 'spm', 'univariate', 'model01_6cond_ttl1', ...
'1stLevel', sub);
output_dir = save_dir;
spm_fname = fullfile(output_dir, sub, 'SPM.mat');
load(spm_fname);

paths = cellstr(SPM.xY.P);

% Get unique file paths (without slice numbers)
uniqueFilePaths = unique(cellfun(@(x) x(1:strfind(x, '.nii,')-1), paths, 'UniformOutput', false));

% Extract 'sub', 'ses', and 'run' info
numFiles = length(uniqueFilePaths);
% subInfo = cell(numFiles, 1);
% sesInfo = cell(numFiles, 1);
% runInfo = cell(numFiles, 1);

subInfo = zeros(1, numFiles);  % Pre-allocate a matrix for efficiency
sesInfo = zeros(1, numFiles);   % We will keep these as cells since you didn't specify to change them
runInfo = zeros(1, numFiles);   % Same here

for i = 1:numFiles
    [~, fileName, ~] = fileparts(uniqueFilePaths{i});
    subInfo(i) = str2double(regexp(fileName, '(?<=sub-)\d+', 'match', 'once'));
    sesInfo(i) = str2double(regexp(fileName, '(?<=ses-)\d+', 'match', 'once'));
    runInfo(i) = str2double(regexp(fileName, '(?<=run-)\d+', 'match', 'once'));
end

% TODO: create a table. Aftereward, find the corresponding run-type info
% infoTable = table(subInfo, sesInfo, runInfo);
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

% The resulting table, MergedTable, will contain all columns from both sortedT and sortedonsetT where 
% sub_num, ses_num, and run_num matched. So, it will include the runtype column as well.

% NOTE 04 define contrast

contrast_name = {
    'P_VC_STIM_cue_high_gt_low', 'V_PC_STIM_cue_high_gt_low', 'C_PV_STIM_cue_high_gt_low',...% contratss
    'P_VC_STIM_stimlin_high_gt_low', 'V_PC_STIM_stimlin_high_gt_low', 'C_PV_STIM_stimlin_high_gt_low',...
    'P_VC_STIM_stimquad_med_gt_other', 'V_PC_STIM_stimquad_med_gt_other', 'C_PV_STIM_stimquad_med_gt_other',...
    'P_VC_STIM_cue_int_stimlin','V_PC_STIM_cue_int_stimlin', 'C_PV_STIM_cue_int_stimlin',...
    'P_VC_STIM_cue_int_stimquad','V_PC_STIM_cue_int_stimquad','C_PV_STIM_cue_int_stimquad',...
    'motor',... %motor
    'P_simple_STIM_cue_high_gt_low',      'V_simple_STIM_cue_high_gt_low', 'C_simple_STIM_cue_high_gt_low',... % dummay contrasts
    'P_simple_STIM_stimlin_high_gt_low',  'V_simple_STIM_stimlin_high_gt_low', 'C_simple_STIM_stimlin_high_gt_low',...
    'P_simple_STIM_stimquad_med_gt_other','V_simple_STIM_stimquad_med_gt_other', 'C_simple_STIM_stimquad_med_gt_other',...
    'P_simple_STIM_cue_int_stimlin',      'V_simple_STIM_cue_int_stimlin', 'C_simple_STIM_cue_int_stimlin',...
    'P_simple_STIM_cue_int_stimquad',     'V_simple_STIM_cue_int_stimquad','C_simple_STIM_cue_int_stimquad',...
    'P_simple_STIM_highcue_highstim',     'P_simple_STIM_highcue_medstim', 'P_simple_STIM_highcue_lowstim',... % pain events
    'P_simple_STIM_lowcue_highstim',      'P_simple_STIM_lowcue_medstim', 'P_simple_STIM_lowcue_lowstim',...
    'V_simple_STIM_highcue_highstim',     'V_simple_STIM_highcue_medstim', 'V_simple_STIM_highcue_lowstim',... % vicarious events
    'V_simple_STIM_lowcue_highstim',      'V_simple_STIM_lowcue_medstim', 'V_simple_STIM_lowcue_lowstim',...
    'C_simple_STIM_highcue_highstim',    'C_simple_STIM_highcue_medstim', 'C_simple_STIM_highcue_lowstim',... % cognitive events
    'C_simple_STIM_lowcue_highstim',    'C_simple_STIM_lowcue_medstim', 'C_simple_STIM_lowcue_lowstim',...
    'P_VC_CUE_cue_high_gt_low','V_PC_CUE_cue_high_gt_low','C_PV_CUE_cue_high_gt_low',...% cue epoch contrasts
    'P_simple_CUE_cue_high_gt_low','V_simple_CUE_STIM_cue_high_gt_low','C_simple_CUE_cue_high_gt_low',...% cue epoch dummy

};

c01 = []; c02 = []; c03 = []; c04 = []; c05 = []; c06 = []; c07 = []; c08 = []; c09 = []; c10 = [];
c11 = []; c12 = []; c13 = []; c14 = []; c15 = []; c16 = []; c17 = []; c18 = []; c19 = []; c20 = [];
c21 = []; c22 = []; c23 = []; c24 = []; c25 = []; c26 = []; c27 = []; c28 = []; c29 = []; c30 = [];
c31 = []; c32 = []; c33 = []; c34 = []; c35 = []; c36 = []; c37 = []; c38 = []; c39 = []; c40 = [];
c41 = []; c42 = []; c43 = []; c44 = []; c45 = []; c46 = []; c47 = []; c48 = []; c49 = []; c50 = [];
c51 = []; c52 = []; c53 = []; c54 = []; c55 = [];

matlabbatch = cell(1,1);
runlength = size(A,1);
numRegressorsPerRun = arrayfun(@(x) length(x.col), SPM.Sess);
runtype_counts = tabulate(A.runtype);
for run_ind = 1: runlength
    disp(strcat('run', num2str(run_ind)));
    sub = strcat('sub-', sprintf('%04d', A.sub_num(run_ind)));
    ses = strcat('ses-', sprintf('%02d', A.ses_num(run_ind)));
    run = strcat('run-', sprintf('%01d', A.run_num(run_ind)));
    task = A.runtype{run_ind};
    disp('identify covariates');
        disp(task);


    % Extract the frequency for the 'cognitive' runtype
    task_idx = strcmp(runtype_counts(:, 1), task);
    task_freq = runtype_counts{task_idx, 2};

    % disp(['Frequency of cognitive: ', num2str(cognitive_frequency)]);

    P_VC_STIM_cue_high_gt_low         = [ (m1(task)*STIM_cue_high_gt_low), zeros(1, numRegressorsPerRun(run_ind) - size((m1(task)*STIM_cue_high_gt_low),2)) ]; % c01
    V_PC_STIM_cue_high_gt_low         = [ (m2(task)*STIM_cue_high_gt_low), zeros(1, numRegressorsPerRun(run_ind) - size((m2(task)*STIM_cue_high_gt_low),2)) ]; % c02
    C_PV_STIM_cue_high_gt_low         = [ (m3(task)*STIM_cue_high_gt_low), zeros(1, numRegressorsPerRun(run_ind) - size((m3(task)*STIM_cue_high_gt_low),2)) ]; % c03

    P_VC_STIM_stimlin_high_gt_low     = [ (m1(task)*STIM_stimlin_high_gt_low), zeros(1, numRegressorsPerRun(run_ind) - size((m1(task)*STIM_stimlin_high_gt_low),2)) ]; % c04
    V_PC_STIM_stimlin_high_gt_low     = [ (m2(task)*STIM_stimlin_high_gt_low), zeros(1, numRegressorsPerRun(run_ind) - size((m2(task)*STIM_stimlin_high_gt_low),2)) ]; % c05
    C_PV_STIM_stimlin_high_gt_low     = [ (m3(task)*STIM_stimlin_high_gt_low), zeros(1, numRegressorsPerRun(run_ind) - size((m3(task)*STIM_stimlin_high_gt_low),2)) ]; % c06

    P_VC_STIM_stimquad_med_gt_other   = [ (m1(task)*STIM_stimquad_med_gt_other), zeros(1, numRegressorsPerRun(run_ind) - size((m1(task)*STIM_stimquad_med_gt_other),2)) ]; % c07
    V_PC_STIM_stimquad_med_gt_other   = [ (m2(task)*STIM_stimquad_med_gt_other), zeros(1, numRegressorsPerRun(run_ind) - size((m2(task)*STIM_stimquad_med_gt_other),2)) ]; % c08
    C_PV_STIM_stimquad_med_gt_other   = [ (m3(task)*STIM_stimquad_med_gt_other), zeros(1, numRegressorsPerRun(run_ind) - size((m3(task)*STIM_stimquad_med_gt_other),2)) ]; % c09

    P_VC_STIM_cue_int_stimlin         = [ (m1(task)*STIM_cue_int_stimlin), zeros(1, numRegressorsPerRun(run_ind) - size((m1(task)*STIM_cue_int_stimlin),2)) ]; % c10
    V_PC_STIM_cue_int_stimlin         = [ (m2(task)*STIM_cue_int_stimlin), zeros(1, numRegressorsPerRun(run_ind) - size((m2(task)*STIM_cue_int_stimlin),2)) ]; % c11
    C_PV_STIM_cue_int_stimlin         = [ (m3(task)*STIM_cue_int_stimlin), zeros(1, numRegressorsPerRun(run_ind) - size((m3(task)*STIM_cue_int_stimlin),2)) ]; % c12

    P_VC_STIM_cue_int_stimquad        = [ (m1(task)*STIM_cue_int_stimquad), zeros(1, numRegressorsPerRun(run_ind) - size((m1(task)*STIM_cue_int_stimquad),2)) ]; % c13
    V_PC_STIM_cue_int_stimquad        = [ (m2(task)*STIM_cue_int_stimquad), zeros(1, numRegressorsPerRun(run_ind) - size((m2(task)*STIM_cue_int_stimquad),2)) ]; % c14
    C_PV_STIM_cue_int_stimquad        = [ (m3(task)*STIM_cue_int_stimquad), zeros(1, numRegressorsPerRun(run_ind) - size((m3(task)*STIM_cue_int_stimquad),2)) ]; % c15

    motor                             = [ 0,0,0,0,0,0,0,0,1,1, zeros(1, numRegressorsPerRun(run_ind) - size(motor_con,2) ) ];  % c16

    P_simple_STIM_cue_high_gt_low         = [ (m5(task)*STIM_cue_high_gt_low), zeros(1, numRegressorsPerRun(run_ind) - size((m5(task)*STIM_cue_high_gt_low),2)) ]; % c17
    V_simple_STIM_cue_high_gt_low         = [ (m6(task)*STIM_cue_high_gt_low), zeros(1, numRegressorsPerRun(run_ind) - size((m6(task)*STIM_cue_high_gt_low),2)) ]; % c18
    C_simple_STIM_cue_high_gt_low         = [ (m7(task)*STIM_cue_high_gt_low), zeros(1, numRegressorsPerRun(run_ind) - size((m7(task)*STIM_cue_high_gt_low),2)) ]; % c19

    P_simple_STIM_stimlin_high_gt_low     = [ (m5(task)*STIM_stimlin_high_gt_low), zeros(1, numRegressorsPerRun(run_ind) - size((m5(task)*STIM_stimlin_high_gt_low),2)) ]; % c20
    V_simple_STIM_stimlin_high_gt_low     = [ (m6(task)*STIM_stimlin_high_gt_low), zeros(1, numRegressorsPerRun(run_ind) - size((m6(task)*STIM_stimlin_high_gt_low),2)) ]; % c21
    C_simple_STIM_stimlin_high_gt_low     = [ (m7(task)*STIM_stimlin_high_gt_low), zeros(1, numRegressorsPerRun(run_ind) - size((m7(task)*STIM_stimlin_high_gt_low),2)) ]; % c22

    P_simple_STIM_stimquad_med_gt_other   = [ (m5(task)*STIM_stimquad_med_gt_other), zeros(1, numRegressorsPerRun(run_ind) - size((m5(task)*STIM_stimquad_med_gt_other),2))  ]; % c23
    V_simple_STIM_stimquad_med_gt_other   = [ (m6(task)*STIM_stimquad_med_gt_other), zeros(1, numRegressorsPerRun(run_ind) - size((m6(task)*STIM_stimquad_med_gt_other),2))  ]; % c24
    C_simple_STIM_stimquad_med_gt_other   = [ (m7(task)*STIM_stimquad_med_gt_other), zeros(1, numRegressorsPerRun(run_ind) - size((m7(task)*STIM_stimquad_med_gt_other),2))  ]; % c25

    P_simple_STIM_cue_int_stimlin         = [ (m5(task)*STIM_cue_int_stimlin), zeros(1, numRegressorsPerRun(run_ind) - size((m5(task)*STIM_cue_int_stimlin),2)) ]; % c26
    V_simple_STIM_cue_int_stimlin         = [ (m6(task)*STIM_cue_int_stimlin), zeros(1, numRegressorsPerRun(run_ind) - size((m6(task)*STIM_cue_int_stimlin),2)) ]; % c27
    C_simple_STIM_cue_int_stimlin         = [ (m7(task)*STIM_cue_int_stimlin), zeros(1, numRegressorsPerRun(run_ind) - size((m7(task)*STIM_cue_int_stimlin),2)) ]; % c28

    P_simple_STIM_cue_int_stimquad        = [ (m5(task)*STIM_cue_int_stimquad), zeros(1, numRegressorsPerRun(run_ind) - size((m5(task)*STIM_cue_int_stimquad),2))  ]; % c29
    V_simple_STIM_cue_int_stimquad        = [ (m6(task)*STIM_cue_int_stimquad), zeros(1, numRegressorsPerRun(run_ind) - size((m6(task)*STIM_cue_int_stimquad),2))  ]; % c30
    C_simple_STIM_cue_int_stimquad        = [ (m7(task)*STIM_cue_int_stimquad), zeros(1, numRegressorsPerRun(run_ind) - size((m7(task)*STIM_cue_int_stimquad),2))  ]; % c31

    P_simple_STIM_highcue_highstim        = [ (m5(task)*STIM_highcue_highstim), zeros(1, numRegressorsPerRun(run_ind) - size((m5(task)*STIM_highcue_highstim),2))  ];  % c32
    P_simple_STIM_highcue_medstim         = [ (m5(task)*STIM_highcue_medstim),  zeros(1, numRegressorsPerRun(run_ind) - size((m5(task)*STIM_highcue_medstim),2))  ];  % c33
    P_simple_STIM_highcue_lowstim         = [ (m5(task)*STIM_highcue_lowstim),  zeros(1, numRegressorsPerRun(run_ind) - size((m5(task)*STIM_highcue_lowstim),2))  ];  % c34
    P_simple_STIM_lowcue_highstim         = [ (m5(task)*STIM_lowcue_highstim),  zeros(1, numRegressorsPerRun(run_ind) - size((m5(task)*STIM_lowcue_highstim),2))  ];  % c35
    P_simple_STIM_lowcue_medstim          = [ (m5(task)*STIM_lowcue_medstim),   zeros(1, numRegressorsPerRun(run_ind) - size((m5(task)*STIM_lowcue_medstim),2))  ];  % c36
    P_simple_STIM_lowcue_lowstim          = [ (m5(task)*STIM_lowcue_lowstim),   zeros(1, numRegressorsPerRun(run_ind) - size((m5(task)*STIM_lowcue_lowstim),2))  ];  % c37

    V_simple_STIM_highcue_highstim        = [ (m6(task)*STIM_highcue_highstim), zeros(1, numRegressorsPerRun(run_ind) - size((m6(task)*STIM_highcue_highstim),2)) ];  % c38
    V_simple_STIM_highcue_medstim         = [ (m6(task)*STIM_highcue_medstim),  zeros(1, numRegressorsPerRun(run_ind) - size((m6(task)*STIM_highcue_medstim),2)) ];  % c39
    V_simple_STIM_highcue_lowstim         = [ (m6(task)*STIM_highcue_lowstim),  zeros(1, numRegressorsPerRun(run_ind) - size((m6(task)*STIM_highcue_lowstim),2)) ];  % c40
    V_simple_STIM_lowcue_highstim         = [ (m6(task)*STIM_lowcue_highstim),  zeros(1, numRegressorsPerRun(run_ind) - size((m6(task)*STIM_lowcue_highstim),2)) ];  % c41
    V_simple_STIM_lowcue_medstim          = [ (m6(task)*STIM_lowcue_medstim),   zeros(1, numRegressorsPerRun(run_ind) - size((m6(task)*STIM_lowcue_medstim),2)) ];  % c42
    V_simple_STIM_lowcue_lowstim          = [ (m6(task)*STIM_lowcue_lowstim),   zeros(1, numRegressorsPerRun(run_ind) - size((m6(task)*STIM_lowcue_lowstim),2)) ];  % c43

    C_simple_STIM_highcue_highstim        = [ (m7(task)*STIM_highcue_highstim), zeros(1, numRegressorsPerRun(run_ind) - size((m7(task)*STIM_highcue_highstim),2)) ];  % c44
    C_simple_STIM_highcue_medstim         = [ (m7(task)*STIM_highcue_medstim),  zeros(1, numRegressorsPerRun(run_ind) - size((m7(task)*STIM_highcue_medstim),2)) ];  % c45
    C_simple_STIM_highcue_lowstim         = [ (m7(task)*STIM_highcue_lowstim),  zeros(1, numRegressorsPerRun(run_ind) - size((m7(task)*STIM_highcue_lowstim),2)) ];  % c46
    C_simple_STIM_lowcue_highstim         = [ (m7(task)*STIM_lowcue_highstim),  zeros(1, numRegressorsPerRun(run_ind) - size((m7(task)*STIM_lowcue_highstim),2)) ];  % c47
    C_simple_STIM_lowcue_medstim          = [ (m7(task)*STIM_lowcue_medstim),   zeros(1, numRegressorsPerRun(run_ind) - size((m7(task)*STIM_lowcue_medstim),2)) ];  % c48
    C_simple_STIM_lowcue_lowstim          = [ (m7(task)*STIM_lowcue_lowstim),   zeros(1, numRegressorsPerRun(run_ind) - size((m7(task)*STIM_lowcue_lowstim),2)) ];  % c49


    % cue epoch contrasts
    P_VC_CUE_cue_high_gt_low         = [ (m1(task)*CUE_cue_high_gt_low),   zeros(1, numRegressorsPerRun(run_ind) - size((m1(task)*CUE_cue_high_gt_low),2)) ]; % c50
    V_PC_CUE_cue_high_gt_low         = [ (m2(task)*CUE_cue_high_gt_low),   zeros(1, numRegressorsPerRun(run_ind) - size((m2(task)*CUE_cue_high_gt_low),2)) ]; % c51
    C_PV_CUE_cue_high_gt_low         = [ (m3(task)*CUE_cue_high_gt_low),   zeros(1, numRegressorsPerRun(run_ind) - size((m3(task)*CUE_cue_high_gt_low),2)) ]; % c52
    P_simple_CUE_cue_high_gt_low     = [ (m5(task)*CUE_cue_high_gt_low),   zeros(1, numRegressorsPerRun(run_ind) - size((m5(task)*CUE_cue_high_gt_low),2)) ]; % c53
    V_simple_CUE_cue_high_gt_low     = [ (m6(task)*CUE_cue_high_gt_low),   zeros(1, numRegressorsPerRun(run_ind) - size((m6(task)*CUE_cue_high_gt_low),2)) ]; % c54
    C_simple_CUE_cue_high_gt_low     = [ (m7(task)*CUE_cue_high_gt_low),   zeros(1, numRegressorsPerRun(run_ind) - size((m7(task)*CUE_cue_high_gt_low),2)) ]; % c55


    c01 = [ c01  P_VC_STIM_cue_high_gt_low];         c02 = [ c02  V_PC_STIM_cue_high_gt_low];         c03 = [ c03  C_PV_STIM_cue_high_gt_low];
    c04 = [ c04  P_VC_STIM_stimlin_high_gt_low];     c05 = [ c05  V_PC_STIM_stimlin_high_gt_low];     c06 = [ c06  C_PV_STIM_stimlin_high_gt_low];   
    c07 = [ c07  P_VC_STIM_stimquad_med_gt_other];   c08 = [ c08  V_PC_STIM_stimquad_med_gt_other];   c09 = [ c09  C_PV_STIM_stimquad_med_gt_other]; 
    c10 = [ c10  P_VC_STIM_cue_int_stimlin];         c11 = [ c11  V_PC_STIM_cue_int_stimlin];         c12 = [ c12  C_PV_STIM_cue_int_stimlin];   
    c13 = [ c13  P_VC_STIM_cue_int_stimquad];        c14 = [ c14  V_PC_STIM_cue_int_stimquad];        c15 = [ c15  C_PV_STIM_cue_int_stimquad];    
    c16 = [ c16  motor];
    c17 = [ c17  P_simple_STIM_cue_high_gt_low];         c18 = [ c18  V_simple_STIM_cue_high_gt_low];         c19 = [ c19  C_simple_STIM_cue_high_gt_low];
    c20 = [ c20  P_simple_STIM_stimlin_high_gt_low];     c21 = [ c21  V_simple_STIM_stimlin_high_gt_low];     c22 = [ c22  C_simple_STIM_stimlin_high_gt_low];   
    c23 = [ c23  P_simple_STIM_stimquad_med_gt_other];   c24 = [ c24  V_simple_STIM_stimquad_med_gt_other];   c25 = [ c25  C_simple_STIM_stimquad_med_gt_other]; 
    c26 = [ c26  P_simple_STIM_cue_int_stimlin];         c27 = [ c27  V_simple_STIM_cue_int_stimlin];         c28 = [ c28  C_simple_STIM_cue_int_stimlin];   
    c29 = [ c29  P_simple_STIM_cue_int_stimquad];        c30 = [ c30  V_simple_STIM_cue_int_stimquad];        c31 = [ c31  C_simple_STIM_cue_int_stimquad];    

    c32 = [ c32  P_simple_STIM_highcue_highstim];        c33 = [ c33  P_simple_STIM_highcue_medstim];        c34 = [ c34  P_simple_STIM_highcue_lowstim];
    c35 = [ c35  P_simple_STIM_lowcue_highstim];         c36 = [ c36  P_simple_STIM_lowcue_medstim];         c37 = [ c37  P_simple_STIM_lowcue_lowstim];
    c38 = [ c38  V_simple_STIM_highcue_highstim];        c39 = [ c39  V_simple_STIM_highcue_medstim];        c40 = [ c40  V_simple_STIM_highcue_lowstim];
    c41 = [ c41  V_simple_STIM_lowcue_highstim];         c42 = [ c42  V_simple_STIM_lowcue_medstim];         c43 = [ c43  V_simple_STIM_lowcue_lowstim];
    c44 = [ c44  C_simple_STIM_highcue_highstim];        c45 = [ c45  C_simple_STIM_highcue_medstim];        c46 = [ c46  C_simple_STIM_highcue_lowstim];
    c47 = [ c47  C_simple_STIM_lowcue_highstim];         c48 = [ c48  C_simple_STIM_lowcue_medstim];         c49 = [ c49  C_simple_STIM_lowcue_lowstim];

    c50 = [ c50  P_VC_CUE_cue_high_gt_low];         c51 = [ c51  V_PC_CUE_cue_high_gt_low];        c52 = [ c52  C_PV_CUE_cue_high_gt_low];
    c53 = [ c53  P_simple_CUE_cue_high_gt_low];     c54 = [ c54  V_simple_CUE_cue_high_gt_low];    c55 = [ c55  C_simple_CUE_cue_high_gt_low];

    disp(strcat('task: ', task));

 end

 contrast_vector{1} = c01/norm(c01);
 contrast_vector{2} = c02/norm(c02);
 contrast_vector{3} = c03/norm(c03);
 contrast_vector{4} = c04/norm(c04);
 contrast_vector{5} = c05/norm(c05);
 contrast_vector{6} = c06/norm(c06);
 contrast_vector{7} = c07/norm(c07);
 contrast_vector{8} = c08/norm(c08);
 contrast_vector{9} = c09/norm(c09);
 contrast_vector{10} = c10/norm(c10);
 contrast_vector{11} = c11/norm(c11);
 contrast_vector{12} = c12/norm(c12);
 contrast_vector{13} = c13/norm(c13);
 contrast_vector{14} = c14/norm(c14);
 contrast_vector{15} = c15/norm(c15);
 contrast_vector{16} = c16/norm(c16);
 contrast_vector{17} = c17/norm(c17);
 contrast_vector{18} = c18/norm(c18);
 contrast_vector{19} = c19/norm(c19);
 contrast_vector{20} = c20/norm(c20);
 contrast_vector{21} = c21/norm(c21);
 contrast_vector{22} = c22/norm(c22);
 contrast_vector{23} = c23/norm(c23);
 contrast_vector{24} = c24/norm(c24);
 contrast_vector{25} = c25/norm(c25);
 contrast_vector{26} = c26/norm(c26);
 contrast_vector{27} = c27/norm(c27);
 contrast_vector{28} = c28/norm(c28);
 contrast_vector{29} = c29/norm(c29);
 contrast_vector{30} = c30/norm(c30);
 contrast_vector{31} = c31/norm(c31);
 contrast_vector{32} = c32/norm(c32);
 contrast_vector{33} = c33/norm(c33);
 contrast_vector{34} = c34/norm(c34);
 contrast_vector{35} = c35/norm(c35);
 contrast_vector{36} = c36/norm(c36);
 contrast_vector{37} = c37/norm(c37);
 contrast_vector{38} = c38/norm(c38);
 contrast_vector{39} = c39/norm(c39);
 contrast_vector{40} = c40/norm(c40);
 contrast_vector{41} = c41/norm(c41);
 contrast_vector{42} = c42/norm(c42);
 contrast_vector{43} = c43/norm(c43);
 contrast_vector{44} = c44/norm(c44);
 contrast_vector{45} = c45/norm(c45);
 contrast_vector{46} = c46/norm(c46);
 contrast_vector{47} = c47/norm(c47);
 contrast_vector{48} = c48/norm(c48);
 contrast_vector{49} = c49/norm(c49);
 contrast_vector{50} = c50/norm(c50);
 contrast_vector{51} = c51/norm(c51);
 contrast_vector{52} = c52/norm(c52);
 contrast_vector{53} = c53/norm(c53);
 contrast_vector{54} = c54/norm(c54);
 contrast_vector{55} = c55/norm(c55);


%  checkOrthogonality(contrast_vector)
%% 1. contrast batch _______________________________________________________
for con_num = 1: length(contrast_name)

    matlabbatch{1}.spm.stats.con.spmmat = cellstr( spm_fname );
    matlabbatch{1}.spm.stats.con.consess{con_num}.tcon.name = contrast_name{con_num};
    matlabbatch{1}.spm.stats.con.consess{con_num}.tcon.convec = contrast_vector{con_num};
    matlabbatch{1}.spm.stats.con.consess{con_num}.tcon.sessrep = 'none';

end

matlabbatch{1}.spm.stats.con.delete = 1; % delete previous contrast

con_batch = fullfile(output_dir, 'contrast_estimation.mat' );
save( con_batch  ,'matlabbatch');

% 2. Run ___________________________________________________________________
spm_jobman('run',matlabbatch);
clearvars matlabbatch

end


function areOrthogonal = checkOrthogonality(vectors)
    % Get the number of vectors
    numVectors = size(vectors, 2);
    
    % Check the dot product of each pair of vectors
    for i = 1:numVectors
        for j = i+1:numVectors
            if dot(vectors(:,i), vectors(:,j)) ~= 0
                areOrthogonal = false;
                return;
            end
        end
    end
    
    areOrthogonal = true;
end
