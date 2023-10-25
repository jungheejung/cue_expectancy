% The purpose of this script is to find where the "cue" keyword exists 
% and find it in the contrast list. 

% load SPM for every participant
firstlevel_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/spm/univariate/model01_6cond_ttl1';
firstlevel_dir= '/dartfs-hpc/scratch/f0042x1/spm/model01_6cond_ttl1';
list = dir(firstlevel_dir);
sub_dir = regexp({list.name}, 'sub-\d{4}', 'match');
sub_list = sub_dir(~cellfun(@isempty, sub_dir));

flag = [];

for sub = 1:length(sub_list)
    load(fullfile(firstlevel_dir, char(sub_list{sub}), 'SPM.mat'));
    % SPM constructed regressor list
    descrip = find(contains({SPM.Vbeta.descrip}, 'CUE')==1);
    % SPM contrast list
    contrast = find(SPM.xCon(1).c)';
    if isequal(descrip, contrast);
        continue
    else
    % if not equal, flag participant list
        flag = [flag; char(sub_list{sub})];
    end
    clear SPM
end

save_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/scripts/step04_SPM/6conditions';
currentDate = datetime('now','Format','MM-dd-yyyy').string();
save_fname = fullfile(save_dir, "s03_checkcontrast_" + currentDate + ".txt");

save_fname = fullfile(save_dir, strcat('s03_checkcontrast_', string(datetime('now', 'Format', 'MM-dd-yyyy')), '.txt'));
fid = fopen(save_fname,'w');    % open file for writing (overwrite if necessary)
fprintf(fid,'%s',flag);          % Write the char array, interpret newline as new line
fclose(fid);   
