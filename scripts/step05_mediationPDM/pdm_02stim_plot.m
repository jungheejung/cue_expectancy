function pdm_02stim_plot(task)
sublist = [6,7,8,9,10,11,13,14,15,16,17,21,23,24,28,29,30,31,32,33,35,37,43,47,51,53,55,58,60,61,62,64,65,66,68,69,70,73,74,76,78,79,80,81,84,85];
single_nii = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/analysis/fmri/spm/multivariate/s03_concatnifti/sub-0065/sub-0065_task-social_run-cognitive_ev-cue.nii';
save_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/analysis/fmri/mediation/pdm';
task= char(task);
disp(task)
%run = {'pain', 'vicarious', 'cognitive'};
%for r = 1:length(run)

if not(exist(fullfile(save_dir, strcat('task-',task,'_stimlin-stim-actual')), 'dir'))
mkdir(fullfile(save_dir, strcat('task-',task,'_stimlin-stim-actual')))
end

    dat_fname =  fullfile(save_dir, strcat('task-',task, '_PDM_stimlin-stim-actual_DAT.mat'));
    load(dat_fname)
    new_m = mm; new_x = xx; new_y = yy;

    %% plot diagnostics
    %plot(mm)
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
    new_x(remove_sub) = [];
    new_y(remove_sub) = [];
    new_m(remove_sub) = [];
    end
    disp('SIZE -------------')
    disp(size(new_x))
    disp(size(new_m))
    disp(size(new_y))
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


    %% Reduce the dimensionality of the brain-mediator data using PVD
    xx = X; yy= Y; mm = M;
    min_comp = min(cellfun('size',yy,1))
    % project onto lower dimensional space keeping th max number of components
    pdm_min = multivariateMediation(xx,yy,mm,'noPDMestimation','B',min_comp);
    save_fname = fullfile(save_dir, strcat('task-',task,'_stimlin-stim-actual'), strcat('task-',task, '_PDM-mincomp_stimlin-stim-actual.mat'));
    save(save_fname,'pdm_min');

    %% Compute the multivariate brain mediators
    % use previous PVD dimension reduction, compute PDMs, and plot path coeff
    pdm = multivariateMediation(pdm_min,'nPDM', min_comp, 'plots');
    save_fname = fullfile(save_dir, strcat('task-',task,'_stimlin-stim-actual'), strcat('task-',task, '_PDM-plot_stimlin-stim-actual.mat'));
    save(save_fname,'pdm');
    % select the number of PDMs (3) based on the |ab| coeff plot, like a scree-plot
    % pdm = multivariateMediation(pdm,'nPDM',3);


    %% bootstrap voxel weights for significance
    % bootstrap the first 3 PDM with 100 samples
    save_fname = fullfile(save_dir,strcat('task-',task,'_stimlin-stim-actual'), strcat('task-',task, '_PDM-bootstrap_stimlin-stim-actual.mat'));
    pdm_boot = multivariateMediation(xx,yy,mm,'B',min_comp,'nPDM',3,'bootPDM',1:3,'bootJPDM','Bsamp',100,'save2file',save_fname);

    %% plot
    dat = fmri_data(single_nii);
    [obj,figh] = plotPDM(pdm_boot,dat);
    % save(save_fname,'pdm','-append');


    % plot --------------------
    % load signle trial nifti
    % sngl = fname_nii;
    % m = mean(sngl);
    % orthviews(m);
    % mypdmresults = sngl;
    % mypdmresults.dat = single(pdm.WfullJoint);% need to add variables
    % orthview(mypdmresults)
    % weight_obj = statistic_image('dat', pdm.WfullJoint,'type', 'p', pdm.boot.pJointPDM{1}, 'n_inmask', 30);
    % % canlab_results_fmridisplay(pdm.WfullJoint, 'outline','linewidth',0.5)
    % 
    % si = statistic_image('dat',pdm.WfullJoint,'type','p');
    % si.p = pdm.boot.pJointPDM{1};
    % si.volInfo = sngl.volInfo;
    % orthviews(si);
    % t = threshold(si, .05, 'fdr', 'k', 10); 
    % orthviews(t);
    % mask = which(sngl); % mask used for data extraction. needs to match the voxels in mm{i} and pdm.Wfull



% o1 = canlab_results_fmridisplay(reg_all_fdr{1,r},'outline','linewidth',0.5,'montagetype','full hcp','splitcolor',{[.1 .8 .8] [.1 .1 .8] [.9 .4 0] [1 1 0]},'overlay','mni_icbm152_t1_tal_nlin_sym_09a_brainonly.img'); % o1 is an fmridisplay object - methods fmridisplay for help
end
