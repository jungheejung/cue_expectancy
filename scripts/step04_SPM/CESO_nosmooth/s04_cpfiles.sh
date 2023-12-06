#!/bin/bash

# Define the source and destination directories
source_dir="/dartfs-hpc/scratch/f0042x1/spm/model02_CESO_nosmooth"
dest_dir="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/spm/univariate/model02_CESO_nosmooth/1stlevel"

# Specify the pattern of files you want to copy
file_pattern="*"
#subdir_pattern="sub-01*"


# For each subdirectory in source_dir
for subdir in "${source_dir}"/sub-*; do
    # If it's a directory
    if [ -d "$subdir" ]; then
        # Extract the subdirectory name
        subdir_name=$(basename "$subdir")

        # Create the corresponding subdirectory in dest_dir
        mkdir -p "$dest_dir/$subdir_name"

        # Copy files matching the file_pattern from the source subdirectory to the destination subdirectory and rename them
        for file in "$subdir"/$file_pattern; do
            if [ -f "$file" ]; then
                # Extract the filename without path
                filename=$(basename "$file")
                
                # Construct the new name
                new_name="${subdir_name}_${filename}"
                
                # Copy and rename
                cp "$file" "$dest_dir/$subdir_name/$new_name"
                echo "Copied $file to $dest_dir/$subdir_name/$new_name"
            fi
        done
    fi
done


echo "Done!"

