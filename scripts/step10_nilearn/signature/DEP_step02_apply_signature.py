#!/usr/bin/env python
# purpose: 
# I benchmarked the apply_all_signatures.m which uses the code CanlabCore/Data_extraction/load_image_set.m
# %%
import os
import glob
from nilearn import image
from nilearn import plotting
import numpy as np
import pandas as pd

# %%
def utils_extract_schaefer2018(nifti_fname_dict):
    # parameters
    # ==========
    #   nifti_fname:
    # result
    # ======
    # run them through nifti masker
    import argparse
    import numpy as np
    import os
    import glob
    import pandas as pd
    from nilearn import image
    from nilearn.maskers import NiftiLabelsMasker
    from nilearn import datasets

    singletrial_dir = nifti_fname_dict['singletrial_dir']
    sub = nifti_fname_dict['sub']
    ses = nifti_fname_dict['ses']
    run = nifti_fname_dict['run']
    runtype = nifti_fname_dict['runtype']
    event = nifti_fname_dict['event']

    img_flist = glob.glob(os.path.join(
        singletrial_dir, sub, f'{sub}_{ses}_{run}_{runtype}_event-{event}_trial-*.nii.gz'))
    img_flist = sorted(img_flist)

    stacked_singletrial = image.concat_imgs(sorted(img_flist))

    dataset = datasets.fetch_atlas_schaefer_2018()
    atlas_filename = dataset.maps
    # labels = dataset.labels
    labels = np.insert(dataset.labels, 0, 'Background')
    masker = NiftiLabelsMasker(labels_img=atlas_filename, standardize=True,
                               memory='nilearn_cache', verbose=5)
    time_series = masker.fit_transform(
        stacked_singletrial)  # (trials, parcels)
    labels_utfstring = [x.decode('utf-8') for x in labels[1:]]
    singletrial_vstack_beta = pd.DataFrame(
        time_series, columns=labels_utfstring)
    flist_basename = [os.path.basename(m) for m in sorted(img_flist)]
    singletrial_vstack_beta.insert(0, 'singletrial_fname', flist_basename)
    return singletrial_vstack_beta

# def convert_imggz_to_niigz(img_fname):
    # fslchfiletype NIFTI_GZ weights_NSF_grouppred_cvpcr.img  
    import subprocess
    from pathlib import Path
    img_dir = os.path.dirname(img_fname)
    img_fnamestem = Path(img_fname).with_suffix('').stem
    if '.img.gz' in img_fname:
        # unzip
        # and then run on os.path.splitext(os.path.basename(img_fname))
        import gzip
        import shutil
        print(img_fname)
        # img_dir = os.path.dirname(img_fname)
        # img_fnamestem = Path(img_fname).with_suffix('').stem
        img_fpath = os.path.join(img_dir,img_fnamestem + '.img')
        with gzip.open(img_fname, 'rb') as f_in:
            with open(img_fpath, 'wb') as f_out:
                shutil.copyfileobj(f_in, f_out)
        command = f'fslchfiletype NIFTI_GZ {img_fpath}'
        process = subprocess.Popen(command.split(), stdout=subprocess.PIPE)
        output, error = process.communicate()
        new_fname = os.path.join(img_dir, img_fnamestem + '.nii.gz')
    else:
        command = f'fslchfiletype NIFTI_GZ {img_fname}'
        process = subprocess.Popen(command.split(), stdout=subprocess.PIPE)
        output, error = process.communicate()
        new_fname = os.path.join(img_dir, img_fnamestem + '.nii.gz')
    return None

def convert_imggz_to_niigz_nib(img_fname):
    # fslchfiletype NIFTI_GZ weights_NSF_grouppred_cvpcr.img  
    import subprocess
    from pathlib import Path
    import nibabel as nb

    img_dir = os.path.dirname(img_fname)
    img_fnamestem = Path(img_fname).with_suffix('').stem
    new_fname = os.path.join(img_dir, img_fnamestem + '.nii.gz')
    if '.img.gz' in img_fname:
        # unzip
        # and then run on os.path.splitext(os.path.basename(img_fname))
        import gzip
        import shutil
        print(img_fname)
        # img_dir = os.path.dirname(img_fname)
        # img_fnamestem = Path(img_fname).with_suffix('').stem

        img_fpath = os.path.join(img_dir,img_fnamestem + '.img')
        with gzip.open(img_fname, 'rb') as f_in:
            with open(img_fpath, 'wb') as f_out:
                shutil.copyfileobj(f_in, f_out)
        # fname = '<file name>.img'  
        img = nb.load(img_fpath)
        nb.save(img, new_fname)
        # command = f'fslchfiletype NIFTI_GZ {img_fpath}'
        # process = subprocess.Popen(command.split(), stdout=subprocess.PIPE)
        # output, error = process.communicate()
        new_fname = os.path.join(img_dir, img_fnamestem + '.nii.gz')
    else:
        img = nb.load(img_fpath)
        nb.save(img, new_fname)
        
    return new_fname

