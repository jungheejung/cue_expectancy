function s02_contrast(input)

% NOTE 01 start jobs
disp('...STARTING JOBS');

rootgroup = settings; rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = 'v7.3'


numscans = 56;
disacqs = 0;
disp(input);
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
fmriprep_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/fmriprep';
main_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social';
smooth_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/smooth_6mm';
motion_dir = fullfile(main_dir, 'data', 'd04_motion');
onset_dir = fullfile(main_dir, 'data', 'd03_onset', 'onset02_SPM');


% sub_num = sscanf(char(input),'%d');
% sub = strcat('sub-', sprintf('%04d', sub_num));
sub = strcat('sub-', sprintf('%04d', input));
disp( sub );
fmri_dir = fullfile(main_dir,'analysis', 'fmri', 'spm', 'univariate', 'model-03_CEScsA_24dofcsd',...
    '1stLevel', sub); % first level spm mat.
spm_fname = fullfile(fmri_dir, 'SPM.mat');


% find nifti files
niilist = dir(fullfile(smooth_dir, sub, '*/func/*task-social*_bold.nii'));
nT = struct2table(niilist); % convert the struct array to a table
sortedT = sortrows(nT, 'name'); % sort the table by 'DOB'

sortedT.sub_num(:) = str2double(extractBetween(sortedT.name, 'sub-', '_'));
sortedT.ses_num(:) = str2double(extractBetween(sortedT.name, 'ses-', '_'));
sortedT.run_num(:) = str2double(extractBetween(sortedT.name, 'run-', '_'));

nii_col_names = sortedT.Properties.VariableNames;
nii_num_colomn = nii_col_names(endsWith(nii_col_names, '_num'));

% find onset files
%%%%%%% TODO: if pain run, check if * sub-0055_*_task-social_*_events_ttl.tsv  exists
% else if, look for _events.tsv

onsetlist = dir(fullfile(onset_dir, sub, '*', strcat(sub, '_*_task-social_*_events.tsv')));
onsetT = struct2table(onsetlist);
sortedonsetT = sortrows(onsetT, 'name');

sortedonsetT.sub_num(:) = str2double(extractBetween(sortedonsetT.name, 'sub-', '_'));
sortedonsetT.ses_num(:) = str2double(extractBetween(sortedonsetT.name, 'ses-', '_'));
sortedonsetT.run_num(:) = str2double(extractBetween(sortedonsetT.name, 'run-', '-'));

onset_col_names = sortedonsetT.Properties.VariableNames;
onset_num_colomn = onset_col_names(endsWith(onset_col_names, '_num'));

%intersection of nifti and onset files
A = intersect(sortedT(:,nii_num_colomn),sortedonsetT(:,onset_num_colomn));
disp(A);
% NOTE 04 define contrast

contrast_name = {'cue_P', 'cue_V', 'cue_C',...
    'stim_P', 'stim_V', 'stim_C',...
    'stimXcue_P', 'stimXcue_V', 'stimXcue_C',...
    'stimXint_P', 'stimXint_V', 'stimXint_C',...
    'motor', ...
    'simple_cue_P', 'simple_cue_V', 'simple_cue_C','simple_cue_G',...
    'simple_stim_P', 'simple_stim_V', 'simple_stim_C','simple_stim_G',...
    'simple_stimXcue_P', 'simple_stimXcue_V', 'simple_stimXcue_C','simple_stimXcue_G',...
    'simple_stimXint_P', 'simple_stimXint_V','simple_stimXint_C', 'simple_stimXint_G'};


c01 = []; c02 = []; c03 = []; c04 = []; c05 = []; c06 = []; c07 = []; c08 = []; c09 = []; c10 = []; 
c11 = []; c12 = []; c13 = []; c14 = []; c15 = []; c16 = []; c17 = []; c18 = []; c19 = []; c20 = []; 
c21 = []; c22 = []; c23 = []; c24 = []; c25 = []; c26 = []; c27 = []; c28 = []; c29 = []; c30 = [];
c31 = []; c32 = []; c33 = []; c34 = []; c35 = []; c36 = [];
n_cov = [];
matlabbatch = cell(1,1);

