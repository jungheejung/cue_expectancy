#!/usr/bin/env python

"""
Apply signatures to nifti input
===============================
Benchmarks the apply_all_signatures.m
 which uses the code CanlabCore/Data_extraction/load_image_set.m

Signature indices are inputted as slurm ids (environment variable)
"""

import os, glob, pathlib
from nilearn import image, plotting
import numpy as np
import pandas as pd
import argparse
from memory_profiler import profile
import cProfile

# %% -------------------------------------------------------------------------
#  functions
# ----------------------------------------------------------------------------
# TODO: ADD FM-Multisens signature


def convert_imggz_to_niigz_nib(img_fname):
    # fslchfiletype NIFTI_GZ weights_NSF_grouppred_cvpcr.img
    import subprocess
    from pathlib import Path
    import nibabel as nb

    img_dir = os.path.dirname(img_fname)
    img_fnamestem = Path(img_fname).with_suffix("").stem
    new_fname = os.path.join(img_dir, img_fnamestem + ".nii.gz")
    if ".img.gz" in img_fname:
        # unzip  and then run on os.path.splitext(os.path.basename(img_fname))
        import gzip
        import shutil

        print(img_fname)
        img_fpath = os.path.join(img_dir, img_fnamestem + ".img")
        with gzip.open(img_fname, "rb") as f_in:
            with open(img_fpath, "wb") as f_out:
                shutil.copyfileobj(f_in, f_out)
        img = nb.load(img_fpath)
        nb.save(img, new_fname)
        new_fname = os.path.join(img_dir, img_fnamestem + ".nii.gz")
    else:
        img = nb.load(img_fname)
        nb.save(img, new_fname)

    return new_fname


# @profile
def utils_extractsignature(img_flist, signature_dict, signature_key):
    """
    Using signature_dict, select a signature that you want to use.
    This code will apply the signatures onto your img_flist and return the dot product between signature and each Nifti image.

    Args:
        img_flist (list): list of Nifti filepaths
        signature_dict (dict): dictionary with signature names as keys, signature paths as values.
        signature_key (str): name of signature

    Returns:
        pd.Dataframe: table with signature extracted dot products
    """

    import os, glob
    from nilearn import image
    import pandas as pd
    import numpy as np
    from nilearn import plotting

    # ----------------------------------------------------------------------------
    # 1. concat image based on filelist
    img_flist = sorted(img_flist)
    stacked_singletrial = image.concat_imgs(sorted(img_flist))

    # ----------------------------------------------------------------------------
    # 2. concatenate
    mask_priv_dir = "/dartfs-hpc/rc/lab/C/CANlab/modules/MasksPrivate"
    mul_sig_dir = "/dartfs-hpc/rc/lab/C/CANlab/modules/Neuroimaging_Pattern_Masks/Multivariate_signature_patterns"
    mask_priv_fname = glob.glob(
        os.path.join(mask_priv_dir, "**", signature_dict[signature_key] + "*"),
        recursive=True,
    )
    mul_sig_fname = glob.glob(
        os.path.join(mul_sig_dir, "**", signature_dict[signature_key] + "*"),
        recursive=True,
    )
    mask_priv_fname.extend(mul_sig_fname)
    # print(mask_priv_fname)
    if len(mask_priv_fname):
        print(mask_priv_fname[0])
    else:
        print(f"check whats going on: {mask_priv_fname}")

    signature_fname = mask_priv_fname[0]
    print(f"key: {signature_key}, signature filename: {mask_priv_fname}")

    if ".nii" not in os.path.splitext(signature_fname)[-1]:
        print(signature_fname)
        signature_fname = convert_imggz_to_niigz_nib(signature_fname)

    # ----------------------------------------------------------------------------
    # 3. resample space
    signature_img = image.load_img(signature_fname)
    resampled_nps = image.resample_img(
        signature_img,
        target_affine=stacked_singletrial.affine,
        target_shape=stacked_singletrial.shape[0:3],
        interpolation="nearest",
    )

    # ----------------------------------------------------------------------------
    #  4. apply signature
    nps_array = image.get_data(resampled_nps)
    singletrial_array = image.get_data(stacked_singletrial)
    len_singletrialstack = singletrial_array.shape[-1]
    vectorize_singletrial = singletrial_array.reshape(
        np.prod(list(singletrial_array.shape[0:3])), len_singletrialstack
    )
    nps_extract = np.dot(nps_array.reshape(-1), vectorize_singletrial)
    nps_df = pd.DataFrame(
        {
            "singletrial_fname": [os.path.basename(basename) for basename in img_flist],
            signature_key: nps_extract,
        }
    )
    return nps_df


