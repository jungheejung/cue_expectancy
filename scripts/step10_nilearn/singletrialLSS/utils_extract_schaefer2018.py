def utils_extract_schaefer2018(nifti_fname_dict):
    # parameters
    # ==========
    #   nifti_fname: 
    # result
    # ======
    # run them through nifti masker
    import argparse
    import numpy as np
    import os, glob
    import pandas as pd
    from nilearn import image
    from nilearn.maskers import NiftiLabelsMasker
    from nilearn import datasets

    singletrial_dir = nifti_fname_dict['singletrial_dir']; sub = nifti_fname_dict['sub'];
    ses = nifti_fname_dict['ses']; run = nifti_fname_dict['run']; runtype = nifti_fname_dict['runtype']; event = nifti_fname_dict['event'];

    img_flist = glob.glob(os.path.join(singletrial_dir, sub, f'{sub}_{ses}_{run}_{runtype}_event-{event}_trial-*.nii.gz'))
    img_flist = sorted(img_flist)

    stacked_singletrial = image.concat_imgs(sorted(img_flist))

    dataset = datasets.fetch_atlas_schaefer_2018()
    atlas_filename = dataset.maps
    # labels = dataset.labels
    labels = np.insert(dataset.labels, 0, 'Background')
    masker = NiftiLabelsMasker(labels_img=atlas_filename, standardize=True,
                            memory='nilearn_cache', verbose=5)
    time_series = masker.fit_transform(stacked_singletrial) # (trials, parcels)
    labels_utfstring = [x.decode('utf-8')  for x in labels[1:] ]
    singletrial_vstack_beta = pd.DataFrame(time_series, columns = labels_utfstring)
    flist_basename = [os.path.basename(m) for m in sorted(img_flist)]
    singletrial_vstack_beta.insert(0, 'singletrial_fname', flist_basename)
    return singletrial_vstack_beta