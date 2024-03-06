import os, glob
from os.path import join

# Specify the directory containing your files
# directory = '/path/to/your/files'
singletrial_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupplateau'
# Path(output_dir).mkdir( parents=True, exist_ok=True )
sub_folders = next(os.walk(singletrial_dir))[1]
print(sub_folders)
sub_list = [i for i in sorted(sub_folders) if i.startswith('sub-')]
# Iterate over files in the specified directory
for sub in sorted(sub_list):
    # Check if the filename matches the expected pattern
    # if filename.startswith("sub-") and filename.endswith(".nii.gz"):
    for filename in os.listdir(join(singletrial_dir, sub)):
        if filename.startswith("sub-") and filename.endswith(".nii.gz"):
            # Construct the new filename
            parts = filename.split("_", 3)  # Split into 3 parts: [sub-xxxx, ses-xx, the rest...]
            new_filename = f"{parts[0]}_{parts[1]}_{parts[2]}_task-cue_{parts[3]}"
            
            # Construct full file paths
            old_file_path = join(singletrial_dir, sub, filename)
            new_file_path = join(singletrial_dir, sub, new_filename)
            
            # Rename the file
            # os.rename(old_file_path, new_file_path)
            print(f"Renamed '{filename}' to '{new_filename}'")

print("Filename update complete.")