# %% -------------------------------------------------------------------------
#  0. argparse
# ----------------------------------------------------------------------------
parser = argparse.ArgumentParser()
parser.add_argument(
    "--slurm-id",
    type=int,
    help="specify slurm array id for list of signatures\n1) NPS, 2) NPSpos, 3)NPSneg, 4) SIIPS...",
)
parser.add_argument("--input-niidir", type=str, help="path where Nifti images exist")
parser.add_argument(
    "--output-savedir",
    type=str,
    help="path to save signature extracted values",
)
args = parser.parse_args()
print(args.slurm_id)
slurm_id = args.slurm_id  # e.g. 1, 2
singletrial_dir = args.input_niidir
save_signaturedir = args.output_savedir


# %% -------------------------------------------------------------------------
#  parameters
# ----------------------------------------------------------------------------
# TODO: delete section1. load nifti image
# singletrial_dir = "/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_TTL2"
# save_signaturedir = "/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/deriv01_signature/ttl2"


# load in the signatures:
signature_dict = {
    "NPS": "weights_NSF_grouppred_cvpcr.img.gz",  # Wager et al. 2013 NPS   - somatic pain
    "NPSpos": "NPSp_Lopez-Sola_2017_PAIN.img.gz",  # 2017 Lopez-Sola positive NPS regions only
    "NPSneg": "NPSn_Lopez-Sola_2017_PAIN.img.gz",  # 2017 Lopez-Sola negative NPS regions only, excluding visual
    "SIIPS": "nonnoc_v11_4_137subjmap_weighted_mean.nii",  # Woo 2017 SIIPS - stim-indep pain,
    "PINES": "Rating_Weights_LOSO_2.nii",  # Chang 2015 PINES - neg emo
    "Rejection": "dpsp_rejection_vs_others_weights_final.nii",  # Woo 2014 romantic rejection
    "VPS": "bmrk4_VPS_unthresholded.nii",  # Krishnan 2016 Vicarious pain VPS
    "VPSnooccip": "Krishnan_2016_VPS_bmrk4_Without_Occipital_Lobe.nii",  # Krishnan 2016 no occipital
    "GSR": "ANS_Eisenbarth_JN_2016_GSR_pattern.img",  # Eisenbarth 2016 autonomic - GSR,
    "Heart": "ANS_Eisenbarth_JN_2016_HR_pattern.img",  # Eisenbarth 2016 autonomic - heart rate (HR)
    "FMMultisens": "FM_Multisensory_wholebrain.nii",  # 2017 Lopez-Sola fibromyalgia,
    "FMpain": "FM_pain_wholebrain.nii",  # 2017 Lopez-Sola fibromyalgia
    "EmpathicCare": "Ashar_2017_empathic_care_marker.nii",  # 2017 Ashar et al. Empathic care and distress
    "EmpathicDist": "Ashar_2017_empathic_distress_marker.nii",
    "Guilt_behavior": "Yu_guilt_SVM_sxpo_sxpx_EmotionForwardmask.nii",  # Yu 2019 Cer Ctx Guilt behavior
    # Kragel 2015 emotion PLS maps
    "Amused": "mean_3comp_amused_group_emotion_PLS_beta_BSz_10000it.nii.gz ",
    "Angry": "mean_3comp_angry_group_emotion_PLS_beta_BSz_10000it.nii.gz",
    "Content": "mean_3comp_neutral_group_emotion_PLS_beta_BSz_10000it.nii.gz",
    "Fearful": "mean_3comp_fearful_group_emotion_PLS_beta_BSz_10000it.nii.gz",
    "Neutral": "mean_3comp_neutral_group_emotion_PLS_beta_BSz_10000it.nii.gz",
    "Sad": "mean_3comp_sad_group_emotion_PLS_beta_BSz_10000it.nii.gz",
    "Surprised": "mean_3comp_surprised_group_emotion_PLS_beta_BSz_10000it.nii.gz",
    # Kragel 2018 whole-brain pain cog control neg emotion
    "Kragel18Pain": "bPLS_Wholebrain_Pain.nii",
    "Kragel18CogControl": "bPLS_Wholebrain_Cognitive_Control.nii",
    "Kragel18NegEmotion": "bPLS_Wholebrain_Negative_Emotion.nii",
    "Reddan18CSplusvsCSminus": "IE_ImEx_Acq_Threat_SVM_nothresh.nii",
    "GeuterPaincPDM": "Geuter_2020_cPDM_combined_pain_map.nii",
    # Zhou 2020 eLife vicarious pain
    "ZhouVPS": "General_vicarious_pain_pattern_unthresholded.nii",
    # MPA2 general vs. specific aversiveness',
    "GeneralAversive": "General_bplsF_unthr.nii",
    "Mechpain": "Mechanical_bplsF_unthr.nii",
    "ThermalPain": "Thermal_bplsF_unthr.nii",
    "AversiveSound": "Sound_bplsF_unthr.nii",
    "AversiveVisual": "Visual_bplsF_unthr.nii",
    # Wager 2011 prediction of placebo brain [P - C]->behav [P - C],
    "PlaceboPvsC_Antic": "PlaceboPredict_Anticipation.img",
    # During pain [P - C]->behav [P - C],
    "PlaceboPvsC_Pain": "PlaceboPredict_PainPeriod.img",
    "Stroop": "stroop_pattern_wani_121416.nii",
}

