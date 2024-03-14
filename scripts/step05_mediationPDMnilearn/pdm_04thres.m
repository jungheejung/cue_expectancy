% load single trial analysis from SPM
% insert volumne info
% save as nifti file
A.dat = out.Wfull{1,1} .* (out.boot.p{1,1} > 0.05);
A.volInfo = S.volInfo;
write(A, 'fname', '/Users/h/Dropbox/projects_dropbox/social_influence_analysis/figure/ohbm/tst_save.nii')