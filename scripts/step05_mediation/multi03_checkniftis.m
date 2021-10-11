% TODO:
save_dir = '/Volumes/social/analysis/fmri/fsl/multivariate/nifti_metrics'
% load images per subject 
sublist = [2,3,4,6,7,...
8,9,10,18,19,...
20,23,25,26,28,29];%, 19];%,26];
% load images __________________________________________________________________

dirname = '/Volumes/social/analysis/fmri/fsl/multivariate/isolate_nifti/'
for s = 1:length(sublist)
sub = strcat('sub-',sprintf('%04d', sublist(s)));
% sub-0010_ses-03_run-01-vicarious_ev-cue-0000.nii.gz 
images = filenames(fullfile(dirname, sub, '*ses*cue*nii.gz'))
% images = filenames([dirname filesep '*ses*cue*nii.gz'])
dat = fmri_data(images);


% save images __________________________________________________________________
% filename1 = fullfile(save_dir, strcat(sub, '_montage.png'))
% saveas(gcf,filename1)
plot(dat);
snapnow
filename2 = fullfile(save_dir, strcat(sub, '_maldist.png'))
exportgraphics(gcf,filename2,'Resolution',300)

close all;

end