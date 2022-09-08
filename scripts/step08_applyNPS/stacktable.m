main_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social';
vps_dir = fullfile(main_dir, 'analysis', 'fmri', 'spm', 'multivariate_24dofcsd','s04_extractbiomarker');
d = dir(vps_dir);
dfolders = d([d(:).isdir]);
dfolders_remove = dfolders(~ismember({dfolders(:).name},{'.','..','sub-0000','sub-0002', 'model-03_CEScsA_24motion'}));
sub_list = {dfolders_remove.name};

fname_key = {'cognitive_ev-cue_l2norm', 'cognitive_ev-cue', 'cognitive_ev-stim_l2norm', 'cognitive_ev-stim',...
    'pain_ev-cue_l2norm', 'pain_ev-cue', 'pain_ev-stim_l2norm', 'pain_ev-stim',...
    'vicarious_ev-cue_l2norm', 'vicarious_ev-cue', 'vicarious_ev-stim_l2norm', 'vicarious_ev-stim'};



for f = 5:8
    T = []
for sub = 1:length(sub_list)

sub_fname = fullfile(vps_dir, sub_list(sub), strcat('extract-VPS_', sub_list(sub), '_', fname_key{f}, '.csv'));
if isfile(sub_fname)
Tsub = readtable(char(sub_fname));
T = [T ; Tsub] ;
end
table_fname = fullfile(vps_dir, char(strcat('extract-VPS_', fname_key{f}, '.csv')));
writetable(T, char(table_fname));
end
end