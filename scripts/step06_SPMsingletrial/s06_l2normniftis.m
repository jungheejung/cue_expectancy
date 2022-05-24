function s06_l2normniftis(task, event)


script_single_dir = pwd;
main_dir = fileparts(fileparts(script_single_dir)); % /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social
singletrial_dir = fullfile(main_dir, 'analysis/fmri/spm/multivariate');
% 
sublist = [6,7,8,9,10,11,13,14,15,16,17,18,20,21,23,24,28,29,30,31,32,33,35,37,43,47,51,53,55,58,60,61,62,64,65,66,68,69,70,71,73,74,75,76,77,78,79,80,81,84,85];
%task = {'cognitive', 'vicarious', 'pain'};
%event = {'cue', 'stim'};
task = char(task)
event = char(event)
event = {'cue', 'stim'};
for s = 1:length(sublist)
    task = 'pain'; event = 'stim'
    sub = strcat('sub-', sprintf('%04d', sublist(s)));
    a = dir(fullfile(singletrial_dir, 's03_concatnifti', sub, strcat(sub, '_task-social_run-', task, '_ev-', event,'.nii')));
    if ~isempty(a)
        cog_cue = fmri_data(fullfile(a.folder, a.name));
        imgs2 = cog_cue.rescale('l2norm_images');
        save_fname = fullfile(singletrial_dir, 's03_concatnifti', sub, strcat(sub, '_task-social_run-', task, '_ev-', event, '_l2norm.nii'));
        write(imgs2, 'fname', save_fname );
    end
end
end
