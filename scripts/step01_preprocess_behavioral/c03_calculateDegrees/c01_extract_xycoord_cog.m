
% """
% This code
% """
% __author__ = "Heejung Jung"
% __version__ = "1.0.1"
% __email__ = "heejung.jung@colorado.edu"
% __status__ = "Production"

% iteratively go through dataset and pull out last row
% filename example: sub-096_task-cognitive_beh_trajectory.mat
% variable name is "rating_Trajectory"

% sub = [1,2,3,4,5,6,7,8,9,10,11,12,15,16,19,25,26,27,28];%,96,97,99];
sub = [2,6,7,8,9,10,11,13,14,15,16,17,18,19,20,21,23,24,25,26,28,29,30,...
    31,32,33,34,35,36,37,38,39,40,41,43,44,46,47,50,51,52,53,55,56,57,58,59,60,...
    61,62,63,64,65,66,68,69,70,71,73,74,75,76,77,78,79,80,81,83,84,85,86,87,88,89,90,...
    91,92,93,94,95,97,98,99,100,101,102,103,104,105,106];

session = [1,3,4];
taskname = {'cognitive'};
for i = 1:length(sub)
    for ses = 1:length(session)
        for task = 1
            d01_behavioral_dir = fullfile('/Users/h/Dropbox/projects_dropbox/social_influence_analysis/data/dartmouth/d01_rawbeh/', ['sub-', sprintf('%04d', sub(i))], ['ses-', sprintf('%02d', session(ses))]);
            d02_behavioral_dir = fullfile('/Users/h/Dropbox/projects_dropbox/social_influence_analysis/data/dartmouth/d02_preprocessed/', ['sub-', sprintf('%04d', sub(i))], ['ses-', sprintf('%02d', session(ses))]);
            filename = dir(fullfile(d01_behavioral_dir, ['sub-',sprintf('%04d', sub(i)),'_ses-',sprintf('%02d', session(ses)),'_task-social*', taskname{task}, '*_trajectory.mat']));
            if ~isempty(filename)
                for block = 1:length(filename)
                    
                    load(fullfile(filename(block).folder,filename(block).name));
                    new_trajectory = zeros(size(rating_Trajectory,1),4);
                    % insert it into a csv file per participant?
                    for trl = 1:size(rating_Trajectory,1)
                        new_trajectory(trl,1:2) =  rating_Trajectory{trl,1}(end,:); % expect
                        new_trajectory(trl,3:4) =  rating_Trajectory{trl,2}(end,:); % actual
                    end
                    T = table(new_trajectory);
                    T2 = splitvars(T);
                    T2.Properties.VariableNames = {'expect_ptb_coord_x', 'expect_ptb_coord_y' , 'actual_ptb_coord_x',  'actual_ptb_coord_y'};
                    [a,strip_fname,ext] = fileparts(filename(block).name);
                    
                    if ~exist(d02_behavioral_dir, 'dir')
                        mkdir(d02_behavioral_dir)
                    end
                    saveFileName = fullfile(d02_behavioral_dir,strcat(strip_fname,'_formatted.csv') );
                    writetable(T2,saveFileName)
                    
                end
            else
                break
                
            end
        end
    end
end
