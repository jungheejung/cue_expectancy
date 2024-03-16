singletrial_pattern = '/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/singletrial/sub-0068/*stimintensity*.nii';
% TODO: need to load data per subject across all sessions. 
%
% fmri_data __________________________________________________________________
main_dir = '/Volumes/spacetop_projects_cue';
sub = 'sub-0068';
singletrial_flist = filenames('/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/singletrial/sub-0068/*stimintensity*.nii');
dat = fmri_data(singletrial_flist);
% behavioral data __________________________________________________________________
% /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/data/beh/beh03_bids/sub-0082/ses-03
% sub-0082_ses-03_task-cue_acq-mb8_run-05_events.tsv
beh_flist = filenames(fullfile(main_dir, 'data', 'beh', 'beh03_bids', sub, '*', strcat('*.tsv')));
concat_beh = table();
for i = 1:numel(beh_flist)
    % Load the TSV file
    beh_df = readtable(beh_flist{i}, 'Delimiter', ',', 'FileType', 'text');
    concat_beh = [concat_beh; beh_df];
end

% intersection of behavioral and fmri __________________________________________________________________
% Extract the basenames without file extension from concat_beh.singletrial_fname
basenames_concat_beh = cellfun(@(x) regexprep(x, '\.nii\.gz$', ''), concat_beh.singletrial_fname, 'UniformOutput', false);
basenames_concat_beh = strcat(basenames_concat_beh, '.nii');
[~, basenames_singletrial_flist, ext] = cellfun(@fileparts, singletrial_flist, 'UniformOutput', false);
basenames_singletrial_flist = strcat(basenames_singletrial_flist, ext);

% get intersection and select the identified rows
[~, idx_concat_beh, idx_singletrial_flist] = intersect(basenames_concat_beh, basenames_singletrial_flist);
subset_beh = concat_beh(idx_concat_beh, :);

%% doublecheck order __________________________________________________________________
% Extract the basenames from singletrial_flist
% Compare the basenames with singletrial_flist
[~, selected_basenames, ~] = cellfun(@fileparts, subset_beh.singletrial_fname, 'UniformOutput', false);
is_order_match = ismember(selected_basenames, basenames_singletrial_flist);

% Check if the order matches
if all(is_order_match)
    disp('The order of filenames in subset_beh matches the order in singletrial_flist.');
else
    disp('The order of filenames in subset_beh does not match the order in singletrial_flist.');
end

% convert values into contrast code beh __________________________________________________________________
% Define the mapping of values to numeric codes
stim_map = {'high_stim', 'med_stim', 'low_stim'}; codeMap = [1, 0, -1];
% Convert the column values to a categorical array
categoricalColumn = categorical(subset_beh.stimtype, stim_map);
subset_beh.stimcon_linear = grp2idx(categoricalColumn) - 2;

%% mediation X - M - Y __________________________________________________________________
xx{s, 1} = subset_beh.stimcon_linear; % table2array(T(:, 'cue_con'));% T.cue; %
% dat =  fmri_data(char(fname_nii));
mm{s, 1} = dat.dat;
%     mm{s, 1} = char(fname_nii);
yy{s, 1} = subset_beh.outcomerating;% table2array(T(:,strcat(y_rating, '_rating'))); %T.actual_rating;

new_m = mm; new_x = xx; new_y = yy;
X = cell( size(new_x,1), 1);
Y = cell( size(new_x,1), 1);
M = cell( size(new_x,1), 1);
for s = 1:length(new_y)
    idx_nan = [];
    idx_nan = ~isnan(new_y{s});
    Y{s} = new_y{s}(idx_nan,:);
    M{s} = new_m{s}(:,idx_nan');
    X{s} = new_x{s}(idx_nan,:);
end

xx = X; yy= Y; mm = M;
%% Reduce the dimensionality of the brain-mediator data using PVD
min_comp = min(cellfun('size',yy,1));
% project onto lower dimensional space keeping th max number of components
pdm = multivariateMediation(xx,yy,mm,'noPDMestimation');

% same as above, but keep only 25 components
pdm = multivariateMediation(xx,yy,mm,'noPDMestimation','B',min_comp);


%% Compute the multivariate brain mediators

% use previous PVD dimension reduction, compute all 25 PDMs, and plot path coeff
pdm = multivariateMediation(pdm,'nPDM', 7, 'plots');

% select the number of PDMs (3) based on the |ab| coeff plot, like a scree-plot
% pdm = multivariateMediation(pdm,'nPDM',3);


%% bootstrap voxel weights for significance

% bootstrap the first PDM with 100 samples
pdm = multivariateMediation(pdm,'noPDMestimation','bootPDM',1,'Bsamp',100);
pdm = multivariateMediation(xx,yy,mm,'B',min_comp,'nPDM',3,'bootPDM',1:3,'bootJPDM','Bsamp',100,'save2file','PDMresults.mat');