# %%
# 1. load nifti image
singletrial_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial'
save_signaturedir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/signature_extract'
key = 'NPS'

# TODO: load in the signatures:
signature_dict = {'NPS': 'weights_NSF_grouppred_cvpcr.img.gz',  # Wager et al. 2013 NPS   - somatic pain
           'NPSpos': 'NPSp_Lopez-Sola_2017_PAIN.img.gz',# 2017 Lopez-Sola positive NPS regions only
           'NPSneg': 'NPSn_Lopez-Sola_2017_PAIN.img.gz',# 2017 Lopez-Sola negative NPS regions only, excluding visual
           'SIIPS': 'nonnoc_v11_4_137subjmap_weighted_mean.nii',# Woo 2017 SIIPS - stim-indep pain,
           'PINES': 'Rating_Weights_LOSO_2.nii', # Chang 2015 PINES - neg emo
           'Rejection': 'dpsp_rejection_vs_others_weights_final.nii', # Woo 2014 romantic rejection
           'VPS': 'bmrk4_VPS_unthresholded.nii',  # Krishnan 2016 Vicarious pain VPS
           'VPS_nooccip': 'Krishnan_2016_VPS_bmrk4_Without_Occipital_Lobe.nii',# Krishnan 2016 no occipital
           'GSR': 'ANS_Eisenbarth_JN_2016_GSR_pattern.img',# Eisenbarth 2016 autonomic - GSR,
           'Heart': 'ANS_Eisenbarth_JN_2016_HR_pattern.img',# Eisenbarth 2016 autonomic - heart rate (HR)
           'FM-Multisens': 'FM_Multisensory_wholebrain.nii',# 2017 Lopez-Sola fibromyalgia,
           'FM-pain': 'FM_pain_wholebrain.nii',# 2017 Lopez-Sola fibromyalgia
           'Empathic_Care':  'Ashar_2017_empathic_care_marker.nii',# 2017 Ashar et al. Empathic care and distress
           'Empathic_Dist': 'Ashar_2017_empathic_distress_marker.nii',
           'Guilt_behavior': 'Yu_guilt_SVM_sxpo_sxpx_EmotionForwardmask.nii',# Yu 2019 Cer Ctx Guilt behavior
           # Kragel 2015 emotion PLS maps
           'Amused': 'mean_3comp_amused_group_emotion_PLS_beta_BSz_10000it.img',
           'Angry':  'mean_3comp_angry_group_emotion_PLS_beta_BSz_10000it.img',
           'Content':  'mean_3comp_neutral_group_emotion_PLS_beta_BSz_10000it.img',
           'Fearful': 'mean_3comp_fearful_group_emotion_PLS_beta_BSz_10000it.img',
           'Neutral': 'mean_3comp_neutral_group_emotion_PLS_beta_BSz_10000it.img',
           'Sad': 'mean_3comp_sad_group_emotion_PLS_beta_BSz_10000it.img',
           'Surprised': 'mean_3comp_surprised_group_emotion_PLS_beta_BSz_10000it.img',
           # Kragel 2018 whole-brain pain cog control neg emotion
           'Kragel18Pain': 'bPLS_Wholebrain_Pain.nii',
           'Kragel18CogControl': 'bPLS_Wholebrain_Cognitive_Control.nii',
           'Kragel18NegEmotion': 'bPLS_Wholebrain_Negative_Emotion.nii',
           'Reddan18CSplus_vs_CSminus': 'IE_ImEx_Acq_Threat_SVM_nothresh.nii',
           'GeuterPaincPDM': 'Geuter_2020_cPDM_combined_pain_map.nii',
           # Zhou 2020 eLife vicarious pain
           'ZhouVPS': 'General_vicarious_pain_pattern_unthresholded.nii',
           # MPA2 general vs. specific aversiveness',
           'General aversive': 'General_bplsF_unthr.nii',
           'Mech pain': 'Mechanical_bplsF_unthr.nii',
           'Thermal pain': 'Thermal_bplsF_unthr.nii',
           'Aversive Sound': 'Sound_bplsF_unthr.nii',
           'Aversive Visual': 'Visual_bplsF_unthr.nii',
           # Wager 2011 prediction of placebo brain [P - C]->behav [P - C],
           'PlaceboPvsC_Antic': 'PlaceboPredict_Anticipation.img',
           # During pain [P - C]->behav [P - C],
           'PlaceboPvsC_Pain': 'PlaceboPredict_PainPeriod.img',
           'stroop': 'stroop_pattern_wani_121416.nii'}
