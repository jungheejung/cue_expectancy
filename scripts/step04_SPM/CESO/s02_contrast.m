function s02_contrast(sub, input_dir, main_dir)

% NOTE 01 start jobs
disp('...STARTING JOBS');

rootgroup = settings; rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = 'v7.3'

numscans = 56;
disacqs = 0;
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

cue_con  = [1,0,0,0];
stim_con = [0,0,1,0];
motor    = [0,1,0,1];
% NOTE 02 define directories _______________________________________________________
% motion_dir = fullfile(main_dir, 'data', 'fmri', 'fmri02_motion');
onset_dir = fullfile(main_dir, 'data', 'fmri', 'fmri01_onset', 'onset02_SPM');

disp( sub );
% output_dir = fullfile(main_dir, 'analysis', 'fmri', 'spm', 'univariate', 'model01_CESO', ...
% '1stLevel', sub);
% output_dir = fullfile(input_dir, sub);
spm_fname = fullfile(input_dir, sub, 'SPM.mat');
load(spm_fname);

paths = cellstr(SPM.xY.P);

% NOTE 03 find intersection of nifti and onset files
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

sortedT = table(subInfo', sesInfo', runInfo', 'VariableNames', {'sub_num', 'ses_num', 'run_num'});
% find onset files
onsetlist = dir(fullfile(onset_dir, sub, '*', strcat(sub, '_*_task-cue_*_events.tsv')));
onsetT = struct2table(onsetlist);
sortedonsetT = sortrows(onsetT, 'name');
sortedonsetT.sub_num(:) = str2double(extractBetween(sortedonsetT.name, 'sub-', '_'));
sortedonsetT.ses_num(:) = str2double(extractBetween(sortedonsetT.name, 'ses-', '_'));
sortedonsetT.run_num(:) = str2double(extractBetween(sortedonsetT.name, 'run-', '_'));
sortedonsetT.runtype(:) = extractBetween(sortedonsetT.name, 'runtype-', '_events.tsv');

%intersection of nifti and onset files
A = innerjoin(sortedT, sortedonsetT, 'Keys', {'sub_num', 'ses_num', 'run_num'});

% NOTE 04 define contrast

contrast_name = {'cue_P', 'cue_V', 'cue_C', 'cue_G',...
    'stim_P', 'stim_V', 'stim_C', 'stim_G',...
    'motor', ...
    'simple_cue_P', 'simple_cue_V', 'simple_cue_C', ...
    'simple_stim_P', 'simple_stim_V', 'simple_stim_C'};

c01 = []; c02 = []; c03 = []; c04 = []; c05 = []; c06 = []; c07 = []; c08 = []; c09 = []; c10 = [];
c11 = []; c12 = []; c13 = []; c14 = []; c15 = []; 

matlabbatch = cell(1,1);
runlength = size(A,1);
numRegressorsPerRun = arrayfun(@(x) length(x.col), SPM.Sess);
runtype_counts = tabulate(A.runtype);
for run_ind = 1: runlength
% for run_ind = 1: size(A,1)
   
    sub = strcat('sub-', sprintf('%04d', A.sub_num(run_ind)));
    ses = strcat('ses-', sprintf('%02d', A.ses_num(run_ind)));
    run = strcat('run-', sprintf('%01d', A.run_num(run_ind)));
    task = A.runtype{run_ind};
    disp(strcat('run-', num2str(run_ind), '  task-', task));

    task_idx = strcmp(runtype_counts(:, 1), task);
    task_freq = runtype_counts{task_idx, 2};

    cue_P         = [ m1(task)*cue_con/task_freq, zeros(1, numRegressorsPerRun(run_ind) - size((m1(task)*cue_con),2)) ];
    cue_V         = [ m2(task)*cue_con/task_freq, zeros(1, numRegressorsPerRun(run_ind) - size((m2(task)*cue_con),2)) ];
    cue_C         = [ m3(task)*cue_con/task_freq, zeros(1, numRegressorsPerRun(run_ind) - size((m3(task)*cue_con),2)) ];
    cue_G         = [ m4(task)*cue_con/task_freq, zeros(1, numRegressorsPerRun(run_ind) - size((m4(task)*cue_con),2)) ];

    stim_P        = [ m1(task)*stim_con/task_freq, zeros(1, numRegressorsPerRun(run_ind) - size((m1(task)*stim_con),2)) ];
    stim_V        = [ m2(task)*stim_con/task_freq, zeros(1, numRegressorsPerRun(run_ind) - size((m2(task)*stim_con),2)) ];
    stim_C        = [ m3(task)*stim_con/task_freq, zeros(1, numRegressorsPerRun(run_ind) - size((m3(task)*stim_con),2)) ];
    stim_G        = [ m4(task)*stim_con/task_freq, zeros(1, numRegressorsPerRun(run_ind) - size((m4(task)*stim_con),2)) ];
    
    motor        = [ motor, zeros(1, numRegressorsPerRun(run_ind) - size((motor),2)) ];

    simple_cue_P         = [ m5(task)*cue_con/task_freq, zeros(1, numRegressorsPerRun(run_ind) - size((m5(task)*cue_con),2)) ];
    simple_cue_V         = [ m6(task)*cue_con/task_freq, zeros(1, numRegressorsPerRun(run_ind) - size((m6(task)*cue_con),2)) ];
    simple_cue_C         = [ m7(task)*cue_con/task_freq, zeros(1, numRegressorsPerRun(run_ind) - size((m7(task)*cue_con),2)) ];

    simple_stim_P        = [ m5(task)*stim_con/task_freq, zeros(1, numRegressorsPerRun(run_ind) - size((m5(task)*stim_con),2)) ];
    simple_stim_V        = [ m6(task)*stim_con/task_freq, zeros(1, numRegressorsPerRun(run_ind) - size((m6(task)*stim_con),2)) ];
    simple_stim_C        = [ m7(task)*stim_con/task_freq, zeros(1, numRegressorsPerRun(run_ind) - size((m7(task)*stim_con),2)) ];

    c01 = [ c01  cue_P];          c02 = [ c02  cue_V];          c03 = [ c03  cue_C];          c04 = [ c04  cue_G];
    c05 = [ c05  stim_P];         c06 = [ c06  stim_V];         c07 = [ c07  stim_C];         c08 = [ c08  stim_G];
    c09 = [ c09  motor];
    c10 = [ c10  simple_cue_P];          c11 = [ c11  simple_cue_V];         c12 = [ c12  simple_cue_C];
    c13 = [ c13  simple_stim_P];         c14 = [ c14  simple_stim_V];        c15 = [ c15  simple_stim_C];
    disp(strcat('task: ', task));

 end

contrast_vector{1} = c01; contrast_vector{2} = c02;
contrast_vector{3} = c03; contrast_vector{4} = c04;
contrast_vector{5} = c05; contrast_vector{6} = c06;
contrast_vector{7} = c07; contrast_vector{8} = c08;
contrast_vector{9} = c09; contrast_vector{10} = c10;
contrast_vector{11} = c11; contrast_vector{12} = c12;
contrast_vector{13} = c13; contrast_vector{14} = c14;
contrast_vector{15} = c15; 


%% 1. contrast batch _______________________________________________________
for con_num = 1: length(contrast_name)

    matlabbatch{1}.spm.stats.con.spmmat = cellstr( spm_fname );
    matlabbatch{1}.spm.stats.con.consess{con_num}.tcon.name = contrast_name{con_num};
    matlabbatch{1}.spm.stats.con.consess{con_num}.tcon.convec = contrast_vector{con_num};
    matlabbatch{1}.spm.stats.con.consess{con_num}.tcon.sessrep = 'none';

end

matlabbatch{1}.spm.stats.con.delete = 1; % delete previous contrast

con_batch = fullfile(input_dir, sub, 'contrast_estimation.mat' );
save( con_batch  ,'matlabbatch');

% 2. Run ___________________________________________________________________
spm_jobman('run',matlabbatch);
clearvars matlabbatch

end
