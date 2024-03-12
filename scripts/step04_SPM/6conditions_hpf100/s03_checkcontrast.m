% load SPM for every participant
firstlevel_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/spm/univariate/model01_CESO/1stLevel';
list = dir(firstlevel_dir);
sub_dir = regexp({list.name}, 'sub-\d{4}', 'match');
sub_list = sub_dir(~cellfun(@isempty, sub_dir));

flag = []

for sub = 50:length(sub_list)
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

save_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/scripts/step04_SPM/CESO';
save_fname = fullfile(save_dir, strcat('s03_checkcontrast_', datetime('now','Format','MM-dd-yyyy'), '.txt'));
fid = fopen(save_fname,'w');    % open file for writing (overwrite if necessary)
fprintf(fid,'%s',flag);          % Write the char array, interpret newline as new line
fclose(fid);   