function plot_vif(main_dir, glm_dir, glm_modelname, fmriprep_dir, output_dir, sub_id)

%task_subfldr = fullfile(save_dir, strcat('task-',run{r},'_', x_keyword, '-', m_keyword,'-',y_keyword, '_l2norm'));
% input variables
cue_input = struct();

cue_input.main_dir = main_dir;
cue_input.glm_dir = glm_dir;
cue_input.glm_modelname = glm_modelname;
cue_input.fmriprep_dir = fmriprep_dir;
cue_input.output_dir = fullfile(output_dir, sub_id);
if not(exist(cue_input.output_dir, 'dir'))
    mkdir(cue_input.output_dir)
cue_input.sub_id = sub_id;

assignin('base','cue_input',cue_input);

options.codeToEvaluate = sprintf('vif_calc(%s)', 'cue_input'); 
options.format = 'html';
options.outputDir = cue_input.output_dir;
options.imageFormat = 'jpg';
vif_output = publish('vif_calc.m',options);

[folder, name] = fileparts(vif_output);
movefile(vif_output, fullfile(output_dir, strcat('vif_model-', glm_modelname, '_', datestr(now,'mm-dd-yy'), '.html')));
end