%% load data
PE = beh...
singletrial = fmri_data();
gray_mask = fmri_mask_image('gray_matter_mask.img');
singletrial = singletrial.apply_mask(gray_mask);
%% group cv
[~,~,subject_id] = unique(singletrial.metadata_table.subject_id,'stable');
uniq_subject_id = unique(subject_id);
n_subj = length(uniq_subject_id);

kfolds = 10;
cv = cvpartition2(ones(size(singletrial.dat,2),1), 'KFOLD', kfolds, 'Stratify', subject_id);

[I,J] = find([cv.test(1),cv.test(2), cv.test(3), cv.test(4), cv.test(5)]);
fold_labels = sortrows([I,J]);
fold_labels = fold_labels(:,2);

%% pcr
[pcr_cverr, pcr_stats, pcr_optout] = bmrk5pain.predict('algorithm_name','cv_pcr',...
    'nfolds',fold_labels, 'error_type', 'mse', ...
    'numcomponents', 10);
fprintf('PCR r = %0.3f\n', corr(pcr_stats.yfit, bmrk5pain.Y));

figure
line_plot_multisubject(bmrk5pain.Y, pcr_stats.yfit, 'subjid', subject_id);
xlabel({'Observed Pain','(stim level average)'}); ylabel({'PCR Estimated Pain','(cross validated)'})

pcr_model = bmrk5pain.get_wh_image(1);
pcr_model.dat = pcr_optout{1}(:);
figure;
pcr_model.montage;

%% lineplot
figure
subplot(1,2,1)
line_plot_multisubject(pcr_stats.yfit, mlpcr_stats.yfit, 'subjid', subject_id);
xlabel({'PCR model prediction'}); ylabel('Multilevel PCR model prediction');
axis square
subplot(1,2,2);
plot(pcr_optout{1}(:),mlpcr_optout{1}(:),'.');
lsline;
xlabel('PCR model weights'); ylabel('Multilevel PCR model weights');
axis square