function step02_apply_NPS_ROI()
%% 1. Data directories and parameters
current_dir = pwd;
main_dir = fileparts(fileparts(fileparts(current_dir)));

%% 2. test run
% main_dir = '/Volumes/spacetop_projects_social';
save_dir = '/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/deriv01_signature/rampup_plateau_canlab';
singletrial_dir = fullfile('/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupplateau');

d = dir(singletrial_dir);
dfolders = d([d(:).isdir]);
dfolders = dfolders(~ismember({dfolders(:).name},{'.','..','archive','beh','sub-0000'}));
% Further filter to include only folders that start with "sub-"
dfolders_remove = dfolders(startsWith({dfolders.name}, 'sub-'));
sub_list = {dfolders_remove.name};
key_list = {'cue', 'stimulus'};


for k = 1%:length(key_list)
    key = char(key_list(k));
    dat = [];
    meta_nifti = [];


    for sub_ind = 52:length(sub_list)
        disp(sub_ind)
        subtable = table();
        sub = sub_list{sub_ind};

        %% Process each file
        sub = sub;    ses = '*';    run = '*';    runtype = 'pain';    event = 'stimulus';
        fname_template = fullfile(singletrial_dir, sub, ...
            strcat(sub, '_', ses, '_', run, '_runtype-', runtype, '_event-', event,'*.nii.gz'));
        fname_list = dir(fname_template);
        flist4table = {fname_list.name};
        output_table = cell2table(flist4table', 'VariableNames', {'singletrial_fname'});

        %% apply NPS
        %             [nps_values, ...
        %                 image_names, ...
        %                 data_objects, ...
        %                 npspos_exp_by_region, ...
        %                 npsneg_exp_by_region, ...
        %                 clpos, clneg]  = apply_nps(test_file);
        %
        %% Xiaochun code

        dat = fmri_data(filenames(fname_template));
        refmask = fmri_data(which('brainmask_canlab.nii'));  % shell image
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

        dat.metadata_table = [dat.metadata_table output_table]; %meta_nifti(:,end)];
        if ~exist(char(fullfile(save_dir)), 'dir')
            mkdir(char(fullfile(save_dir)))
        end

        % signature-VPSnooccip_sub-all_runtype-pvc_event-stimulus.tsv
        table_fname = fullfile(save_dir, strcat(sub, '_signature-NPSroi_runtype-pvc_event-', key, '.csv'));
        writetable(dat.metadata_table, table_fname, 'Delimiter',',');
        clear dat meta_nifti test_file
        disp(strcat("complete job", sub));

%     else
%         disp(strcat('participant ', sub, ' does not have ', key, ' nifti file'));
%     end

end


end


