function step02_apply_NPS_ROI()
    %% 1. Data directories and parameters
    current_dir = pwd;
    main_dir = fileparts(fileparts(fileparts(current_dir)));
    % sub-0060_ses-04_run-05_runtype-pain_event-stimulus_trial-000_cuetype-low_stimintensity-high.nii.gz
    % sub-0060_ses-04_run-06_runtype-cognitive_event-stimulus_trial-000_cuetype-low_stimintensity-high.nii.gz
    
    %% 2. test run
    % main_dir = '/Volumes/spacetop_projects_social';
    singletrial_dir = fullfile(main_dir, 'analysis', 'fmri', 'nilearn', 'singletrial');
    nps_dir = fullfile(main_dir, 'analysis', 'fmri', 'nilearn', 'signature_canlabcore');
    d = dir(singletrial_dir);
    dfolders = d([d(:).isdir]);
    dfolders_remove = dfolders(~ismember({dfolders(:).name},{'.','..','sub-0000','sub-0002'}));
    sub_list = {dfolders_remove.name};
    key_list = {'cue', 'stimulus'};
    % sub = char(sub_list(input));
    ses = '*';    run = '*';    runtype = '*';    event = 'stimulus';

    % for s = 1:length(sub_list)
    %     sub = char(sub_list(s)); 
    for k = 1:length(key_list)
        
        key = char(key_list(k));
        dat = [];
        meta_nifti = [];
        % glob all files
        test_file = dir(fullfile(singletrial_dir, sub, ...
        strcat(sub, '_', ses, '_', run, '_runtype-', runtype, '_event-', key,'*.nii.gz')));
        flist4table = {test_file.name}
        output_table = cell2table(flist4table', "VariableNames",  ["singletrial_fname"])
        % disp(strcat('loading ', sub, ' test file: ', test_file));
        % if ~isempty(test_file)
        %     nifti_metafname = fullfile(singletrial_dir,sub, strcat('niftifname_',sub,'_task-',key,'_ev-stim.txt'));
        %     meta_nifti = readtable(char(nifti_metafname),'ReadVariableNames',0);
            % input_images = filenames('image_data/Pain_Sub*ANP_001.img', 'char', 'absolute');
            % [nps_values, image_names, data_objects] = apply_nps(input_images, 'noverbose');
            
            %% apply NPS
            %             [nps_values, ...
            %                 image_names, ...
            %                 data_objects, ...
            %                 npspos_exp_by_region, ...
            %                 npsneg_exp_by_region, ...
            %                 clpos, clneg]  = apply_nps(test_file);
            %
            %% Xiaochun code
        dat = fmri_data(test_file);
        
        refmask = fmri_data(which('brainmask.nii'));  % shell image
        nps = which('weights_NSF_grouppred_cvpcr.img');
        npspos = which('weights_NSF_positive_smoothed_larger_than_10vox.img');
        npsneg = which('weights_NSF_negative_smoothed_larger_than_10vox.img');
        posnames = {'vermis'    'rIns'    'rV1'    'rThal'    'lIns'    'rdpIns'    'rS2_Op'    'dACC'};
        negnames = {'rLOC'    'lLOC'    'rpLOC'    'pgACC'    'lSTS'    'rIPL'    'PCC'};
        
        npsw = resample_space(fmri_data(nps), refmask);
        npsposw = resample_space(fmri_data(npspos), refmask);
        npsnegw = resample_space(fmri_data(npsneg), refmask);
        
        nps_values = apply_mask(dat, npsw, 'pattern_expression', 'ignore_missing');
        nps_corr_values = apply_mask(dat, npsw, 'pattern_expression', 'correlation', 'ignore_missing');
        nps_cosine_values = apply_mask(dat, npsw, 'pattern_expression', 'cosine_similarity', 'ignore_missing');
        
        npspos_values = apply_mask(dat, npsposw, 'pattern_expression', 'ignore_missing');
        npspos_corr_values = apply_mask(dat, npsposw, 'pattern_expression', 'correlation', 'ignore_missing');
        npspos_cosine_values = apply_mask(dat, npsposw, 'pattern_expression', 'cosine_similarity', 'ignore_missing');
        
        npsneg_values = apply_mask(dat, npsnegw, 'pattern_expression', 'ignore_missing');
        npsneg_corr_values = apply_mask(dat, npsnegw, 'pattern_expression', 'correlation', 'ignore_missing');
        npsneg_cosine_values = apply_mask(dat, npsnegw, 'pattern_expression', 'cosine_similarity', 'ignore_missing');
        
        all_dat2 = resample_space(dat, npspos);
        clpos = extract_roi_averages(all_dat2, npspos, 'pattern_expression', 'contiguous_regions', 'nonorm');
        clpos_corr = extract_roi_averages(all_dat2, npspos, 'pattern_expression', 'correlation', 'contiguous_regions', 'nonorm');
        clpos_cosine = extract_roi_averages(all_dat2, npspos, 'pattern_expression', 'cosine_similarity', 'contiguous_regions', 'nonorm');
        npspos_exp_by_region = cat(2, clpos.dat);
        npspos_corr_exp_by_region = cat(2, clpos_corr.dat);
        npspos_cosine_exp_by_region = cat(2, clpos_cosine.dat);
        
        clneg = extract_roi_averages(all_dat2, npsneg, 'pattern_expression', 'contiguous_regions', 'nonorm');
        clneg_corr = extract_roi_averages(all_dat2, npsneg, 'pattern_expression', 'correlation', 'contiguous_regions', 'nonorm');
        clneg_cosine = extract_roi_averages(all_dat2, npsneg, 'pattern_expression', 'cosine_similarity', 'contiguous_regions', 'nonorm');
        npsneg_exp_by_region = cat(2, clneg.dat);
        npsneg_corr_exp_by_region = cat(2, clneg_corr.dat);
        npsneg_cosine_exp_by_region = cat(2, clneg_cosine.dat);
        
        dat.metadata_table.nps = nps_values;
        dat.metadata_table.nps_corr = nps_corr_values;
        dat.metadata_table.nps_cosine = nps_cosine_values;
        
        dat.metadata_table.npspos = npspos_values;
        dat.metadata_table.npspos_corr = npspos_corr_values;
        dat.metadata_table.npspos_cosine = npspos_cosine_values;
        
        dat.metadata_table.npsneg = npsneg_values;
        dat.metadata_table.npsneg_corr = npsneg_corr_values;
        dat.metadata_table.npsneg_cosine = npsneg_cosine_values;
        %% Save
        for p = 1:length(posnames)
            pos_value_name{p} = ['pos_nps_',posnames{p}];
            pos_corr_name{p} = ['pos_nps_',posnames{p},'_corr'];
            pos_cosine_name{p} = ['pos_nps_',posnames{p},'_cosine'];
            temp_npspos = table(npspos_exp_by_region(:,p), 'VariableNames',pos_value_name(p));
            temp_npspos_corr = table(npspos_corr_exp_by_region(:,p), 'VariableNames',pos_corr_name(p));
            temp_npspos_cosine = table(npspos_cosine_exp_by_region(:,p), 'VariableNames',pos_cosine_name(p));
            
            dat.metadata_table = [dat.metadata_table temp_npspos temp_npspos_corr temp_npspos_cosine];
        end
        
        for p = 1:length(negnames)
            neg_value_name{p} = ['neg_nps_',negnames{p}];
            neg_corr_name{p} = ['neg_nps_',negnames{p},'_corr'];
            neg_cosine_name{p} = ['neg_nps_',negnames{p},'_cosine'];
            temp_npsneg = table(npsneg_exp_by_region(:,p), 'VariableNames',neg_value_name(p));
            temp_npsneg_corr = table(npsneg_corr_exp_by_region(:,p), 'VariableNames',neg_corr_name(p));
            temp_npsneg_cosine = table(npsneg_cosine_exp_by_region(:,p), 'VariableNames',neg_cosine_name(p));
            
            dat.metadata_table = [dat.metadata_table temp_npsneg temp_npsneg_corr temp_npsneg_cosine];
        end
        
            %             name = 'filename';
            %             dat.metadata_table{name} = meta_nifti(:,end);
            %             filename_meta = table(meta_nifti(:,end), 'VariableNames', 'filename');
            % meta_nifti.Properties.VariableNames(end) = {'filename'};
        dat.metadata_table = [dat.metadata_table output_table]; %meta_nifti(:,end)];
        if ~exist(char(fullfile(nps_dir)), 'dir')
            mkdir(char(fullfile(nps_dir)))
        end

            % signature-VPSnooccip_sub-all_runtype-pvc_event-stimulus.tsv
        table_fname = fullfile(nps_dir, strcat('signature-NPSroi_sub-all_runtype-pvc_event-', key, '.tsv'));
        writetable(dat.metadata_table, table_fname, 'Delimiter',' ');
        clear dat meta_nifti test_file
        disp(strcat("complete job", signature));
            
        else
            disp(strcat('participant ', sub, ' does not have ', key, ' nifti file'));
        end
        
    end
    
    
    end
end
    
    