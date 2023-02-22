function plot_vif(main_dir, glm_dir, glm_modelname, fmriprep_dir, output_dir, sub_id)

%task_subfldr = fullfile(save_dir, strcat('task-',run{r},'_', x_keyword, '-', m_keyword,'-',y_keyword, '_l2norm'));
% input variables
input = struct();

input.main_dir = main_dir;
input.glm_dir = glm_dir;
input.glm_modelname = glm_modelname;
input.fmriprep_dir = fmriprep_dir;
input.output_dir = fullfile(output_dir, sub_id);
input.smooth_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop_data/derivatives/fmriprep/results/fmriprep';
if not(exist(input.output_dir, 'dir'))
    mkdir(input.output_dir)
input.sub_id = sub_id;

assignin('base','input',input);

options.codeToEvaluate = sprintf('vif_calc(%s)', 'input'); 
options.format = 'html';
options.outputDir = input.output_dir;
options.imageFormat = 'jpg';
vif_output = publish('vif_calc.m',options);

[folder, name] = fileparts(vif_output);
movefile(vif_output, fullfile(output_dir, strcat('vif_model-', glm_modelname, '_', sub_id,'_',datestr(now,'mm-dd-yy'), '.html')));
end
