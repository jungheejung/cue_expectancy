
%% Step 1 load single trials__________________________________________________

% TODO:
% 1. for each subject, get fsl estimated single trials
% 2. stack in FSL >  
% sub-0020_ses-03_run-05-pain_ev-stim-0011.nii.gz 
% sub-0020_ses-03_run-05-pain_ev-stim-0010.nii.gz 
% >> concatenate across session and runs. 
% >> save as sub-0020_task-pain.nii.gz
% >> save metadata into json, so that I can grab matching behavioral data, too
% 2. UNGUNZIP if not 
%       [x] unpack nii.gz as .nii 
% 2. [ ] load into cell 
% 3. [ ] grab corresponding dataframe from behavioral data. 
% 4. need to unpack behavioral data and match with corresponding nifti
% first extract 1) sub, 2) ses, 3) run, 4) trial num
% 1) load each sub_ses_run.csv file
% (e.g.sub-0002_ses-01_task-social_run-01-pain_beh.csv)
% 2) search for corresponding sub, ses, run, trial num, trial type 
% 3) extract cue and rating info. 


mount_dir = '/Users/h/Documents/MATLAB/test_social/';
stack_dir = '/Volumes/social/analysis/fmri/fsl/multivariate/isolate_nifti/';
% stack_dir = '/Users/h/Documents/projects_local/social_influence_analysis/scripts/step05_mediation';

% fmri_data( );
% M_hj = cell(1,4);
% sub-0002: 204 trials
% sub-0008: 192 trials
% sub-0019: 204 trials

sublist = [2, 8, 9]%, 19];%,26];
%% 1. for each subject, get fsl estimated single trials
    X = cell(1, length(sublist));
    M = cell(1, length(sublist));
    Y = cell(1, length(sublist));
    
    

for s = 1 : length(sublist)

    simpleP_t = dir(fullfile(stack_dir,...
        strcat('sub-',sprintf('%04d', sublist(s))),...
        strcat('sub-*_ses-*_run-*_ev-stim-*.nii.gz'))); 
    
    simpleP_fldr = {simpleP_t.folder}; fname = {simpleP_t.name};
    simpleP_files = strcat(simpleP_fldr,'/', fname)';
    nii_files = regexprep(simpleP_files, '(?:\.[^\.]*$|$)', '');
    
%     %% 2. UNGUNZIP if not 
%     for n = 1:length(nii_files)
%     if ~exist(char(nii_files(n)),'file') 
%         gunzip(char(simpleP_files(n)))
%     end
%     end
    
    %% spm_file_merge
    single_concat_dir = '/Users/h/Documents/projects_local/social_influence_analysis/sandbox';
    stacked_single = fullfile(single_concat_dir,strcat('single-trial_sub-',sprintf('%04d', sublist(s)), '.nii'));
%     if ~exist(char(stacked_single, 'file'))
%         v4 = spm_file_merge(nii_files,...
%         fullfile(single_concat_dir,...
%         strcat('single-trial_sub-',sprintf('%04d', sublist(s)))));
%     end

    %% 3. get corresponding behavioral data by loading in corresponding CSV files
    cue_contrast = []; expect_rating = []; actual_rating = [];
    for n = 1:length(nii_files)

        A = regexp( simpleP_t(n).name, '\<0*[+]?\d+\.?\d', 'match' );
        sub   = str2num(A{1});
        ses   = str2num(A{2});
        run   = str2num(A{3});
        trial = str2num(A{4});
        
        table_dir = '/Users/h/Documents/projects_local/social_influence_analysis/data/dartmouth/d02_preprocessed_N60';
        csv_fname = dir(fullfile(table_dir,...
            strcat('sub-', A{1}),...
            strcat('ses-', A{2}),...
            strcat('sub-', A{1}, '_ses-', A{2}, '_task-social_run-', A{3}, '*.csv')));
        T = readtable(fullfile(csv_fname.folder, csv_fname.name));
                
        % grab cue type info, append to dataframe
        if strcmpi(char(T.param_cue_type(trial+1)), 'low_cue')
            cue_contrast = [cue_contrast ; -1];
        elseif strcmpi(char(T.param_cue_type(trial+1)), 'high_cue')
            cue_contrast = [cue_contrast ; 1];
        end
        
        actual_rating = [actual_rating; T.event04_actual_angle(trial+1)];
        expect_rating = [expect_rating; T.event02_expect_angle(trial+1)];
        
        
    end
    X{1,s} = cue_contrast;
    Y{1,s} = actual_rating;
    M{1,s} = fullfile(single_concat_dir,strcat('single-trial_sub-',sprintf('%04d', sublist(s)), '.nii'));

    % save as table
    vnames = {'trial', 'cue', 'actual_rating', 'nii_filename'};
    vtypes = {'double','double','double','string'};
    F = table('Size', [size(design_file,1), size(vnames,2)], 'VariableNames', vnames, 'VariableTypes', vtypes);
    F.trial = 1:length(nii_files);
    F.cue = cue_contrast;
    F.actual_rating = actual_rating;
    F.nii_filename = nii_files;
    save_tableF = 
    writetable(F,save_tableF);

        
end

% 
% for s = 1 %: length(sublist)
%     M{1,s} = fullfile(single_concat_dir,strcat('single-trial_sub-',sprintf('%04d', sublist(s)), '.nii'));
% end


%% Step 2 __________________________________________________
% extract number from ev information Xtrial_num
% load csv and grab the corresponding row and stim rating information
% for i = 1:4
% Y_hj{i} = [26.04888695,0,...
% 18.50775155,74.18080605,...
% 9.68878656,46.46048251,...
% 50.25380275,2.070030653,...
% 18.50775155,3.561533089,...
% 0.69586594,83.33038016]';
% end
% 
% for i = 1:4
% X_hj{i} = [ 1, -1,...   
%         1, 1,...
%         1, 1,...
%         -1, -1,... 
%         1, -1,...
%         -1, -1]';% cue type
% end

% mask = '/Users/h/Documents/MATLAB/CanlabCore/CanlabCore/canlab_canonical_brains/Canonical_brains_surfaces/brainmask.nii';
% mask = which('gray_matter_mask.img');
% SETUP.TR=0.46;
% SETUP.HPlength = 100;
% SETUP.dummyscans = 6;
% % SETUP.scans_per_session = [872 872 872 872 872 872 872 872 872 872 872 872];
% SETUP.wh_is_mediator = 'M';
% SETUP.outputnames = 'ouput.nii';

SETUP.mask = which('gray_matter_mask.nii');
SETUP.preprocX = 0;
SETUP.preprocY = 0;
SETUP.preprocM = 0;
SETUP.wh_is_mediator = 'M';
% SETUP. = ;

% mediation_brain_multilevel(SETUP.data.X, SETUP.data.Y, SETUP.data.M, struct('mask', spm_get(1), 'startslice', 7), 'boot', 'nopreproc','bootsamples', 10000);
% SETUP.names = {'X:Cue' 'Y:Actual Rating' 'M:BrainMediator'};



% What to do if I just want text
% results = mediation_brain(X_hj, Y_hj, M_hj,SETUP);
% results = mediation_brain(X, Y, M,'names',names,'mask', mask,'boot','pvals',5, 'bootsamples', 10);
mediation_brain_multilevel(X, Y, M, SETUP, 'nopreproc')

SETUP = mediation_brain_corrected_threshold('fdr');




