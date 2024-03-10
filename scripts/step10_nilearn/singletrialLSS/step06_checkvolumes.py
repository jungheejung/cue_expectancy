import os
from pathlib import Path

# Define the paths to the two directories
dir_path_nii_gz = Path('/Volumes/seagate/cue_singletrials/singletrial_rampupplateau')
dir_path_nii = Path('/Volumes/seagate/cue_singletrials/uncompressed_singletrial_rampupplateau')

# dir_path_nii_gz = Path('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue')
# dir_path_nii = Path('/Volumes/seagate/cue_singletrials/uncompressed_singletrial_rampupplateau')

# Function to collect all file paths in a directory, stripped of the root directory and file extension
# def get_relative_paths(directory, extension):
    
#     return {str(path.relative_to(directory)).rsplit(extension, 1)[0] for path in directory.rglob(f'*{extension}')}

# def get_relative_paths(directory, extension):
#     # Use rglob to find all matching files, then filter by filenames starting with 'sub-'
#     filtered_paths = {
#         str(path.relative_to(directory)).rsplit(extension, 1)[0]
#         for path in directory.rglob(f'*{extension}')
#         if path.name.startswith('sub-')
#     }
#     return filtered_paths
def get_relative_paths(directory, extension):
    filtered_paths = set()
    for path in directory.rglob(f'sub-*/*{extension}'):
        # Split the path into parts and filter based on your criteria
        if path.name.startswith('sub-'):
            relative_path = str(path.relative_to(directory)).rsplit(extension, 1)[0]
            filtered_paths.add(relative_path)
    return filtered_paths
# Collect relative paths and filenames without extensions
nii_gz_files = get_relative_paths(dir_path_nii_gz, '.nii.gz')
nii_files = get_relative_paths(dir_path_nii, '.nii')

# Compare the sets of relative paths
mismatch = nii_gz_files.symmetric_difference(nii_files)

if not mismatch:
    print("The directory structures and number of files match.")
else:
    print(f"Mismatch found in {len(mismatch)} file(s) or directories.")
    for item in mismatch:
        print(item)

# Optionally, you can check if the counts match directly (less detailed)
if len(nii_gz_files) == len(nii_files):
    print("The count of files in both directories is the same.")
else:
    print(f"The counts differ: .nii.gz={len(nii_gz_files)}, .nii={len(nii_files)}")