sig_df = pd.DataFrame(columns=["singletrial_fname"])
signature_key = list(signature_dict.keys())[slurm_id]  # signature_dict.keys()[slurm_id]
print(signature_key)


# %% -------------------------------------------------------------------------
#  load single trial images
# ----------------------------------------------------------------------------
# @profile
def main():
    nifti_fname_dict = {
        "singletrial_dir": singletrial_dir,
        "sub": "*",
        "ses": "*",
        "run": "*",
        "runtype": "*",
        "event": "stimulus",
    }
    if nifti_fname_dict["sub"] == "*":
        save_sub = "all"
    else:
        save_sub = nifti_fname_dict["sub"]
    if nifti_fname_dict["runtype"] == "*":
        save_runtype = "pvc"
    else:
        save_runtype = nifti_fname_dict["runtype"]

    sub = "*"
    ses = "*"
    run = "*"
    runtype = "*"
    event = "stimulus"

    img_flist = glob.glob(
        os.path.join(
            singletrial_dir,
            sub,
            f"{sub}_{ses}_{run}_runtype-{runtype}_event-{event}*.nii.gz",
        )
    )
    print(sorted(img_flist)[0:10])
    img_flist = sorted(img_flist)

    stacked_singletrial = image.concat_imgs(sorted(img_flist))
    # %% -------------------------------------------------------------------------
    #  extract signature and save as tsv
    # ----------------------------------------------------------------------------
    df = utils_extractsignature(img_flist, signature_dict, signature_key)
    pathlib.Path(save_signaturedir).mkdir(parents=True, exist_ok=True)
    df.to_csv(
        os.path.join(
            save_signaturedir,
            f"signature-{signature_key}_sub-{save_sub}_runtype-{save_runtype}_event-{event}.tsv",
        )
    )


if __name__ == "__main__":
    cProfile.run("main()")
