function s02_contrast_6cond(sub, input_dir, main_dir)

    % PARAMETERS
    %     - STIM: CUE h x STIM h (onset03_stim)
    %     - STIM: CUE h x STIM m
    %     - STIM: CUE h x STIM l
    %     - STIM: CUE l x STIM h
    %     - STIM: CUE l x STIM m
    %     - STIM: CUE l x STIM l
    %     - CUE: onset01_cue
    %     - EXPECT RATING: onset02_ratingexpect, pmod_expectRT
    %     - OUTCOME RATING: onset04_ratingoutcome, pmod_outcomeRT


% NOTE 01 start jobs
disp('...STARTING JOBS');

rootgroup = settings; rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = 'v7.3'

numscans = 56;
disacqs = 0;
disp(strcat('[ STEP 01 ] setting parameters...'));

% contrast mapper _______________________________________________________
keySet = {'pain','vicarious','cognitive'};
cue_high_gt_low         = [1,1,1,-1,-1,-1];
stimlin_high_gt_low     = [1,0,-1,1,0,-1];
stimquad_med_gt_other   = [-1,2,-1,-1,2,-1];
cue_int_stimlin         = [1,0,-1,-1,0,1];
cue_int_stimquad        = [-1,2,-1,1,-2,1];

con1 = [2 -1 -1];   con2 = [-1 2 -1];   con3 = [-1 -1 2];   con4 = [1 1 1];
con5 = [1 0 0];     con6 = [0 1 0];     con7 = [0 0 1];
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

