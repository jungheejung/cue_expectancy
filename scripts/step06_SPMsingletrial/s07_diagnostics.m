

addpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12'); 
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore')); 
main_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social';
concat_dir = fullfile(main_dir, 'analysis', 'fmri', 'spm', 'multivariate', 's03_concatnifti');
sublist = {'sub-0002','sub-0003','sub-0005',...
    'sub-0006','sub-0007','sub-0008','sub-0009','sub-0010',...
    'sub-0014','sub-0015','sub-0016','sub-0018' ,'sub-0019','sub-0020',...
    'sub-0021','sub-0023','sub-0024','sub-0025',...
    'sub-0026','sub-0028','sub-0029','sub-0030',...
    'sub-0031','sub-0032','sub-0033','sub-0035'};

sublist = [3,4,5,6,7,8,9,10,14,15,16,18,19,20,21,23,24,25,26,28,29,30,31,32,33,35,37,43,47,51,53,55,58,60];

tasklist = {'pain', 'vicarious', 'cognitive'};
eventlist = {'cue', 'stim'};
plot_dir = fullfile(main_dir, 'figure', 'spm_concat_nifti');
for s = 1:length(sublist)
    for t = 1:length(tasklist)
        for e = 1:length(eventlist)
            keyword = strcat('task-', tasklist(t), '_ev-', eventlist(e));
            if ~exist(fullfile(plot_dir, char(keyword)), 'dir')
                mkdir(fullfile(plot_dir, char(keyword)))
            end
            sub = strcat('sub-', sprintf('%04d', sublist(s)));
            disp(sub)
            
            S = fmri_data(fullfile(concat_dir, sub, strcat( sub, '_task-', tasklist(t), '_ev-', eventlist(e), '.nii')));
            plot(S);
            % findall(groot,'Type','figure')
            montage = findall( groot,'Type', 'Figure', 'Name', 'Orthviews_fmri_data_mean_and_std' );
            exportgraphics(montage,fullfile(plot_dir, char(keyword), strcat(sub, '_', char(keyword),'_01.png')));
            
            fh = findall( groot,'Type', 'Figure', 'Name', 'fmri data matrix' );
            exportgraphics(fh, fullfile(plot_dir, char(keyword), strcat( sub, '_',char(keyword),'_02.png')));
            
            close all

        end
    end
end

