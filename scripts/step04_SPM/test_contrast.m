main_dir = '/Users/h/Documents/projects_local/social_influence_analysis/data/dartmouth/preprocessed/';
sub = 'sub-0006';
filelist = dir(fullfile(main_dir, sub, '*/*_beh.csv'));
T = struct2table(filelist); % convert the struct array to a table
sortedT = sortrows(T, 'name'); % sort the table by 'DOB'
fmri_dir = fullfile(main_dir,'analysis', 'fmri', 'glm', 'model-01_CcEScaA', '1stLevel', strcat('sub-', sprintf('%02d', sub)));
motion_txt = fullfile();
if ~exist(fmri_dir, 'dir')
    mkdir(fmri_dir)
end

contrast1 = []; contrast2 = []; contrast3 = []; contrast4 = [];
%ses_str =  strcat('ses-',  sprintf('%02d', ses_num));
keySet = {'pain','vicarious','cognitive'};
con1 = [2 -1 -1];
con2 = [-1 2 -1];
con3 = [-1 -1 2];
con4 = [1 1 1];
m1 = containers.Map(keySet,con1);
m2 = containers.Map(keySet,con2);
m3 = containers.Map(keySet,con3);
m4 = containers.Map(keySet,con4);

for run_ind = 1:size(sortedT,1)
    csv_fname = fullfile(char(sortedT.folder(run_ind)), char(sortedT.name(run_ind)));
    keyword = extractBetween(sortedT.name(run_ind), 'run-0', '_beh.csv');
    task = char(extractAfter(keyword, '-'));
    contrast1 = [ contrast1  m1(task)];
    contrast2 = [ contrast2  m2(task)];
    contrast3 = [ contrast3  m3(task)];
    contrast4 = [ contrast4  m4(task)];
end