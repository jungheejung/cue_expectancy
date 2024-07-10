% nociceptive regions (from pain_pathway atlas)
pain_pathways = load_atlas(which('pain_pathways_atlas_obj.mat'));
pain_pathways = pain_pathways.select_atlas_subset({'dpIns', 'aMCC_MPFC', 'Thal_VPLM','Thal_MD'});
pain_pathways_mean = extract_roi_averages(dat, fmri_data(pain_pathways), 'unique_mask_values', 'nonorm');