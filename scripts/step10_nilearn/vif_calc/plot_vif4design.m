function plot_vif4design()
input.main_dir = '/Volumes/spacetop_projects_cue';
input.glm_dir = fullfile(input.main_dir, '/analysis/fmri/spm/univariate/model01_6cond/1stLevel');
input.glm_modelname = "6conditions";
input.smooth_dir = fullfile(input.main_dir,"/analysis/fmri/smooth6mm");
input.fmriprep_dir = "/Volumes/fmriprep/results/fmriprep";
input.output_dir = fullfile(input.main_dir, '/analysis/fmri/spm/univariate/model01_6cond/vif');
input.sub_id = 'sub-0061';


%vif_calc(input);


main_dir = input.main_dir;
glm_dir = input.glm_dir;
glm_modelname = input.glm_modelname;
fmriprep_dir = input.fmriprep_dir;
smooth_dir = input.smooth_dir;
output_dir = fullfile(input.output_dir, input.sub_id);

if not(exist(input.output_dir, 'dir'))
    mkdir(input.output_dir)
end
sub = input.sub_id;
disp(strcat("vif_calc:", sub));

%% 3. VIF per run _______________________________________________________
% identify how many runs in SPM
    % find nifti files
    niilist = dir(fullfile(smooth_dir, sub, '*/smooth-6mm_*task-cue*_bold.nii'));
    nT = struct2table(niilist); % convert the struct array to a table
    sortedT = sortrows(nT, 'name'); % sort the table by 'DOB'

    sortedT.sub_num(:) = str2double(extractBetween(sortedT.name, 'sub-', '_'));
    sortedT.ses_num(:) = str2double(extractBetween(sortedT.name, 'ses-', '_'));
    sortedT.run_num(:) = str2double(extractBetween(sortedT.name, 'run-', '_'));

    nii_col_names = sortedT.Properties.VariableNames;
    nii_num_colomn = nii_col_names(endsWith(nii_col_names, '_num'));
    onset_dir = fullfile(main_dir, 'data', 'fmri', 'fmri01_onset', 'onset02_SPM');
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


    for run_ind = 1:size(A, 1)

        sub = []; ses = []; run = [];
        sub = strcat('sub-', sprintf('%04d', A.sub_num(run_ind)));
        ses = strcat('ses-', sprintf('%02d', A.ses_num(run_ind)));
        run = strcat('run-', sprintf('%01d', A.run_num(run_ind)));

        %t = readtable('/Users/h/Dropbox (Dartmouth College)/projects_dropbox/d_beh/sub-0078/task-social/ses-01/sub-0078_ses-01_task-social_run-05-pain_beh');
        % h_stim = t(ismember(t.param_stimulus_type, 'high_stim'),:);
        % l_stim = t(ismember(t.param_stimulus_type, 'low_stim'),:);
        % m_stim = t(ismember(t.param_stimulus_type, 'med_stim'),:);
        onset_glob = dir(fullfile(onset_dir, sub, ses, strcat(sub, '_', ses, '_task-cue_', strcat('run-', sprintf('%02d', A.run_num(run_ind))), '*_events.tsv')));
        onset_fname = fullfile(char(onset_glob.folder), char(onset_glob.name));
        t = readtable(onset_fname, 'FileType','text');

%         onset01_cue = t.onset01_cue - t.param_trigger_onset;
%         onset02_expect = t.event02_expect_displayonset - t.param_trigger_onset;
%         onset03_stim = t.event03_stimulus_displayonset - t.param_trigger_onset;
%         onset04_actual = t.event04_actual_responseonset - t.param_trigger_onset;
        TR = 0.46;
        len = 872;
        onset_cell = {t.onset01_cue t.onset02_ratingexpect t.onset03_stim t.onset04_ratingoutcome };
        %plotDesign(onset_cell, 5, 0.46)
        %% separate plot:

        % subplot(1,3,1);grid on;
        figure('visible','off')
        X = onsets2fmridesign(onset_cell, TR, 872 .* TR, spm_hrf(1));
        plotdesignout = plotDesign(onset_cell,[], TR);
        pbaspect([1 1 1])
        ax1= gca;
        set(figure, 'visible', 'off')
        ax1.FontSize = 16; 
        % subplot(1,3,2); grid on;
        figure('visible','off')
        create_figure("heat_map")
        imagesc(corr(plotdesignout));
        pbaspect([1 1 1])
        ax2= gca;
        set(figure, 'visible', 'off')
        ax2.FontSize = 16; 
        % subplot(1,3,2)
        figure('visible','off')
        create_figure("vifs")
        vifs = getvif(X, false, 'plot');
        pbaspect([1 1 1])
        ax3 = gca;
        set(figure, 'visible', 'off')
        ax3.FontSize = 16; 

        %%
        %set(0,'DefaultFigureVisible','on')
        fnew = figure('Position', [10 10 900 400], 'visible', 'on');

        %axis tight; axis image; 
        ax1_copy = copyobj(ax1,fnew);
        subplot(1,3,1,ax1_copy)

        copies = copyobj(ax2,fnew);
        ax2_copy = copies(1);
        subplot(1,3,2,ax2_copy)

        copies2 = copyobj(ax3,fnew);
        ax3_copy = copies2(1);
        subplot(1,3,3,ax3_copy)

        sgtitle(strcat(sub, ses, run));
        set(fnew, 'visible', 'on')
        set(figure, 'visible', 'on')
        close all;

    end
end