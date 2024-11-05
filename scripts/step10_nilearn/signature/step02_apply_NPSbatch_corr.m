function step02_apply_NPSbatch(slurm_id, main_dir, singletrial_dir)
    %% Data directories and parameters setup
%     main_dir = '/Volumes/seagate/TMP';
main_dir = '/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/deriv01_signature/rampup_plateau_brainmask';
    singletrial_dir = fullfile('/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupplateau');
    sub_list = getSubFolders(singletrial_dir);
    key_list = {'stimulus'}; % Add 'cue' to this list if needed

    %% Initialize a table to store the results
    resultTable = table();

    %% Loop through keys and subjects
    for k = 1:length(key_list)
        key = key_list{k};
        
        for sub_ind = slurm_id %1:length(sub_list)
            sub = sub_list{sub_ind};
            test_files = dir(fullfile(singletrial_dir, sub, sprintf('*_event-%s*.nii.gz', key)));

            %% Process each file
            for file_ind = 1:length(test_files)
                dataobj = fmri_data(fullfile(test_files(file_ind).folder, test_files(file_ind).name));
                [nps_values, image_names, ~, npspos_exp_by_region, npsneg_exp_by_region, npspos, npsneg] = apply_nps(dataobj);

                %% Prepare region names (assumes pos and neg regions are constant across files)
                if file_ind == 1 && isempty(resultTable)
                    posnames = {'vermis', 'rIns', 'rV1', 'rThal', 'lIns', 'rdpIns', 'rS2_Op', 'dACC'};
                    negnames = {'rLOC', 'lLOC', 'rpLOC', 'pgACC', 'lSTS', 'rIPL', 'PCC'};
                    allRegionNames = [{'singletrial_fname'}, {'NPS'},{'NPSpos'}, {'NPSneg'}, posnames, negnames];
                end



                allRegionNames = [{'singletrial_fname', 'NPS', 'NPSpos', 'NPSneg'}, posnames, negnames];
                
                % Ensure the data row matches in number of elements
                dataRow = [image_names(1), nps_values, npspos, npsneg, npspos_exp_by_region{:}, npsneg_exp_by_region{:}]; % Adjust based on actual data structure
                dataRowFlat = horzcat(dataRow{1}, dataRow{2}, dataRow{3}, dataRow{4}, num2cell(dataRow{5}), num2cell(dataRow{6}));
                % Then, create the table row
                if numel(dataRowFlat) == numel(allRegionNames)
                    newRow = array2table(dataRowFlat, "VariableNames", allRegionNames);
                else
                    error('Mismatch between data and variable names lengths');
                end

                %% Append to the result table
                resultTable = [resultTable; newRow];
            end
            writetable(resultTable, fullfile(main_dir, 'CANlab_applyNPS_singletrial_rampupplateau.csv'));
        end
    end

    %% Save the result table to a file (optional)
%     writetable(resultTable, fullfile(main_dir, 'CANlab_applyNPS_singletrial_rampupplateau.csv'));
end

function subFolders = getSubFolders(singletrial_dir)
    d = dir(singletrial_dir);
    isSub = startsWith({d.name}, 'sub-') & [d.isdir];
    subFolders = {d(isSub).name};
end