for run_ind = 1: size(A,1)
    disp(strcat('run', num2str(run_ind)));
    sub = strcat('sub-', sprintf('%04d', A.sub_num(run_ind)));
    ses = strcat('ses-', sprintf('%02d', A.ses_num(run_ind)));
    run = strcat('run-', sprintf('%01d', A.run_num(run_ind)));
    run2d = strcat('run-', sprintf('%02d', A.run_num(run_ind)));
    motion_fname = fullfile(motion_dir, '24dof_csf_spike_dummy', sub, ses, strcat(sub, '_', ses, '_task-social_', run2d, '_confounds-subset.txt'));
    mdf = dlmread(motion_fname);
    n_cov = [];
    n_cov = zeros(1, size(mdf,2));
    disp(strcat('[ STEP 04 ]constructing contrasts...'));
    onset_glob    = dir(fullfile(onset_dir, sub, ses, strcat(sub, '_', ses, '_task-social_',strcat('run-', sprintf('%02d', A.run_num(run_ind))), '-*_events.tsv')));
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

    cue_P         = [ m1(task),0,0,0,0,0  ]; % 01
    cue_V         = [ m2(task),0,0,0,0,0  ]; % 02
    cue_C         = [ m3(task),0,0,0,0,0  ]; % 03
    
    stim_P        = [ 0,0,m1(task),0,0,0  ]; % 04
    stim_V        = [ 0,0,m2(task),0,0,0  ]; % 05
    stim_C        = [,0,0,m3(task),0,0,0  ]; % 06

    stimXcue_P    = [ 0,0,0,m1(task),0,0  ]; % 07
    stimXcue_V    = [ 0,0,0,m2(task),0,0  ]; % 08
    stimXcue_C    = [ 0,0,0,m3(task),0,0  ]; % 09
 
    stimXint_P    = [ 0,0,0,0,m1(task),0  ]; % 10
    stimXint_V    = [ 0,0,0,0,m2(task),0  ]; % 11
    stimXint_C    = [ 0,0,0,0,m3(task),0  ]; % 12

    motor         = [ 0,1,0,0,0,1    ];  % 13

    simple_cue_P         = [ m5(task),0,0,0,0,0  ]; % 14
    simple_cue_V         = [ m6(task),0,0,0,0,0  ]; % 15
    simple_cue_C         = [ m7(task),0,0,0,0,0  ]; % 16
    simple_cue_G         = [ m4(task),0,0,0,0,0  ]; % 17

    simple_stim_P        = [ 0,0,m5(task),0,0,0  ]; % 18
    simple_stim_V        = [ 0,0,m6(task),0,0,0  ]; % 19
    simple_stim_C        = [ 0,0,m7(task),0,0,0  ]; % 20
    simple_stim_G        = [ 0,0,m4(task),0,0,0  ]; % 21

    simple_stimXcue_P    = [ 0,0,0,m5(task),0,0  ]; % 22
    simple_stimXcue_V    = [ 0,0,0,m6(task),0,0  ]; % 23
    simple_stimXcue_C    = [ 0,0,0,m7(task),0,0  ]; % 24
    simple_stimXcue_G    = [ 0,0,0,m4(task),0,0  ]; % 25

    simple_stimXint_P    = [ 0,0,0,0,m5(task),0  ]; % 26
    simple_stimXint_V    = [ 0,0,0,0,m6(task),0  ]; % 27
    simple_stimXint_C    = [ 0,0,0,0,m7(task),0  ]; % 28
    simple_stimXint_G    = [ 0,0,0,0,m4(task),0  ]; % 29

    disp(strcat('task: ', task));

    c01 = [ c01,  cue_P,       n_cov];   c02 = [ c02, cue_V,      n_cov];   c03 = [ c03, cue_C,      n_cov];      
    c04 = [ c04,  stim_P,      n_cov];   c05 = [ c05, stim_V,     n_cov];   c06 = [ c06, stim_C,     n_cov];      
    c07 = [ c07,  stimXcue_P,  n_cov];   c08 = [ c08, stimXcue_V, n_cov];   c09 = [ c09, stimXcue_C, n_cov];
    c10 = [ c10,  stimXint_P,  n_cov];   c11 = [ c11, stimXint_V, n_cov];   c12 = [ c12, stimXint_C, n_cov];
    c13 = [ c13,  motor,   n_cov];
    c14 = [ c14,  simple_cue_P,       n_cov];   c15 = [ c15, simple_cue_V,       n_cov];   c16 = [ c16, simple_cue_C,       n_cov];   c17 = [ c17,  simple_cue_G,      n_cov];
    c18 = [ c18,  simple_stim_P,      n_cov];   c19 = [ c19, simple_stim_V,      n_cov];   c20 = [ c20, simple_stim_C,      n_cov];   c21 = [ c21,  simple_stim_G,     n_cov];
    c22 = [ c22,  simple_stimXcue_P,  n_cov];   c23 = [ c23, simple_stimXcue_V,  n_cov];   c24 = [ c24, simple_stimXcue_C,  n_cov];   c25 = [ c25,  simple_stimXcue_G, n_cov];
    c26 = [ c26,  simple_stimXint_P,  n_cov];   c27 = [ c27, simple_stimXint_V,  n_cov];   c28 = [ c28, simple_stimXint_C,  n_cov];   c29 = [ c29,  simple_stimXint_G, n_cov];
end
disp(strcat('contrast length c09', num2str(size(c09))));
contrast_vector{1} = c01;  contrast_vector{2} = c02;
contrast_vector{3} = c03;  contrast_vector{4} = c04;
contrast_vector{5} = c05;  contrast_vector{6} = c06;
contrast_vector{7} = c07;  contrast_vector{8} = c08;
contrast_vector{9} = c09;  contrast_vector{10} = c10;
contrast_vector{11} = c11; contrast_vector{12} = c12;
contrast_vector{13} = c13; contrast_vector{14} = c14;
contrast_vector{15} = c15; contrast_vector{16} = c16;
contrast_vector{17} = c17; contrast_vector{18} = c18;
contrast_vector{19} = c19; contrast_vector{20} = c20;
contrast_vector{21} = c21; contrast_vector{22} = c22;
contrast_vector{23} = c23; contrast_vector{24} = c24;
contrast_vector{25} = c25; contrast_vector{26} = c26;
contrast_vector{27} = c27; contrast_vector{28} = c28;
contrast_vector{29} = c29; 

%% 1. contrast batch _______________________________________________________
for con_num = 1: length(contrast_name)
disp(contrast_name{con_num});
    matlabbatch{1}.spm.stats.con.spmmat = cellstr( spm_fname );
    matlabbatch{1}.spm.stats.con.consess{con_num}.tcon.name = contrast_name{con_num};
    matlabbatch{1}.spm.stats.con.consess{con_num}.tcon.convec = contrast_vector{con_num};
    matlabbatch{1}.spm.stats.con.consess{con_num}.tcon.sessrep = 'none';

end

matlabbatch{1}.spm.stats.con.delete = 1; % delete previous contrast

con_batch = fullfile(fmri_dir, 'contrast_estimation.mat' );
save( con_batch  ,'matlabbatch');

% 2. Run ___________________________________________________________________
spm_jobman('run',matlabbatch);
clearvars matlabbatch

end
