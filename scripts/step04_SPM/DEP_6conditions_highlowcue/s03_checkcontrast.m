% The purpose of this script is to find where the "cue" or "cue-high_stim-high" keyword exists 
% and find it in the contrast list. 

% load SPM for every participant
% firstlevel_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/spm/univariate/model01_6cond_highlowcue/1stLevel';
firstlevel_dir = '/dartfs-hpc/scratch/f0042x1/spm/model01_6cond_highlowcue'
list = dir(firstlevel_dir);
sub_dir = regexp({list.name}, 'sub-\d{4}', 'match');
sub_list = sub_dir(~cellfun(@isempty, sub_dir));


for sub = 1:length(sub_list)
    flag = [];
    disp(sub_list{sub});
    
    try
        load(fullfile(firstlevel_dir, char(sub_list{sub}), 'SPM.mat'));
        
        % SPM constructed regressor list
        descrip = find(contains({SPM.Vbeta.descrip}, 'cue-high_stim-high')==1);
        
        % SPM contrast list
        contrast = find(SPM.xCon(1).c)';
        
        % if not equal, flag participant list
        if ~all(ismember(descrip, contrast))
            flag = [flag; char(sub_list{sub})];
        end
        
        clear SPM
        
        save_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/scripts/step04_SPM/6conditions_highlowcue';
        save_fname = fullfile(save_dir, strcat('s03_checkcontrast_', sub_list{sub}{1}, '_', datetime('now','Format','MM-dd-yyyy'), '.txt'));
        fid = fopen(save_fname,'w');    % open file for writing (overwrite if necessary)
        fprintf(fid,'%s',flag);          % Write the char array, interpret newline as new line
        fclose(fid);
    
    catch errorInfo
        disp(['Error loading SPM.mat for subject: ', char(sub_list{sub})]);
        disp(errorInfo.message);  % Display error message
        continue;  % Skip to the next iteration of the loop
    end
end


% for sub = 1:length(sub_list)
%     flag = [];
%     disp(sub_list{sub});
    
%     try
%         load(fullfile(firstlevel_dir, char(sub_list{sub}), 'SPM.mat'));
        
%         % SPM constructed regressor list
%         descrip = find(contains({SPM.Vbeta.descrip}, 'cue-high_stim-high')==1);
        
%         % SPM contrast list
%         contrast = find(SPM.xCon(1).c)';
        
%         % if not equal, flag participant list
%         if ~all(ismember(descrip, contrast))
%             flag = [flag; char(sub_list{sub})];
%         end
        
%         clear SPM
        
%         save_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/scripts/step04_SPM/6conditions';
        
%         % Check if the directory exists
%         if ~exist(save_dir, 'dir')
%             mkdir(save_dir);  % Create the directory if it doesn't exist
%         end
        
%         % Create the filename
%         save_fname = fullfile(save_dir, strcat('s03_checkcontrast_', sub_list{sub}{1}, '_', datetime('now','Format','MM-dd-yyyy'), '.txt'));
        
%         % Attempt to open the file for writing
%         fid = fopen(save_fname,'w');
        
%         % Check if the file opened successfully
%         if fid == -1
%             error('Unable to open the file for writing.');
%         end
        
%         % Write the flag to the file
%         fprintf(fid,'%s',flag);
        
%         % Close the file
%         fclose(fid);
    
%     catch errorInfo
%         disp(['Error processing subject: ', char(sub_list{sub})]);
%         disp(errorInfo.message);  % Display error message
%         continue;  % Skip to the next iteration of the loop
%     end
% end


% for sub = 1:length(sub_list)
%     flag = []
%     disp(sub_list{sub});
    
%     load(fullfile(firstlevel_dir, char(sub_list{sub}), 'SPM.mat'));
%     % SPM constructed regressor list
%     descrip = find(contains({SPM.Vbeta.descrip}, 'cue-high_stim-high')==1);
%     % SPM contrast list
%     contrast = find(SPM.xCon(1).c)';
%     % if isequal(descrip, contrast);
%     if all(ismember(descrip, contrast));
%         continue
%     else
%     % if not equal, flag participant list
%         flag = [flag; char(sub_list{sub})];
%     end
%     clear SPM
%     save_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/scripts/step04_SPM/6conditions';
%     save_fname = fullfile(save_dir, strcat('s03_checkcontrast_', sub_list{sub}{1}, '_' datetime('now','Format','MM-dd-yyyy'), '.txt'));
%     fid = fopen(save_fname,'w');    % open file for writing (overwrite if necessary)
%     fprintf(fid,'%s',flag);          % Write the char array, interpret newline as new line
%     fclose(fid);   
% end

