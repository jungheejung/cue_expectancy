
import numpy as np
import os, glob, argparse, json
from os.path import join
from nilearn import image, masking, datasets

parser = argparse.ArgumentParser()
parser.add_argument("--main-dir", type=str,
                    help="specify slurm array id")
parser.add_argument("--slurm-id", type=int,
                    help="specify slurm array id")

args = parser.parse_args()
print(args.slurm_id)
main_dir = args.main_dir
slurm_id = args.slurm_id

# main_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue'
singletrial_dir = join(main_dir, 'analysis/fmri/nilearn/singletrial_rampupplateau')
save_discovery_dir= join(main_dir, 'analysis/fmri/nilearn/deriv02_parcel-NPS')

# glob files
subdirectories = sorted(glob.glob(join(singletrial_dir, "sub-*")))
flists = []
for subdir in subdirectories:
    sub = os.path.basename(subdir)
    flist = glob.glob(join(singletrial_dir, sub,
        f"{sub}_ses-*_run-*_runtype-*_event-stimulus_trial-*_cuetype-*.nii.gz"))
    flists.append(flist)

flattened_list = [item for sublist in flists for item in sublist]

mask_list = glob.glob(join(main_dir, '/data/atlas/nps*.nii'))
mask_fname = mask_list[slurm_id]
mask_img = image.load_img(mask_fname)  # Adjust path as necessary
mni_template = datasets.load_mni152_template(resolution=3) # load MNI
resampled_mask_mni = image.resample_to_img(mask_img, mni_template, interpolation='nearest')

masked_data_list = []

for img_path in flattened_list:
    img = image.load_img(img_path)
    resampled_nifti = image.resample_to_img(img, mni_template, interpolation='nearest')
    masked_data = masking.apply_mask(img, resampled_mask_mni)
    masked_data_list.append(masked_data)

save_fname = join(save_discovery_dir, os.path.splitext(mask_fname)[0] + '_event-stimulus.npy')
np.save(save_fname, masked_data_list)

metadata = {'filenames': [os.path.basename(fname) for fname in flattened_list]}

with open(join(save_discovery_dir,os.path.splitext(mask_fname)[0] + '_event-stimulus.json'), 'w') as file:
    json.dump(metadata, file, indent=4)