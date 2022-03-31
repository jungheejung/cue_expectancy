clear;clc;
Path = '/Users/spring/Dropbox (Dartmouth College)/NPS_Reliability/D01_Single_trial_dataset/canlab_single_trials_for_git_repo';
st_datasets = {'bmrk5pain_xc','bmrk3pain','bmrk4','scebl','ie2','exp','ilcp','ie'};
%%
all_data = [];
for s = 1:length(st_datasets)
    cd(Path);
    if exist(['NPS_complete_metadata_',st_datasets{s},'.mat'],'file')
        load(['NPS_complete_metadata_',st_datasets{s},'.mat']);
    else
        this_dat = load_image_set(st_datasets{s});
        meta_data = extract_nps(this_dat);
        meta_data.study_id = repmat(st_datasets(s),height(meta_data),1);
        save(['NPS_complete_metadata_',st_datasets{s},'.mat'],'meta_data'); 
    end
    
    if s == 1
       all_data = meta_data;
    else
       all_data = outerjoin(all_data,meta_data,'MergeKeys', true);
    end
end
%%
all_data = sortrows(all_data, [63 7 4 5]);
cd(Path);
save('metadata_all_NPS_complete_exclude_nsf.mat','all_data');
clear meta_data s;

%% EXTRACT NPS
function nps_metadata = extract_nps(dat)
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

    % exclude trials with high vifs
    if ismember('high_vif', dat.metadata_table.Properties.VariableNames)
       dat.metadata_table = dat.metadata_table(dat.metadata_table.high_vif ~= 1,:);
    end

    nps_metadata = dat.metadata_table;
end
