function s02_contrast(sub, input_dir, main_dir)

% NOTE 01 start jobs
disp('...STARTING JOBS');

rootgroup = settings; rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = 'v7.3'

numscans = 56;
disacqs = 0;
disp(sub);
disp(strcat('[ STEP 01 ] setting parameters...'));

% contrast mapper _______________________________________________________
keySet = {'pain','vicarious','cognitive'};
con1 = [2 -1 -1];   con2 = [-1 2 -1];  con3 = [-1 -1 2];  con4 = [1 1 1];
con5 = [1 0 0]; con6 = [0 1 0]; con7 = [0 0 1];
% m1 = containers.Map(keySet,con1);
% m2 = containers.Map(keySet,con2);
% m3 = containers.Map(keySet,con3);
% m4 = containers.Map(keySet,con4);
% m5 = containers.Map(keySet,con5);
% m6 = containers.Map(keySet,con6);
% m7 = containers.Map(keySet,con7);


m1 = containers.Map(keySet,con1);
m2 = containers.Map(keySet,con2);
m3 = containers.Map(keySet,con3);
m4 = containers.Map(keySet,con4);
m5 = containers.Map(keySet,con5);
m6 = containers.Map(keySet,con6);
m7 = containers.Map(keySet,con7);
% C E S c i O  
% 1 2 3 4 5 6
epoch_cue               = [1,0,0,0,0,0];
epoch_motor             = [0,1,0,0,0,1];
epoch_stim              = [0,0,1,0,0,0];
pmod_stimXcue           = [0,0,0,1,0,0];
pmod_stimXintensity     = [0,0,0,0,1,0];

% NOTE 02 define directories _______________________________________________________
motion_dir = fullfile(main_dir, 'data', 'fmri', 'fmri02_motion');
onset_dir = fullfile(main_dir, 'data', 'fmri', 'fmri01_onset', 'onset02_SPM');

% fmriprep_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/dartmouth/fmriprep/fmriprep/'; % sub / ses
% main_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/';
% motion_dir = fullfile(main_dir, 'data', 'dartmouth', 'd05_motion');
% onset_dir = fullfile(main_dir, 'data', 'dartmouth', 'd04_EV_SPM');

% sub_num = sscanf(char(input),'%d');
disp( strcat('-----------------------',sub,'----------------------' ));
output_dir = fullfile(main_dir, 'analysis', 'fmri', 'spm', 'univariate', 'model02_CESciO', ...
'1stLevel', sub);
spm_fname = fullfile(output_dir, 'SPM.mat');
load(spm_fname);

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
contrast_name = {
    'P_VC_epoch_cue', 'V_PC_epoch_cue', 'C_PV_epoch_cue',...
    'P_VC_epoch_stim', 'V_PC_epoch_stim', 'C_PV_epoch_stim',...
    'P_VC_pmod_stimXcue', 'V_PC_pmod_stimXcue', 'C_PV_pmod_stimXcue',...
    'P_VC_pmod_stimXintensity', 'V_PC_pmod_stimXintensity', 'C_PV_pmod_stimXintensity',...
    'motor',...
    'P_simple_epoch_cue', 'V_simple_epoch_cue', 'C_simple_epoch_cue',...
    'P_simple_epoch_stim', 'V_simple_epoch_stim', 'C_simple_epoch_stim',...
    'P_simple_pmod_stimXcue', 'V_simple_pmod_stimXcue', 'C_simple_pmod_stimXcue',...
    'P_simple_pmod_stimXintensity', 'V_simple_pmod_stimXintensity', 'C_simple_pmod_stimXintensity'
};

    
c01 = []; c02 = []; c03 = []; c04 = []; c05 = []; c06 = []; c07 = []; c08 = []; c09 = []; c10 = [];
c11 = []; c12 = []; c13 = []; c14 = []; c15 = []; c16 = []; c17 = []; c18 = []; c19 = []; c20 = []; 
c21 = []; c22 = []; c23 = []; c24 = []; c25 = []; 

matlabbatch = cell(1,1);