mask_priv_dir = '/dartfs-hpc/rc/lab/C/CANlab/modules/MasksPrivate'
mul_sig_dir = '/dartfs-hpc/rc/lab/C/CANlab/modules/Neuroimaging_Pattern_Masks/Multivariate_signature_patterns'
mask_priv_fname = glob.glob(os.path.join(mask_priv_dir, '**', signature_dict[key]), recursive = True)
mul_sig_fname = glob.glob(os.path.join(mul_sig_dir, '**', signature_dict[key]), recursive = True)
mask_priv_fname.extend(mul_sig_fname)
print(mask_priv_fname)
if len(mask_priv_fname) == 1:
    print(mask_priv_fname[0])
else: 
    print(f"check whats going on: {mul_sig_fname}")

signature_fname = mask_priv_fname[0]
print(f"key: {key}, signature filename: {mul_sig_fname}")
# signature_fname = '/Users/h/Documents/MATLAB/MasksPrivate/Masks_private/2017_Lopez_Sola_Fibromyalgia/rNPS_fdr_pospeaks_smoothed.img.gz'
if '.nii' not in os.path.splitext(signature_fname)[-1]:
    print(signature_fname)
    signature_fname = convert_imggz_to_niigz_nib(signature_fname)
    # signature_fname = 


nifti_fname_dict = {'singletrial_dir': singletrial_dir,
                    'sub': '*',
                    'ses': '*',
                    'run': '*',
                    'runtype': 'pain',
                    'event': 'stimulus'}
if nifti_fname_dict['sub'] == '*':
    save_sub = 'sub-all'
else: 
    save_sub = nifti_fname_dict['sub']


# singletrial_dir = '/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/singletrial/'
sub = '*'
ses = '*'
run = '*'
runtype = 'pain'
event = 'stimulus'
img_flist = glob.glob(os.path.join(singletrial_dir, sub,
                      f'{sub}_{ses}_{run}_runtype-{runtype}_event-{event}*.nii.gz'))
print(img_flist)
img_flist = sorted(img_flist)
stacked_singletrial = image.concat_imgs(sorted(img_flist))
# %% extract atlas if needed
# TODO: updatecode
#schaefer2018 = utils_extract_schaefer2018(nifti_fname_dict)
#schaefer2018
# 2. concatenate

# 3. resample space
# nps = '/Users/h/Documents/MATLAB/MasksPrivate/Masks_private/2013_Wager_NEJM_NPS/weights_NSF_grouppred_cvpcr.nii.gz'
nps_img = image.load_img(signature_fname)
# image.load_img(nps)
plotting.plot_stat_map(nps_img, display_mode='mosaic',
                       cut_coords=(5, 4, 10),
                       title="display_mode='z', cut_coords=5")
plotting.plot_img(image.mean_img(stacked_singletrial))
# %% resample space
resampled_nps = image.resample_img(nps_img,
                                   target_affine=stacked_singletrial.affine,
                                   target_shape=stacked_singletrial.shape[0:3],
                                   interpolation='nearest')

# %% check: plot resampled
display = plotting.plot_stat_map(image.mean_img(stacked_singletrial), display_mode='mosaic',
                                 cut_coords=(5, 4, 10),
                                 title="display_mode='z', cut_coords=5")
display.add_overlay(resampled_nps, cmap=plotting.cm.purple_green)

# %% apply nps
nps_array = image.get_data(resampled_nps)
singletrial_array = image.get_data(stacked_singletrial)
len_singletrialstack = singletrial_array.shape[-1]
vectorize_singletrial = singletrial_array.reshape(
    np.prod(list(singletrial_array.shape[0:3])), len_singletrialstack)
nps_extract = np.dot(nps_array.reshape(-1), vectorize_singletrial)
nps_df = pd.DataFrame({'singletrial_fname': [os.path.basename(
    basename) for basename in img_flist], key: nps_extract})
nps_df.to_csv(os.path.join(save_signaturedir, f"signature-{key}_sub-{save_sub}_runtype-{runtype}_event-{event}.tsv"))
