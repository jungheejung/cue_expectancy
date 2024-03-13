from nilearn import plotting

# Load the NIfTI image using nibabel
import nibabel as nib
img = nib.load('my_image.nii.gz')

# Use plot_stat_map to plot the image
plotting.plot_stat_map(img)
