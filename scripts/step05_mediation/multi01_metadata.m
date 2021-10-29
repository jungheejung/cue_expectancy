% TODO:
% 1. grab stacked nifti
% 2. based on nifti filename text file, grab corresponding behavioral data
% 3. save metadata into .csv file via table
% 4. run CANlab mediation


% directories _________________
% nifti_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/analysis/fmri/fsl/multivariate/isolate_nifti';
script_mediation_dir = pwd;
main_dir = fileparts(fileparts(script_mediation_dir)); % /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social
nifti_dir = fullfile(main_dir, 'analysis','fmri','fsl','multivariate','concat_nifti');
sublist = [2,3,4,5,6,7,8,9,10,14,15,16,18,19,20,21,23,24,25,26,28,29,30,31,32,33,35];%, 19];%,26];
eventlist = {'cue', 'stim'}
% step 01 __________________________________________________________________

% grab stacked nifti
for e = 1:length(eventlist)
for s = 1:length(sublist)
    disp(strcat('starting ', strcat('sub-',sprintf('%04d', sublist(s)))))
    simpleP_t = dir(fullfile(nifti_dir, strcat('sub-',sprintf('%04d', sublist(s)) ),...
    strcat('sub-', sprintf('%04d', sublist(s)), '_task-*_ev-',char(eventlist(e)),'.nii.gz')   ));
    % strcat('sub-', sprintf('%04d', sublist(s)), '_task-*_ev-',eventlist(e),'.nii.gz') ));
    simpleP_fldr = {simpleP_t.folder}; fname = {simpleP_t.name};
    simpleP_files = strcat(simpleP_fldr,'/', fname)';

    % filename='/Users/h/Documents/projects_local/social_influence_analysis/niftifname_sub-0025_task-cognitive_ev-cue.txt';

    for f = 1: length(simpleP_files)
        [filepath,name,ext] = fileparts(simpleP_files{f});
        parsef = split(name,'_');
        event = split(parsef{3}, '.');

        % corresponding nifti text
        nifti_fname = strcat('niftifname_', parsef{1}, '_', parsef{2}, '_', event{1}, '.txt');
            
        nifti_fdir = fullfile(nifti_dir, strcat('sub-',sprintf('%04d', sublist(s)) ));
        fid = fopen(fullfile(nifti_fdir, nifti_fname),'r');
        start_row = 1;
        nifti_list= textscan(fid, '%s', 'Delimiter', '', 'WhiteSpace', '', 'HeaderLines' ,start_row-1, 'ReturnOnError', false);
        fclose(fid);


        % unzip via spm
        % step 02 __________________________________________________________________
        % based on nifti filename text file, grab corresponding behavioral data
        cue_contrast = []; stim_contrast = []; expect_rating = []; actual_rating = [];
        for n = 1: length(nifti_list{1})
            nifti_list{1}{n}
            A = regexp( nifti_list{1}{n}, '\<0*[+]?\d+\.?\d', 'match' );
            % sub_num   = strcat('sub-', A{1});
            % ses_num   = str2num(A{2});
            % run_num   = str2num(A{3});
            trial = str2num(A{4});

            table_dir = fullfile(main_dir,'data','dartmouth','d02_preprocessed');
            csv_fname = dir(fullfile(table_dir,...
                strcat('sub-', A{1}),...
                strcat('ses-', A{2}),...
                strcat('sub-', A{1}, '_ses-', A{2}, '_task-social_run-', A{3}, '*.csv') ));
            T = readtable(fullfile(csv_fname.folder, csv_fname.name));
                    
            % grab cue type info, append to dataframe
            if strcmpi(char(T.param_cue_type(trial+1)), 'low_cue')
                cue_contrast = [cue_contrast ; -1];
            elseif strcmpi(char(T.param_cue_type(trial+1)), 'high_cue')
                cue_contrast = [cue_contrast ; 1];
            end
            
	    if strcmpi(char(T.param_stimulus_type(trial+1)), 'low_stim')
                stim_contrast = [stim_contrast ; 48];
            elseif strcmpi(char(T.param_stimulus_type(trial+1)), 'med_stim')
                stim_contrast = [stim_contrast ; 49];
            elseif strcmpi(char(T.param_stimulus_type(trial+1)), 'high_stim')
                stim_contrast = [stim_contrast ; 50];
            end

            actual_rating = [actual_rating; T.event04_actual_angle(trial+1)];
            expect_rating = [expect_rating; T.event02_expect_angle(trial+1)];
            
            
        end
        % step 03 __________________________________________________________________
        %  save as csv - set table parameters
        vnames = {'trial','cue','stim','expect_rating','actual_rating','nii_filename'};
        vtypes = {'double','double','string','double','double','string'}
        F = table('Size',[size(nifti_list{1},1), size(vnames,2)],'VariableNames',vnames,'VariableTypes',vtypes);
        F.trial = [1:length(nifti_list{1})]';
        F.cue = cue_contrast;
        F.stim = stim_contrast;
        F.expect_rating = expect_rating;
        F.actual_rating = actual_rating;
        F.nii_filename = nifti_list{1};
        F.nii_filename = eraseBetween(F.nii_filename, 1,2); % remove the './ from the filenames'
        save_tablename = strcat('metadata_', parsef{1}, '_', parsef{2}, '_', event{1}, '.csv')
        writetable(F,fullfile(nifti_fdir, save_tablename));

% step 04 __________________________________________________________________
    end
end
end