disp( strcat('-----------------------',sub,'----------------------' ));
output_dir = fullfile(main_dir, 'analysis', 'fmri', 'spm', 'univariate', 'model01_6cond', ...
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

contrast_name = {'P_VC_cue_high_gt_low', 'V_PC_cue_high_gt_low', 'C_PV_cue_high_gt_low', ...
'P_VC_stimlin_high_gt_low', 'V_PC_stimlin_high_gt_low', 'C_PV_stimlin_high_gt_low',...
'P_VC_stimquad_med_gt_other', 'V_PC_stimquad_med_gt_other', 'C_PV_stimquad_med_gt_other',...
'P_VC_cue_int_stimlin','V_PC_cue_int_stimlin', 'C_PV_cue_int_stimlin',...
'P_VC_cue_int_stimquad','V_PC_cue_int_stimquad','C_PV_cue_int_stimquad',...
'motor',...
'P_simple_cue_high_gt_low', 'V_simple_cue_high_gt_low', 'C_simple_cue_high_gt_low', ...
'P_simple_stimlin_high_gt_low', 'V_simple_stimlin_high_gt_low', 'C_simple_stimlin_high_gt_low',...
'P_simple_stimquad_med_gt_other', 'V_simple_stimquad_med_gt_other', 'C_simple_stimquad_med_gt_other',...
'P_simple_cue_int_stimlin', 'V_simple_cue_int_stimlin', 'C_simple_cue_int_stimlin',...
'P_simple_cue_int_stimquad','V_simple_cue_int_stimquad','C_simple_cue_int_stimquad'
};

c01 = []; c02 = []; c03 = []; c04 = []; c05 = []; c06 = []; c07 = []; c08 = []; c09 = []; c10 = [];
c11 = []; c12 = []; c13 = []; c14 = []; c15 = []; c16 = []; c17 = []; c18 = []; c19 = []; c20 = [];
c21 = []; c22 = []; c23 = []; c24 = []; c25 = []; c26 = []; c27 = []; c28 = []; c29 = []; c30 = [];
c31 = [];
matlabbatch = cell(1,1);

for run_ind = 1: size(A,1)
    disp(strcat('run', num2str(run_ind)));
    sub = strcat('sub-', sprintf('%04d', A.sub_num(run_ind)));
    ses = strcat('ses-', sprintf('%02d', A.ses_num(run_ind)));
    run = strcat('run-', sprintf('%01d', A.run_num(run_ind)));
    disp('identify covariates');
    covariate = zeros(1, size(SPM.Sess(run_ind).C.name,2));
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


    P_VC_cue_high_gt_low         = [ m1(task)*cue_high_gt_low,0,0,0,covariate ];
    V_PC_cue_high_gt_low         = [ m2(task)*cue_high_gt_low,0,0,0,covariate ];
    C_PV_cue_high_gt_low         = [ m3(task)*cue_high_gt_low,0,0,0,covariate ];

    P_VC_stimlin_high_gt_low     = [ m1(task)*stimlin_high_gt_low,0,0,0,covariate ];
    V_PC_stimlin_high_gt_low     = [ m2(task)*stimlin_high_gt_low,0,0,0,covariate ];
    C_PV_stimlin_high_gt_low     = [ m3(task)*stimlin_high_gt_low,0,0,0,covariate ];

    P_VC_stimquad_med_gt_other   = [ m1(task)*stimquad_med_gt_other,0,0,0,covariate ];
    V_PC_stimquad_med_gt_other   = [ m2(task)*stimquad_med_gt_other,0,0,0,covariate ];
    C_PV_stimquad_med_gt_other   = [ m3(task)*stimquad_med_gt_other,0,0,0,covariate ];

    P_VC_cue_int_stimlin         = [ m1(task)*cue_int_stimlin,0,0,0,covariate ];
    V_PC_cue_int_stimlin         = [ m2(task)*cue_int_stimlin,0,0,0,covariate ];
    C_PV_cue_int_stimlin         = [ m3(task)*cue_int_stimlin,0,0,0,covariate ];

    P_VC_cue_int_stimquad        = [ m1(task)*cue_int_stimquad,0,0,0,covariate ];
    V_PC_cue_int_stimquad        = [ m2(task)*cue_int_stimquad,0,0,0,covariate ];
    C_PV_cue_int_stimquad        = [ m3(task)*cue_int_stimquad,0,0,0,covariate ];

    motor                        = [ 0,0,0,0,0,0,0,1,1,covariate ];

    P_simple_cue_high_gt_low         = [ m5(task)*cue_high_gt_low,0,0,0,covariate ];
    V_simple_cue_high_gt_low         = [ m6(task)*cue_high_gt_low,0,0,0,covariate ];
    C_simple_cue_high_gt_low         = [ m7(task)*cue_high_gt_low,0,0,0,covariate ];

    P_simple_stimlin_high_gt_low     = [ m5(task)*stimlin_high_gt_low,0,0,0,covariate ];
    V_simple_stimlin_high_gt_low     = [ m6(task)*stimlin_high_gt_low,0,0,0,covariate ];
    C_simple_stimlin_high_gt_low     = [ m7(task)*stimlin_high_gt_low,0,0,0,covariate ];

    P_simple_stimquad_med_gt_other   = [ m5(task)*stimquad_med_gt_other,0,0,0,covariate ];
    V_simple_stimquad_med_gt_other   = [ m6(task)*stimquad_med_gt_other,0,0,0,covariate ];
    C_simple_stimquad_med_gt_other   = [ m7(task)*stimquad_med_gt_other,0,0,0,covariate ];

    P_simple_cue_int_stimlin         = [ m5(task)*cue_int_stimlin,0,0,0,covariate ];
    V_simple_cue_int_stimlin         = [ m6(task)*cue_int_stimlin,0,0,0,covariate ];
    C_simple_cue_int_stimlin         = [ m7(task)*cue_int_stimlin,0,0,0,covariate ];

    P_simple_cue_int_stimquad        = [ m5(task)*cue_int_stimquad,0,0,0,covariate ];
    V_simple_cue_int_stimquad        = [ m6(task)*cue_int_stimquad,0,0,0,covariate ];
    C_simple_cue_int_stimquad        = [ m7(task)*cue_int_stimquad,0,0,0,covariate ];

    c01 = [ c01  P_VC_cue_high_gt_low];         c02 = [ c02  V_PC_cue_high_gt_low];         c03 = [ c03  C_PV_cue_high_gt_low];
    c04 = [ c04  P_VC_stimlin_high_gt_low];     c05 = [ c05  V_PC_stimlin_high_gt_low];     c06 = [ c06  C_PV_stimlin_high_gt_low];   
    c07 = [ c07  P_VC_stimquad_med_gt_other];   c08 = [ c08  V_PC_stimquad_med_gt_other];   c09 = [ c09  C_PV_stimquad_med_gt_other]; 
    c10 = [ c10  P_VC_cue_int_stimlin];         c11 = [ c11  V_PC_cue_int_stimlin];         c12 = [ c12  C_PV_cue_int_stimlin];   
    c13 = [ c13  P_VC_cue_int_stimquad];        c14 = [ c14  V_PC_cue_int_stimquad];        c15 = [ c15  C_PV_cue_int_stimquad];    
    c16 = [ c16  motor];
    c17 = [ c17  P_simple_cue_high_gt_low];         c18 = [ c18  V_simple_cue_high_gt_low];         c19 = [ c19  C_simple_cue_high_gt_low];
    c20 = [ c20  P_simple_stimlin_high_gt_low];     c21 = [ c21  V_simple_stimlin_high_gt_low];     c22 = [ c22  C_simple_stimlin_high_gt_low];   
    c23 = [ c23  P_simple_stimquad_med_gt_other];   c24 = [ c24  V_simple_stimquad_med_gt_other];   c25 = [ c25  C_simple_stimquad_med_gt_other]; 
    c26 = [ c26  P_simple_cue_int_stimlin];         c27 = [ c27  V_simple_cue_int_stimlin];         c28 = [ c28  C_simple_cue_int_stimlin];   
    c29 = [ c29  P_simple_cue_int_stimquad];        c30 = [ c30  V_simple_cue_int_stimquad];        c31 = [ c31  C_simple_cue_int_stimquad];    
    disp(strcat('task: ', task));

 end

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
contrast_vector{29} = c29; contrast_vector{30} = c30;
contrast_vector{31} = c31;
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
