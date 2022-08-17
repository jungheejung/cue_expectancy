function s06_l2normniftis(task, event)


script_single_dir = pwd;
main_dir = fileparts(fileparts(script_single_dir)); % /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social
singletrial_dir = fullfile(main_dir, 'analysis/fmri/spm/multivariate_24dofcsd');
% 
% sublist = [6,7,8,9,10,11,13,14,15,16,17,18,20,21,23,24,28,29,30,31,32,33,35,37,43,47,51,53,55,58,60,61,62,64,65,66,68,69,70,71,73,74,75,76,77,78,79,80,81,84,85];
%task = {'cognitive', 'vicarious', 'pain'};
%event = {'cue', 'stim'};
task = char(task);
event = char(event);
%event = {'cue', 'stim'};
glob_sub = dir(fullfile(singletrial_dir, 's03_concatnifti', '*', strcat('*_task-social_run-', task, '_ev-', event,'.nii')));
nT = struct2table(glob_sub); % convert the struct array to a table
sortedT = sortrows(nT, 'name'); % sort the table by 'DOB'
sortedT.sub_num(:) = str2double(extractBetween(sortedT.name, 'sub-', '_'));
for s = 1:size(sortedT,1)
    if ~isempty(sortedT)
        sub = strcat('sub-', sprintf('%04d', sortedT.sub_num(s)));
        nifti = fmri_data(char(fullfile(sortedT.folder(s), sortedT.name(s))));
        imgs2 = nifti.rescale('l2norm_images');
        save_fname = fullfile(singletrial_dir, 's03_concatnifti', sub, strcat(sub, '_task-social_run-', task, '_ev-', event, '_l2norm.nii'));
        write(imgs2, 'fname', save_fname );
    end
end
end
