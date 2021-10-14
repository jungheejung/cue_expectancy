
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
sub = [3, 4];
taskname = {'cognitive', 'vicarious', 'pain'};
for i = 1:length(sub)
for task = 1:2
behavioral_dir = fullfile('/Users/h/Documents/projects_local/social_influence_analysis/dartmouth/rawbeh/', ['sub-', sprintf('%04d', sub(i))], '/beh/');
filename = fullfile(behavioral_dir, ['sub-',sprintf('%04d', sub(i)),'_task-', taskname{task}, '_beh_trajectory.mat']);
load(filename);
new_trajectory = zeros(size(rating_Trajectory,1),4);
% insert it into a csv file per participant?
for trl = 1:size(rating_Trajectory,1)
new_trajectory(trl,1:2) =  rating_Trajectory{trl,1}(end,:); % expect
new_trajectory(trl,3:4) =  rating_Trajectory{trl,2}(end,:); % actual
end
T = table(new_trajectory);
T2 = splitvars(T);
T2.Properties.VariableNames = {'expect_ptb_coord_x', 'expect_ptb_coord_y' , 'actual_ptb_coord_x',  'actual_ptb_coord_y'};
saveFileName = fullfile(behavioral_dir,[strcat('sub-', sprintf('%04d', sub(i))), '_task-',taskname{task},'_beh_trajectory_formatted.csv' ]);
writetable(T2,saveFileName)
end

end
