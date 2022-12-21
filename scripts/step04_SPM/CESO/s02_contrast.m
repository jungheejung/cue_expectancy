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

% NOTE 02 define directories _______________________________________________________
motion_dir = fullfile(main_dir, 'data', 'fmri', 'fmri02_motion');
onset_dir = fullfile(main_dir, 'data', 'fmri', 'fmri01_onset', 'onset02_SPM');

disp( sub );
output_dir = fullfile(main_dir, 'analysis', 'fmri', 'spm', 'univariate', 'model01_CESO', ...
'1stLevel', sub);
spm_fname = fullfile(output_dir, 'SPM.mat');

% NOTE 03 find intersection of nifti and onset files
% find nifti files
niilist = dir(fullfile(input_dir, sub, '*/smooth-6mm_*task-cue*_bold.nii'));
nT = struct2table(niilist); % convert the struct array to a table
sortedT = sortrows(nT, 'name'); % sort the table by 'DOB'

sortedT.sub_num(:) = str2double(extractBetween(sortedT.name, 'sub-', '_'));
sortedT.ses_num(:) = str2double(extractBetween(sortedT.name, 'ses-', '_'));
sortedT.run_num(:) = str2double(extractBetween(sortedT.name, 'run-', '_'));

nii_col_names = sortedT.Properties.VariableNames;
nii_num_colomn = nii_col_names(endsWith(nii_col_names, '_num'));

% find onset files
onsetlist = dir(fullfile(onset_dir, sub, '*', strcat(sub, '_*_task-cue_*_events.tsv')));
onsetT = struct2table(onsetlist);
sortedonsetT = sortrows(onsetT, 'name');

sortedonsetT.sub_num(:) = str2double(extractBetween(sortedonsetT.name, 'sub-', '_'));
sortedonsetT.ses_num(:) = str2double(extractBetween(sortedonsetT.name, 'ses-', '_'));
sortedonsetT.run_num(:) = str2double(extractBetween(sortedonsetT.name, 'run-', '_'));

onset_col_names = sortedonsetT.Properties.VariableNames;
onset_num_colomn = onset_col_names(endsWith(onset_col_names, '_num'));
disp(nii_num_colomn)
%intersection of nifti and onset files
A = intersect(sortedT(:, nii_num_colomn), sortedonsetT(:, onset_num_colomn));

% NOTE 04 define contrast

contrast_name = {'cue_P', 'cue_V', 'cue_C', 'cue_G',...
    'stim_P', 'stim_V', 'stim_C', 'stim_G',...
    'motor', ...
    'simple_cue_P', 'simple_cue_V', 'simple_cue_C', ...
    'simple_stim_P', 'simple_stim_V', 'simple_stim_C'};

c01 = []; c02 = []; c03 = []; c04 = []; c05 = []; c06 = []; c07 = []; c08 = []; c09 = []; c10 = [];
c11 = []; c12 = []; c13 = []; c14 = []; c15 = []; 

matlabbatch = cell(1,1);

for run_ind = 1: size(A,1)
    disp(strcat('run', num2str(run_ind)));
    sub = strcat('sub-', sprintf('%04d', A.sub_num(run_ind)));
    ses = strcat('ses-', sprintf('%02d', A.ses_num(run_ind)));
    run = strcat('run-', sprintf('%01d', A.run_num(run_ind)));
    disp(strcat('[ STEP 04 ]constructing contrasts...'));
    onset_glob    = dir(fullfile(onset_dir, sub, ses, strcat(sub, '_', ses, '_task-cue_',strcat('run-', sprintf('%02d', A.run_num(run_ind))), '*_events.tsv')));
    onset_fname   = fullfile(char(onset_glob.folder), char(onset_glob.name));
    if isempty(onset_glob)
      disp('ABORT')
      break
    end
    disp(strcat('onset folder: ', onset_glob.folder));
    disp(strcat('onset file:   ', onset_glob.name));
    social        = struct2table(tdfread(onset_fname));
    keyword       = extractBetween(onset_glob.name, 'runtype-', '_events');
    %task          = char(extractAfter(keyword, '-'));
    task          = char(keyword)
    disp(task);

    cue_P         = [ m1(task),0,0,0 ];
    cue_V         = [ m2(task),0,0,0 ];
    cue_C         = [ m3(task),0,0,0 ];
    cue_G         = [ m4(task),0,0,0 ];

    stim_P        = [ 0,0,m1(task),0 ];
    stim_V        = [ 0,0,m2(task),0 ];
    stim_C        = [ 0,0,m3(task),0 ];
    stim_G        = [ 0,0,m4(task),0 ];

    motor         = [ 0,1,0,1 ];

    simple_cue_P         = [ m5(task),0,0,0 ];
    simple_cue_V         = [ m6(task),0,0,0 ];
    simple_cue_C         = [ m7(task),0,0,0 ];

    simple_stim_P        = [ 0,0,m5(task),0 ];
    simple_stim_V        = [ 0,0,m6(task),0 ];
    simple_stim_C        = [ 0,0,m7(task),0 ];

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

con_batch = fullfile(output_dir, 'contrast_estimation.mat' );
save( con_batch  ,'matlabbatch');

% 2. Run ___________________________________________________________________
spm_jobman('run',matlabbatch);
clearvars matlabbatch

end
