function plot_pdm(input)

x_keyword = input.x_keyword;
m_keyword = input.m_keyword;
y_keyword = input.y_keyword;
main_dir = input.main_dir;
single_nii = input.single_nii;
sublist = input.sublist;
task = input.task;
iter = input.iter;
num_components = input.num_components;
dat_fname = input.dat_fpath
task_subfldr = input.task_subfldr;
alpha = input.alpha;
sig = input.sig;
save_dir = fullfile(main_dir, 'analysis/fmri/mediation/pdm');

% task_subfldr = fullfile(save_dir, strcat('task-',task,'_', x_keyword, '-', m_keyword,'-',y_keyword));
if not(exist(task_subfldr, 'dir'))
    mkdir(task_subfldr)
end

% dat_fname =  fullfile(task_subfldr, strcat('task-',task,'_PDM_', x_keyword, '-', m_keyword,'-',y_keyword, '_DAT.mat'));
load(dat_fname)

%% preprocess data (remove outliers, mismatch dimensions, nan trials)
% 1. remove outlier single trials based on mahalanobis distance
new_m = mm; new_x = xx; new_y = yy; new_outlier = outlier;
Xoutlier = cell( size(xx,1), 1);    Youtlier = cell( size(xx,1), 1);    Moutlier = cell( size(xx,1), 1);
for s = 1:length(outlier)
    disp(strcat("-------subject", num2str(s), "------"))
disp(strcat("current length is ", num2str(size(yy{s,1},1))))
Xoutlier{s,1} = xx{s,1}(~outlier{s,1},:) ;
Youtlier{s,1} = yy{s,1}(~outlier{s,1},:) ;
Moutlier{s,1} = mm{s,1}(:,~outlier{s,1}) ;
disp(strcat("after removing", num2str(s), "size is now ",num2str(size(Youtlier{s,1},1))))
end

% 2. check dimensions - some participants have mismatch in single trial brain data, and outcome ratings
remove_sub = [];
for s = 1:length(Youtlier)
    if ~isequal(size(Moutlier{s},2), size(Youtlier{s},1))
        remove_sub = [remove_sub ;s];
    end
end

for s = 1:length(remove_sub)
    disp('-------------------------------------------')
    disp(strcat(sublist(s), 'is odd, dimensions dont match. removing for now'))
    disp('-------------------------------------------')
end

if ~isempty(remove_sub)
    Xoutlier(remove_sub) = [];    Youtlier(remove_sub) = [];    Moutlier(remove_sub) = []; sublist(remove_sub) = [];
end
disp('SIZE -------------')
disp(size(Xoutlier));    disp(size(Moutlier));    disp(size(Youtlier));

% 3. remove nan trials
X = cell( size(Xoutlier,1), 1);    Y = cell( size(Xoutlier,1), 1);    M = cell( size(Xoutlier,1), 1);
% TODO: Use this method?
for s = 1:length(Youtlier)
idx_nan = [];
idx_nan = ~isnan(Youtlier{s});
Y{s} = Youtlier{s}(idx_nan,:);
M{s} = Moutlier{s}(:,idx_nan');
X{s} = Xoutlier{s}(idx_nan,:);
end

% TODO: Use this method?
for s = 1:length(Youtlier)
    idx_nan = [];
    idx_nan = find(~Youtlier{s});
    Y{s} = Youtlier{s}(idx_nan,:);
    M{s} = Moutlier{s}(:,idx_nan');
    X{s} = Xoutlier{s}(idx_nan,:);
    end

disp(strcat('ultimate subject list: ', sublist))

%% Reduce the dimensionality of the brain-mediator data using PVD
pdmX = X; pdmY= Y; pdmM = M;
min_comp = min(cellfun('size',pdmY,1));
if min_comp < 25
min_comp = min_comp;
else
min_comp = 25;
end
% project onto lower dimensional space keeping th max number of components
pdm_min = multivariateMediation(pdmX,pdmY,pdmM,'noPDMestimation','B',min_comp);
save_fname = fullfile(task_subfldr, strcat('task-',task, '_PDM-mincomp_', x_keyword, '-', m_keyword,'-',y_keyword,'.mat'));
save(save_fname,'pdm_min');

%% Compute the multivariate brain mediators
% use previous PVD dimension reduction, compute PDMs, and plot path coeff
pdm = multivariateMediation(pdm_min,'nPDM', min_comp, 'plots');
save_fname = fullfile(task_subfldr, strcat('task-',task, '_PDM-plot_', x_keyword, '-', m_keyword,'-',y_keyword,'.mat'));
save(save_fname,'pdm');
% select the number of PDMs (3) based on the |ab| coeff plot, like a scree-plot
% pdm = multivariateMediation(pdm,'nPDM',3);

%% bootstrap voxel weights for significance
% bootstrap the first 3 PDM with 100 samples
save_fname = fullfile(task_subfldr, strcat('task-',task, '_PDM-bootstrap_',  x_keyword, '-', m_keyword,'-',y_keyword,'.mat'));
pdm_boot = multivariateMediation(pdmX,pdmY,pdmM,...
'B',num_components,'nPDM',num_components,'bootPDM',1:num_components,...
'bootjPDM','Bsamp',iter,'plots','save2file',save_fname);
%% plot
dat = fmri_data(single_nii);
[obj,figh] = plotPDM(pdm_boot,dat);

end
