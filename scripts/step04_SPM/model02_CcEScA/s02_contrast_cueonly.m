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
fmriprep_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/dartmouth/fmriprep/fmriprep/'; % sub / ses
main_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/';
motion_dir = fullfile(main_dir, 'data', 'dartmouth', 'd05_motion');
onset_dir = fullfile(main_dir, 'data', 'dartmouth', 'd04_EV_SPM');



sub_num = sscanf(char(input),'%d');
sub = strcat('sub-', sprintf('%04d', sub_num));
disp( sub );
fmri_dir = fullfile(main_dir,'analysis', 'fmri', 'spm', 'univariate', 'model-02_CcEScA',...
    '1stLevel', sub); % first level spm mat.
spm_fname = fullfile(fmri_dir, 'SPM.mat');


% NOTE 03 find intersection of nifti and onset files
% find nifti files
niilist = dir(fullfile(fmriprep_dir, sub, '*/func/smooth_5mm_*task-social*_bold.nii'));
nT = struct2table(niilist); % convert the struct array to a table
sortedT = sortrows(nT, 'name'); % sort the table by 'DOB'

sortedT.sub_num(:) = str2double(extractBetween(sortedT.name, 'sub-', '_'));
sortedT.ses_num(:) = str2double(extractBetween(sortedT.name, 'ses-', '_'));
sortedT.run_num(:) = str2double(extractBetween(sortedT.name, 'run-', '_'));

nii_col_names = sortedT.Properties.VariableNames;
nii_num_colomn = nii_col_names(endsWith(nii_col_names, '_num'));

% find onset files
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

% NOTE 04 define contrast

contrast_name = {'cue_P', 'cue_V', 'cue_C', 'cue_G',...
    'cueXcue_P', 'cueXcue_V', 'cueXcue_C', 'cueXcue_G',...
    'stim_P', 'stim_V', 'stim_C', 'stim_G',...
    'stimXcue_P', 'stimXcue_V', 'stimXcue_C', 'stimXcue_G',...
    'motor', ...
    'simple_cue_P', 'simple_cue_V', 'simple_cue_C',...
    'simple_cueXcue_P', 'simple_cueXcue_V', 'simple_cueXcue_C', ...
    'simple_stim_P', 'simple_stim_V', 'simple_stim_C',...
    'simple_stimXcue_P', 'simple_stimXcue_V', 'simple_stimXcue_C'};

