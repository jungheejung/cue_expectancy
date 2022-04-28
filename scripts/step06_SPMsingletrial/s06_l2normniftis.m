function s06_l2normniftis(task, event)
singletrial_dir = '/Volumes/spacetop_projects_social/analysis/fmri/spm/multivariate/';
sublist = [6,7,8,9,10,11,13,14,15,16,17,18,20,21,23,24,28,29,30,31,32,33,35,37,43,47,51,53,55,58,60,61,62,64,65,66,68,69,70,71,73,74,75,76,77,78,79,80,81,84,85];
task = {'cognitive', 'vicarious', 'pain'};
event = {'cue', 'stim'};
for s = 1:length(sublist)
sub = strcat('sub-', sprintf('%04d', sublist(s)));
task = 'pain'
event = 'cue'
cog_cue = fmri_data(fullfile(singletrial_dir, 's03_concatnifti', sub, strcat(sub, '_task-social_run-', task, '_ev-', event,'.nii')));
imgs2 = cog_cue.rescale('l2norm_images');
save_fname = fullfile(singletrial_dir, 's03_concatnifti', sub, strcat(sub, '_task-social_run-', task, '_ev-', event, '_l2norm.nii'));
write(imgs2, 'fname', save_fname );
end
end
