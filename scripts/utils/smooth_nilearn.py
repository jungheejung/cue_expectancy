import os, glob
import argparse
import nibabel as nib
from nilearn import image
from pathlib import Path

"""
This code smooths a single trial betamap and unzips it
"""
# 0. argparse ________________________________________________________________________________
parser = argparse.ArgumentParser()
parser.add_argument("--sub", type=str,
                    help="specify slurm array id")
args = parser.parse_args()
sub = args.sub # e.g. 1, 2


# Define the input and output folders
input_folder = f'/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial/{sub}'
output_folder = '/dartfs-hpc/scratch/f0042x1/singletrial_smooth'

# Specify the FWHM for smoothing (e.g., 6mm)
fwhm = 6.0

# Create the output folder if it doesn't exist
os.makedirs(output_folder, exist_ok=True)

# Iterate through files in the input folder
for root, dirs, files in os.walk(input_folder):
    for filename in files:
        if filename.endswith('.nii.gz'):
            input_filepath = os.path.join(root, filename)
            
            # Load the NIfTI image
            img = nib.load(input_filepath)
            
            # Smooth the image
            smoothed_img = image.smooth_img(img, fwhm)
            
            # Create a new filename with the "smooth-6mm_" prefix
            base_filename = os.path.splitext(filename)[0]
            new_filename = f'smooth-{int(fwhm)}mm_{base_filename}'
            print(new_filename)
            
            # Specify the output path
            output_subfolder = os.path.join(output_folder, sub)
            Path(output_subfolder).mkdir(exist_ok=True, parents=True)
            output_filepath = os.path.join(output_subfolder, new_filename)
            
            # Save the smoothed image
            nib.save(smoothed_img, output_filepath)
            print(f'Saved: {output_filepath}')
print(f"complete {sub}")