c01 = []; c02 = []; c03 = []; c04 = []; c05 = []; c06 = []; c07 = []; c08 = []; c09 = []; c10 = []; 
c11 = []; c12 = []; c13 = []; c14 = []; c15 = []; c16 = []; c17 = []; c18 = []; c19 = []; c20 = []; 
c21 = []; c22 = []; c23 = []; c24 = []; c25 = []; c26 = []; c27 = []; c28 = []; c29 = []; 


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

    cue_P         = [ m1(task),0,0,0,0,0,0,0,0,0,0,0,0,0  ];
    cue_V         = [ m2(task),0,0,0,0,0,0,0,0,0,0,0,0,0  ];
    cue_C         = [ m3(task),0,0,0,0,0,0,0,0,0,0,0,0,0  ];
    cue_G         = [ m4(task),0,0,0,0,0,0,0,0,0,0,0,0,0  ];
    cueXcue_P     = [ 0,m1(task),0,0,0,0,0,0,0,0,0,0,0,0  ];
    cueXcue_V     = [ 0,m2(task),0,0,0,0,0,0,0,0,0,0,0,0  ];
    cueXcue_C     = [ 0,m3(task),0,0,0,0,0,0,0,0,0,0,0,0  ];
    cueXcue_G     = [ 0,m4(task),0,0,0,0,0,0,0,0,0,0,0,0  ];
    stim_P        = [ 0,0,0,m1(task),0,0,0,0,0,0,0,0,0,0  ];
    stim_V        = [ 0,0,0,m2(task),0,0,0,0,0,0,0,0,0,0  ];
    stim_C        = [ 0,0,0,m3(task),0,0,0,0,0,0,0,0,0,0  ];
    stim_G        = [ 0,0,0,m4(task),0,0,0,0,0,0,0,0,0,0  ];
    stimXcue_P    = [ 0,0,0,0,m1(task),0,0,0,0,0,0,0,0,0  ];
    stimXcue_V    = [ 0,0,0,0,m2(task),0,0,0,0,0,0,0,0,0  ];
    stimXcue_C    = [ 0,0,0,0,m3(task),0,0,0,0,0,0,0,0,0  ];
    stimXcue_G    = [ 0,0,0,0,m4(task),0,0,0,0,0,0,0,0,0  ];

    motor         = [ 0,0,1,0,0,1,0,0,0,0,0,0,0,0    ];
    simple_cue_P         = [ m5(task),0,0,0,0,0,0,0,0,0,0,0,0,0,0  ];
    simple_cue_V         = [ m6(task),0,0,0,0,0,0,0,0,0,0,0,0,0,0  ];
    simple_cue_C         = [ m7(task),0,0,0,0,0,0,0,0,0,0,0,0,0,0  ];
    simple_cueXcue_P     = [ 0,m5(task),0,0,0,0,0,0,0,0,0,0,0,0,0  ];
    simple_cueXcue_V     = [ 0,m6(task),0,0,0,0,0,0,0,0,0,0,0,0,0  ];
    simple_cueXcue_C     = [ 0,m7(task),0,0,0,0,0,0,0,0,0,0,0,0,0  ];
    simple_stim_P        = [ 0,0,0,m5(task),0,0,0,0,0,0,0,0,0,0,0  ];
    simple_stim_V        = [ 0,0,0,m6(task),0,0,0,0,0,0,0,0,0,0,0  ];
    simple_stim_C        = [ 0,0,0,m7(task),0,0,0,0,0,0,0,0,0,0,0  ];
    simple_stimXcue_P    = [ 0,0,0,0,m5(task),0,0,0,0,0,0,0,0,0,0  ];
    simple_stimXcue_V    = [ 0,0,0,0,m6(task),0,0,0,0,0,0,0,0,0,0  ];
    simple_stimXcue_C    = [ 0,0,0,0,m7(task),0,0,0,0,0,0,0,0,0,0  ];


    disp(strcat('task: ', task));

    c01 = [ c01  cue_P];       c02 = [ c02  cue_V];       c03 = [ c03  cue_C];       c04 = [ c04  cue_G];
    c05 = [ c05  cueXcue_P];   c06 = [ c06  cueXcue_V];   c07 = [ c07  cueXcue_C];   c08 = [ c08  cueXcue_G];
    c09 = [ c09  stim_P];      c10 = [ c10  stim_V];      c11 = [ c11  stim_C];      c12 = [ c12  stim_G];
    c13 = [ c13  stimXcue_P];  c14 = [ c14  stimXcue_V];  c15 = [ c15  stimXcue_C];  c16 = [ c16  stimXcue_G];
    c17 = [ c17  motor];
    c18 = [ c18  simple_cue_P];      c19 = [ c19  simple_cue_V];      c20 = [ c20  simple_cue_C];
    c21 = [ c21  simple_cueXcue_P];  c22 = [ c22  simple_cueXcue_V];  c23 = [ c23  simple_cueXcue_C];
    c24 = [ c24  simple_stim_P];     c25 = [ c25  simple_stim_V];     c26 = [ c26  simple_stim_C];
    c27 = [ c27  simple_stimXcue_P]; c28 = [ c28  simple_stimXcue_V]; c29 = [ c29  simple_stimXcue_C];
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
contrast_vector{25} = c25; contrast_vector{26} = c26;
contrast_vector{27} = c27; contrast_vector{28} = c28;
contrast_vector{29} = c29; 
%% 1. contrast batch _______________________________________________________
for con_num = 1: length(contrast_name)

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
