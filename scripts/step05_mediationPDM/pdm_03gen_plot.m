function pdm_03gen_plot(input)

x_keyword = input.x_keyword;
m_keyword = input.m_keyword;
y_keyword = input.y_keyword;
main_dir = input.main_dir;
single_nii = input.single_nii;
sublist = input.sublist;
task = input.task;
iter = input.iter;
num_components = input.num_components;

save_dir = fullfile(main_dir, 'analysis/fmri/mediation/pdm');

task_subfldr = fullfile(save_dir, strcat('task-',task,'_', x_keyword, '-', m_keyword,'-',y_keyword));
if not(exist(task_subfldr, 'dir'))
    mkdir(task_subfldr)
end

dat_fname =  fullfile(task_subfldr, strcat('task-',task,'_PDM_', x_keyword, '-', m_keyword,'-',y_keyword, '_DAT.mat'));
load(dat_fname)
new_m = mm; new_x = xx; new_y = yy;

%% check dimensions and remove nans
remove_sub = [];
for s = 1:length(new_y)
    if ~isequal(size(new_m{s},2), size(new_y{s},1))
        remove_sub = [remove_sub ;s];
    end
end

for s = 1:length(remove_sub)
    disp('-------------------------------------------')
    disp(strcat(sublist(s), 'is odd, dimensions dont match. removing for now'))
    disp('-------------------------------------------')
end

if ~isempty(remove_sub)
new_x(remove_sub) = [];    new_y(remove_sub) = [];    new_m(remove_sub) = [];
end
disp('SIZE -------------')
disp(size(new_x));    disp(size(new_m));    disp(size(new_y));
X = cell( size(new_x,1), 1);    Y = cell( size(new_x,1), 1);    M = cell( size(new_x,1), 1);
for s = 1:length(new_y)
idx_nan = [];
idx_nan = ~isnan(new_y{s});
Y{s} = new_y{s}(idx_nan,:);
M{s} = new_m{s}(:,idx_nan');
X{s} = new_x{s}(idx_nan,:);
end

%% Reduce the dimensionality of the brain-mediator data using PVD
xx = X; yy= Y; mm = M;
min_comp = min(cellfun('size',yy,1))
% project onto lower dimensional space keeping th max number of components
pdm_min = multivariateMediation(xx,yy,mm,'noPDMestimation','B',min_comp);
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
pdm_boot = multivariateMediation(xx,yy,mm,'B',num_components,'nPDM',num_components,'bootPDM',1:num_components,'bootJPDM','Bsamp',iter,'save2file',save_fname);

%% plot
dat = fmri_data(single_nii);
[obj,figh] = plotPDM(pdm_boot,dat);

end
