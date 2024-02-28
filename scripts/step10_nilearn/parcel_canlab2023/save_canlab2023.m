canlab2023_fine = load_atlas('canlab2023_fine_fmriprep20_2mm');
data = fmri_data(canlab2023_fine);
data.fullpath = '/Users/h/Documents/projects_local/cue_expectancy/resources/';
data.write()    

data = fmri_data(atlas)
data.fullpath = <enter your save path here>
data.write()

tbl = table(canlab2023.labels, ...
    canlab2023.labels_2, ...
    canlab2023.labels_3, ...
    canlab2023.labels_4, ...
    canlab2023.labels_5, ...
    canlab2023.label_descriptions, ...
    'VariableNames', {'fine labels', 'coarse labels', 'coarser labels', 'coarsest labels', 'source atlas', 'label_description'});
writetable(tbl,<savepath>);


tbl = table(canlab2023.labels, canlab2023.labels_2, canlab2023.labels_3, canlab2023.labels_4, canlab2023.label_descriptions, 'VariableNames', {'coarse labels', 'coarser labels', 'coarsest labels', 'source atlas', 'label_description'})
writetable(tbl,<savepath>)