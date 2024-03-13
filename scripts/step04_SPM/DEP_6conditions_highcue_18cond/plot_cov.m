function plot_cov(filteredcon_files, covariate_name)
% covariate_name = 'cuestim_z_outcome';
filtered_con_obj = fmri_data(filteredcon_files);
filtered_con_obj.X = filtered_pain_cueeffect.(covariate_name);

out = regress(filtered_con_obj);

m = mean(filtered_con_obj);
m.dat = sum(~isnan(filtered_con_obj.dat) & filtered_con_obj.dat ~= 0, 2);
orthviews(m, 'trans') % display

% Pain > baseline :: Plot diagnostics, before l2norm
drawnow; snapnow
[wh_outlier_uncorr, wh_outlier_corr] = plot(filtered_con_obj);
set(gcf,'Visible','on')
figure ('Visible', 'on');
drawnow, snapnow;
con = filtered_con_obj;
disp(strcat("current length is ", num2str(size(filtered_con_obj.dat,2))))
%for s = 1:length(wh_outlier_corr)
    %disp(strcat("-------subject", num2str(s), "------"))
con.dat = filtered_con_obj.dat(:,~wh_outlier_corr);
con.image_names = filtered_con_obj.image_names(~wh_outlier_corr,:)
con.fullpath = filtered_con_obj.fullpath(~wh_outlier_corr,:)
con.files_exist = filtered_con_obj.files_exist(~wh_outlier_corr,:)
%end
disp(strcat("after removing ", num2str(sum(wh_outlier_corr)), " participants, size is now ",num2str(size(con.dat,2))))

% plot diagnostics after l2norm
imgs2 = con.rescale('l2norm_images');

%
t = ttest(imgs2);
orthviews(t);
drawnow, snapnow;

fdr_t05 = threshold(t, .05, 'fdr');
orthviews(fdr_t05);
drawnow, snapnow;
fdr_t05.dat = fdr_t05.dat.*fdr_t05.sig;
%write(fdr_t05, 'fname', fullfile(nifti_save_dir, strcat(nifti_save_fname_prefix, contrast_of_interest, '_fdr-05.nii')), 'overwrite');

fdr_t001 = threshold(t, .001, 'fdr');
orthviews(fdr_t001);
drawnow, snapnow;
fdr_t001.dat = fdr_t001.dat.*fdr_t001.sig;
%write(fdr_t001, 'fname', fullfile(nifti_save_dir, strcat(nifti_save_fname_prefix, contrast_of_interest, '_fdr-001.nii')), 'overwrite');

create_figure('montage'); axis off;
montage(fdr_t001);
drawnow, snapnow;

[image_by_feature_correlations, top_feature_tables] = neurosynth_feature_labels( mean(imgs2), 'images_are_replicates', false, 'noverbose');


% Phil tripartite marker
[obj, names] = load_image_set('pain_cog_emo');
bpls_wholebrain = get_wh_image(obj, [8 16 24]);
names_wholebrain = names([8 16 24]);
create_figure('Kragel Pain-Cog-Emo maps', 1, 3);

stats = image_similarity_plot(con_data_obj, 'average', 'mapset', bpls_wholebrain, 'networknames', names_wholebrain, 'nofigure');
axis image

subplot(1, 3, 2)

barplot_columns(stats.r', 'nofigure', 'colors', {[1 .9 0] [.2 .2 1] [1 .2 .2]}, 'names', names_wholebrain)
set(gca, 'FontSize', 14)
ylabel('Pattern similarity (r)');
title('Similarity (r) with patterns')

test_data_obj = resample_space(con_data_obj, bpls_wholebrain);

clear csim
for i = 1:3

    csim(:, i) = canlab_pattern_similarity(test_data_obj.dat, bpls_wholebrain.dat(:, i), 'cosine_similarity');

end

subplot(1, 3, 3)

barplot_columns(csim, 'nofigure', 'colors', {[1 .9 0] [.2 .2 1] [1 .2 .2]}, 'names', names_wholebrain)
set(gca, 'FontSize', 14)
ylabel('Pattern similarity (cosine sim)');
title('Pattern response (cosine similarity)')

end