def utils_extractsignature(img_flist, signature_dict, signature_key):
    # input:
        # list of images
    # output:
        # pandas dataframe
    import os, glob
    from nilearn import image
    import pandas as pd
    import numpy as np
    from nilearn import plotting
    
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
    # 1. concat image based on filelist
    img_flist = sorted(img_flist)
    stacked_singletrial = image.concat_imgs(sorted(img_flist))

    # 2. concatenate
    mask_priv_dir = '/dartfs-hpc/rc/lab/C/CANlab/modules/MasksPrivate'
    mul_sig_dir = '/dartfs-hpc/rc/lab/C/CANlab/modules/Neuroimaging_Pattern_Masks/Multivariate_signature_patterns'
    mask_priv_fname = glob.glob(os.path.join(mask_priv_dir, '**', signature_dict[signature_key]), recursive = True)
    mul_sig_fname = glob.glob(os.path.join(mul_sig_dir, '**', signature_dict[signature_key]), recursive = True)
    mask_priv_fname.extend(mul_sig_fname)
    # print(mask_priv_fname)
    if len(mul_sig_fname):
        print(mul_sig_fname[0])
    else: 
        print(f"check whats going on: {mul_sig_fname}")

    signature_fname = mul_sig_fname[0]
    print(f"key: {signature_key}, signature filename: {mul_sig_fname}")

    if '.nii' not in os.path.splitext(signature_fname)[-1]:
        print(signature_fname)
        signature_fname = convert_imggz_to_niigz_nib(signature_fname)

    # 3. resample space
    signature_img = image.load_img(signature_fname)
    resampled_nps = image.resample_img(signature_img,
                                    target_affine=stacked_singletrial.affine,
                                    target_shape=stacked_singletrial.shape[0:3],
                                    interpolation='nearest')

    # %% 4. apply signature
    nps_array = image.get_data(resampled_nps)
    singletrial_array = image.get_data(stacked_singletrial)
    len_singletrialstack = singletrial_array.shape[-1]
    vectorize_singletrial = singletrial_array.reshape(
        np.prod(list(singletrial_array.shape[0:3])), len_singletrialstack)
    nps_extract = np.dot(nps_array.reshape(-1), vectorize_singletrial)
    nps_df = pd.DataFrame({'singletrial_fname': [os.path.basename(
        basename) for basename in img_flist], signature_key: nps_extract})
    return nps_df