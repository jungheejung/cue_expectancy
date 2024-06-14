function step02_apply_NPS()
%% Data directories and parameters setup

main_dir = '/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/deriv01_signature/rampup_plateau_canlab';
singletrial_dir = fullfile('/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupplateau');

d = dir(singletrial_dir);
dfolders = d([d(:).isdir]);
dfolders = dfolders(~ismember({dfolders(:).name},{'.','..','archive','beh','sub-0000'}));
% Further filter to include only folders that start with "sub-"
dfolders_remove = dfolders(startsWith({dfolders.name}, 'sub-'));

key = 'stimulus';
sub_list = {dfolders_remove.name};
key_list = {'stimulus'}; % Add 'cue' to this list if needed

%% Initialize a table to store the results
resultTable = table();


for sub_ind = 1:length(sub_list)
    subtable = table();
    sub = sub_list{sub_ind};

    %% Process each file
    sub = sub;    ses = '*';    run = '*';    runtype = 'pain';    event = 'stimulus';
    fname_template = fullfile(singletrial_dir, sub, ...
        strcat(sub, '_', ses, '_', run, '_runtype-', runtype, '_event-', event,'*.nii.gz'));
    fname_list = dir(fname_template);
    flist4table = {fname_list.name};
    output_table = cell2table(flist4table', 'VariableNames', {'singletrial_fname'});

    dataobj = fmri_data(filenames(fname_template));
    [nps_values, image_names, ~, npspos_exp_by_region, npsneg_exp_by_region, npspos, npsneg] = apply_nps(dataobj);

    %% Prepare region names (assumes pos and neg regions are constant across files)
    if file_ind == 1 && isempty(resultTable)
        posnames = {'vermis', 'rIns', 'rV1', 'rThal', 'lIns', 'rdpIns', 'rS2_Op', 'dACC'};
        negnames = {'rLOC', 'lLOC', 'rpLOC', 'pgACC', 'lSTS', 'rIPL', 'PCC'};
        allRegionNames = [{'singletrial_fname','NPS','NPSpos', 'NPSneg'} posnames, negnames];
    end

    allRegionNames = [{'singletrial_fname', 'NPS','NPSpos', 'NPSneg'}, posnames, negnames];

    % Ensure the data row matches in number of elements
    dataRow = [image_names{:}, nps_values{:},num2cell(npspos.dat), num2cell(npsneg.dat), npspos_exp_by_region{:}, npsneg_exp_by_region{:}]; % Adjust based on actual data structure
    dataRowFlat = horzcat(dataRow{1}, dataRow{2}, dataRow{3},dataRow{4},num2cell(dataRow{5}), num2cell(dataRow{6}));
    cell2table(image_names{:},nps_values{:},npspos.dat, npsneg.dat, npspos_exp_by_region{:}, npsneg_exp_by_region{:})
    % Then, create the table row
    if numel(dataRowFlat) == numel(allRegionNames)
        newRow = array2table(dataRowFlat, "VariableNames", allRegionNames);
    else
        error('Mismatch between data and variable names lengths');
    end

    %% Append to the result table
    subtable = newRow;
    resultTable = [subtable; newRow];

writetable(subtable, fullfile(main_dir, strcat(sub,'_CANlab_applyNPS_singletrial_rampupplateau.csv')));
end

%% Save the result table to a file (optional)
writetable(resultTable, fullfile(main_dir, 'CANlab_applyNPS_singletrial_rampupplateau.csv'));
end

function subFolders = getSubFolders(singletrial_dir)
d = dir(singletrial_dir);
isSub = startsWith({d.name}, 'sub-') & [d.isdir];
subFolders = {d(isSub).name};
end


