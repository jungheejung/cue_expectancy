% Here, I create code to extract beta coefficients from single trial data
main_dir = fileparts(fileparts(fileparts(pwd)));
canlab2023 = load_atlas('canlab2023');
singletrial_dir = '/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupdown';

%% get subdirectories
items = dir(singletrial_dir);
sub_dirs = items([items.isdir] & startsWith({items.name}, 'sub-'));
numSubDirs = numel(sub_dirs);

for i = 57:length(sub_dirs)
    % sub = "sub-0002";
    sub = sub_dirs(i).name;
    data_img = dir(fullfile(singletrial_dir, sub, strcat(sub ,'_*_runtype-pain_event-stimulus_trial-*_cuetype-*_stimintensity-*.nii.gz')));

    % Check if there are any files to process
    if isempty(data_img)
        fprintf('No files found for %s. Skipping...\n', sub);
        continue; % Skip to the next iteration of the loop
    end

    fldr_name = {data_img.folder}; fname = {data_img.name};
    img_list = strcat(fldr_name,'/', fname)';
    single_trial_obj = fmri_data(img_list);
    region_extraction = extract_data(canlab2023, single_trial_obj);
    % add data_img into column for metadata
    savedir = fullfile(main_dir,"analysis/fmri/nilearn/deriv02_parcel-canlab2023/singletrial_rampupdown");
    savefname = strcat("extractdata_", sub, "_atlas-canlab2023.tsv");
    savefpath = fullfile(savedir, savefname);
    
    if ~exist(savedir, 'dir')
        % Directory does not exist, so create it
        mkdir(savedir);
        disp(['Directory created at: ', savedir]);
    else
        disp(['Directory already exists at: ', savedir]);
    end
    
    %% add metadata into extracted parcel info
    T = array2table(region_extraction);
    T.filename = {data_img.name}';
    writetable(T, savefpath, 'Delimiter', '\t', 'FileType', 'text', 'WriteRowNames',false); % Tab-delimited text file
    clear single_trial_obj
end

%% save labels
% Combine the cell arrays into a table
L = table(canlab2023.labels', canlab2023.labels_2', canlab2023.labels_3', canlab2023.labels_4', ...
    'VariableNames', {'Label1', 'Label2', 'Label3', 'Label4'});
writetable(L, fullfile(main_dir,"analysis/fmri/nilearn/deriv02_parcel-canlab2023/singletrial_rampupdown/label_atlas-canlab2023_parcel-525.csv"));