for run_ind = 1: size(A,1)
    disp(strcat('run', num2str(run_ind)));
    sub = strcat('sub-', sprintf('%04d', A.sub_num(run_ind)));
    ses = strcat('ses-', sprintf('%02d', A.ses_num(run_ind)));
    run = strcat('run-', sprintf('%01d', A.run_num(run_ind)));
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

    P_VC_epoch_cue               = [ (m1(task)*epoch_cue)/runlength,covariate ];
    V_PC_epoch_cue               = [ (m2(task)*epoch_cue)/runlength,covariate ];
    C_PV_epoch_cue               = [ (m3(task)*epoch_cue)/runlength,covariate ];
    
    P_VC_epoch_stim              = [ (m1(task)*epoch_stim )/runlength,covariate ];
    V_PC_epoch_stim              = [ (m2(task)*epoch_stim )/runlength,covariate ];
    C_PV_epoch_stim              = [ (m3(task)*epoch_stim )/runlength,covariate ];
    
    P_VC_pmod_stimXcue           = [ (m1(task)*pmod_stimXcue )/runlength,covariate ];
    V_PC_pmod_stimXcue           = [ (m2(task)*pmod_stimXcue )/runlength,covariate ];
    C_PV_pmod_stimXcue           = [ (m3(task)*pmod_stimXcue )/runlength,covariate ];
    
    P_VC_pmod_stimXintensity     = [ (m1(task)*pmod_stimXintensity )/runlength,covariate ];
    V_PC_pmod_stimXintensity     = [ (m2(task)*pmod_stimXintensity )/runlength,covariate ];
    C_PV_pmod_stimXintensity     = [ (m3(task)*pmod_stimXintensity )/runlength,covariate ];
    
    motor                        = [ epoch_motor,covariate ];
    
    P_simple_epoch_cue               = [ (m5(task)*epoch_cue)/runlength,covariate ];
    V_simple_epoch_cue               = [ (m6(task)*epoch_cue)/runlength,covariate ];
    C_simple_epoch_cue               = [ (m7(task)*epoch_cue)/runlength,covariate ];
    
    P_simple_epoch_stim              = [ (m5(task)*epoch_stim )/runlength,covariate ];
    V_simple_epoch_stim              = [ (m6(task)*epoch_stim )/runlength,covariate ];
    C_simple_epoch_stim              = [ (m7(task)*epoch_stim )/runlength,covariate ];
    
    P_simple_pmod_stimXcue           = [ (m5(task)*pmod_stimXcue )/runlength,covariate ];
    V_simple_pmod_stimXcue           = [ (m6(task)*pmod_stimXcue )/runlength,covariate ];
    C_simple_pmod_stimXcue           = [ (m7(task)*pmod_stimXcue )/runlength,covariate ];
    
    P_simple_pmod_stimXintensity     = [ (m5(task)*pmod_stimXintensity )/runlength,covariate ];
    V_simple_pmod_stimXintensity     = [ (m6(task)*pmod_stimXintensity )/runlength,covariate ];
    C_simple_pmod_stimXintensity     = [ (m7(task)*pmod_stimXintensity )/runlength,covariate ];
    
    c01 = [c01, P_VC_epoch_cue];          c02 = [c02, V_PC_epoch_cue];          c03 = [c03, C_PV_epoch_cue];
    c04 = [c04, P_VC_epoch_stim];         c05 = [c05, V_PC_epoch_stim];         c06 = [c06, C_PV_epoch_stim];
    c07 = [c07, P_VC_pmod_stimXcue];      c08 = [c08, V_PC_pmod_stimXcue];      c09 = [c09, C_PV_pmod_stimXcue];
    c10 = [c10, P_VC_pmod_stimXintensity];c11 = [c11, V_PC_pmod_stimXintensity];c12 = [c12, C_PV_pmod_stimXintensity];
    c13 = [c13, motor];
    c14 = [c14, P_simple_epoch_cue];          c15 = [c15, V_simple_epoch_cue];          c16 = [c16, C_simple_epoch_cue];
    c17 = [c17, P_simple_epoch_stim];         c18 = [c18, V_simple_epoch_stim];         c19 = [c19, C_simple_epoch_stim];
    c20 = [c20, P_simple_pmod_stimXcue];      c21 = [c21, V_simple_pmod_stimXcue];      c22 = [c22, C_simple_pmod_stimXcue];
    c23 = [c23, P_simple_pmod_stimXintensity];c24 = [c24, V_simple_pmod_stimXintensity];c25 = [c25, C_simple_pmod_stimXintensity];
    
    disp(strcat('task: ', task));

 end

contrast_vector{1} = c01; contrast_vector{2} = c02;
contrast_vector{3} = c03; contrast_vector{4} = c04;
contrast_vector{5} = c05; contrast_vector{6} = c06;
contrast_vector{7} = c07; contrast_vector{8} = c08;
contrast_vector{9} = c09; contrast_vector{10} = c10;
contrast_vector{11} = c11; contrast_vector{12} = c12;
contrast_vector{13} = c13; contrast_vector{14} = c14;
contrast_vector{15} = c15; contrast_vector{16} = c16;
contrast_vector{17} = c17; contrast_vector{18} = c18;
contrast_vector{19} = c19; contrast_vector{20} = c20;
contrast_vector{21} = c21; contrast_vector{22} = c22;
contrast_vector{23} = c23; contrast_vector{24} = c24;
contrast_vector{25} = c25; 


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
