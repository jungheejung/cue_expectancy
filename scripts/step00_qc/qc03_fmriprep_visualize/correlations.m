function s01_glm_6cond(sub)


D=dir(sprintf('/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop_data/derivatives/fmriprep/results/fmriprep/%s/ses-*/func/*task-social*MNI152NLin2009cAsym*',sub));

if ~isempty(D)
fnames={};
for j = 1:length(D)
fname=fullfile(D(j).folder, D(j).name);
fnames{j} = fname;
end
fnames = fnames';
runs = fmri_data(fnames);
cor = corr([runs.dat]);
img=imagesc(cor);
set(gca,'Ydir','normal');

title(sprintf('%s Correlations between the volumes of the runs from all the sessions - task:social',sub))
colorbar
saveas(img,sprintf('/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop_data/derivatives/fmriprep_qc/kodi_fmriprep_bold_correlation/%s.png',sub));
end
clear
end
