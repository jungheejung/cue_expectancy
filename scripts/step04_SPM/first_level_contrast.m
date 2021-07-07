function first_level_contrast(input)
% parameters ___________________________________________________________________
% main_dir = '/Users/h/Documents/projects_local/conformity.01';
main_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/';
matlabbatch = cell(1,1);

sub_num = sscanf(char(input),'%d');
sub = strcat('sub-', sprintf('%04d', sub_num));
disp( sub );


fmri_dir = fullfile(main_dir,'analysis', 'fmri', 'spm', 'model-01_CcEScaA',...
    '1stLevel', sub); % first level spm mat.
spm_fname = fullfile(fmri_dir, 'SPM.mat');

% contrast
onset_dir = fullfile(main_dir, 'data', 'dartmouth', 'd04_EV_SPM');

contrast_name = {'cue_P', 'cue_V', 'cue_C', 'cue_G',...
    'stim_P', 'stim_V', 'stim_C', 'stim_G',...
    'stimXcue_P', 'stimXcue_V', 'stimXcue_C', 'stimXcue_G',...
    'stimXactual_P', 'stimXactual_V', 'stimXactual_C', 'stimXactual_G', 'motor'};

c01 = []; c02 = []; c03 = []; c04 = [];c05 = []; c06 = []; c07 = []; c08 = [];
c09 = []; c10 = []; c11 = []; c12 = [];c13 = []; c14 = []; c15 = []; c16 = []; c17 = [];

filelist = dir(fullfile(onset_dir, sub, '*/*_events.tsv'));
T = struct2table(filelist); % convert the struct array to a table
sortedT = sortrows(T, 'name');

for run_ind = 1: size(sortedT,1)
    disp(strcat('run', num2str(run_ind)));
    sub_num = sscanf(char(extractBetween(sortedT.name(run_ind), 'sub-', '_')),'%d'); sub = strcat('sub-', sprintf('%04d', sub_num));
    ses_num = sscanf(char(extractBetween(sortedT.name(run_ind), 'ses-', '_')),'%d'); ses = strcat('ses-', sprintf('%02d', ses_num));
    run_num = sscanf(char(extractBetween(sortedT.name(run_ind), 'run-', '_')),'%d'); run = strcat('run-', sprintf('%01d', run_num));
    onset_fname   = fullfile(char(sortedT.folder(run_ind)), char(sortedT.name(run_ind)));
    social        = struct2table(tdfread(onset_fname));
    keyword       = extractBetween(sortedT.name(run_ind), 'run-0', '_events.tsv');
    task          = char(extractAfter(keyword, '-'));
    cue_P         = [ 0,m1(task),0,0,0,0,0,0,0,0,0,0,0,0,0 ];
    cue_V         = [ 0,m2(task),0,0,0,0,0,0,0,0,0,0,0,0,0  ];
    cue_C         = [ 0,m3(task),0,0,0,0,0,0,0,0,0,0,0,0,0  ];
    cue_G         = [ 0,m4(task),0,0,0,0,0,0,0,0,0,0,0,0,0  ];
    stim_P        = [ 0,0,0,m1(task),0,0,0,0,0,0,0,0,0,0,0  ];
    stim_V        = [ 0,0,0,m2(task),0,0,0,0,0,0,0,0,0,0,0  ];
    stim_C        = [ 0,0,0,m3(task),0,0,0,0,0,0,0,0,0,0,0  ];
    stim_G        = [ 0,0,0,m4(task),0,0,0,0,0,0,0,0,0,0,0  ];
    stimXcue_P    = [ 0,0,0,0,m1(task),0,0,0,0,0,0,0,0,0,0  ];
    stimXcue_V    = [ 0,0,0,0,m2(task),0,0,0,0,0,0,0,0,0,0  ];
    stimXcue_C    = [ 0,0,0,0,m3(task),0,0,0,0,0,0,0,0,0,0  ];
    stimXcue_G    = [ 0,0,0,0,m4(task),0,0,0,0,0,0,0,0,0,0  ];
    stimXactual_P = [ 0,0,0,0,0,m1(task),0,0,0,0,0,0,0,0,0  ];
    stimXactual_V = [ 0,0,0,0,0,m2(task),0,0,0,0,0,0,0,0,0  ];
    stimXactual_C = [ 0,0,0,0,0,m3(task),0,0,0,0,0,0,0,0,0  ];
    stimXactual_G = [ 0,0,0,0,0,m4(task),0,0,0,0,0,0,0,0,0  ];
    motor         = [ 0,0,1,0,0,0,1,0,0,0,0,0,0,0,0    ];
    c01 = [ c01  cue_P];  c02 = [ c02  cue_V];  c03 = [ c03  cue_C];  c04 = [ c04  cue_G];
    c05 = [ c05  stim_P];  c06 = [ c06  stim_V];  c07 = [ c07  stim_C];  c08 = [ c08  stim_G];
    c09 = [ c09  stimXcue_P];  c10 = [ c10  stimXcue_V];  c11 = [ c11  stimXcue_C];  c12 = [ c12  stimXcue_G];
    c13 = [ c13  stimXactual_P];  c14 = [ c14  stimXactual_V];  c15 = [ c15  stimXactual_C];  c16 = [ c16  stimXactual_G];
    c17 = [ c17  motor];
end

contrast_vector{1} = c01; contrast_vector{2} = c02;
contrast_vector{3} = c03; contrast_vector{4} = c04;
contrast_vector{5} = c05; contrast_vector{6} = c06;
contrast_vector{7} = c07; contrast_vector{8} = c08;
contrast_vector{9} = c09; contrast_vector{10} = c10;
contrast_vector{11} = c11; contrast_vector{12} = c12;
contrast_vector{13} = c13; contrast_vector{14} = c14;
contrast_vector{15} = c15; contrast_vector{16} = c16;
contrast_vector{17} = c17;
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
