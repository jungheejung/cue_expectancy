% VIF
t = readtable('/Users/h/Dropbox (Dartmouth College)/projects_dropbox/d_beh/sub-0078/task-social/ses-01/sub-0078_ses-01_task-social_run-05-pain_beh');
h_stim = t(ismember(t.param_stimulus_type, 'high_stim'),:);
l_stim = t(ismember(t.param_stimulus_type, 'low_stim'),:);
m_stim = t(ismember(t.param_stimulus_type, 'med_stim'),:);


m_stim = t;
onset01_cue = m_stim.event01_cue_onset - m_stim.param_trigger_onset;
onset02_expect = m_stim.event02_expect_displayonset - m_stim.param_trigger_onset;
onset03_stim = m_stim.event03_stimulus_displayonset - m_stim.param_trigger_onset;
onset04_actual = m_stim.event04_actual_responseonset - m_stim.param_trigger_onset;
TR = 0.46;
len = 872;
onset_cell = {onset01_cue onset02_expect onset03_stim onset04_actual };
%plotDesign(onset_cell, 5, 0.46)
%% separate plot:

%subplot(1,3,1);grid on;
figure
X = onsets2fmridesign(onset_cell, TR, 872 .* TR, spm_hrf(1));
plotDesign(onset_cell,[], TR);
ax1= gca;
%subplot(1,3,2); grid on;
figure
create_figure("heat_map")
imagesc(corr(plotdesignout));
ax2= gca;

%subplot 3
figure
create_figure("vifs")
vifs = getvif(X, false, 'plot');
ax3 = gca;

%%
fnew = figure;
ax1_copy = copyobj(ax1,fnew);
subplot(1,3,1,ax1_copy)

copies = copyobj(ax2,fnew);
ax2_copy = copies(1);
subplot(1,3,2,ax2_copy)

copies2 = copyobj(ax3,fnew);
ax3_copy = copies2(1);
subplot(1,3,3,ax3_copy)

%X = onsets2fmridesign({[0 30 60]' [15 45 90]'}, 1.5, 180, spm_hrf(1), 'parametric_standard', {[2 .5 1]' [1 2 2.5]'}); figure; plot(X)
