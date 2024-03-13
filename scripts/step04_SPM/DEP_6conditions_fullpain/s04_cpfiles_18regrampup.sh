#!/bin/bash

# Define the source and destination directories
source_dir="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/spm/univariate/model01_6cond_fullpain"
dest_dir="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/spm/univariate/model01_6cond_fullpain/1stlevel"

# Specify the pattern of files you want to copy
file_pattern="con*.nii"
#subdir_pattern="sub-01*"
contrast_names=(
    "P_VC_STIM_cue_high_gt_low" "V_PC_STIM_cue_high_gt_low"    "C_PV_STIM_cue_high_gt_low" 
    "P_VC_STIM_stimlin_high_gt_low"    "V_PC_STIM_stimlin_high_gt_low"    "C_PV_STIM_stimlin_high_gt_low" 
    "P_VC_STIM_stimquad_med_gt_other"    "V_PC_STIM_stimquad_med_gt_other" "C_PV_STIM_stimquad_med_gt_other" 
    "P_VC_STIM_cue_int_stimlin" "V_PC_STIM_cue_int_stimlin" "C_PV_STIM_cue_int_stimlin"
    "P_VC_STIM_cue_int_stimquad"    "V_PC_STIM_cue_int_stimquad"    "C_PV_STIM_cue_int_stimquad" 
    "motor" 
    "P_simple_STIM_cue_high_gt_low"       "V_simple_STIM_cue_high_gt_low"    "C_simple_STIM_cue_high_gt_low" 
    "P_simple_STIM_stimlin_high_gt_low"   "V_simple_STIM_stimlin_high_gt_low"    "C_simple_STIM_stimlin_high_gt_low" 
    "P_simple_STIM_stimquad_med_gt_other"   "V_simple_STIM_stimquad_med_gt_other"    "C_simple_STIM_stimquad_med_gt_other"
    "P_simple_STIM_cue_int_stimlin"       "V_simple_STIM_cue_int_stimlin"    "C_simple_STIM_cue_int_stimlin" 
    "P_simple_STIM_cue_int_stimquad"     "V_simple_STIM_cue_int_stimquad"   "C_simple_STIM_cue_int_stimquad" 
    "P_simple_STIM_highcue_highstim"     "P_simple_STIM_highcue_medstim"     "P_simple_STIM_highcue_lowstim" 
    "P_simple_STIM_lowcue_highstim"     "P_simple_STIM_lowcue_medstim"   "P_simple_STIM_lowcue_lowstim"
    "V_simple_STIM_highcue_highstim"     "V_simple_STIM_highcue_medstim"     "V_simple_STIM_highcue_lowstim" 
    "V_simple_STIM_lowcue_highstim"      "V_simple_STIM_lowcue_medstim"     "V_simple_STIM_lowcue_lowstim"
    "C_simple_STIM_highcue_highstim"    "C_simple_STIM_highcue_medstim"  "C_simple_STIM_highcue_lowstim" 
    "C_simple_STIM_lowcue_highstim"    "C_simple_STIM_lowcue_medstim"    "C_simple_STIM_lowcue_lowstim" 
    "P_VC_CUE_cue_high_gt_low"  "V_PC_CUE_cue_high_gt_low"  "C_PV_CUE_cue_high_gt_low" 
    "P_simple_CUE_cue_high_gt_low"  "V_simple_CUE_STIM_cue_high_gt_low"  "C_simple_CUE_cue_high_gt_low" 
    "G_simple_CUE_cue_high_gt_low" 
    "P_VC_STIM"  "V_PC_STIM"     "C_PV_STIM" 
)




# Loop through subdirectories in the source directory
for subdir in "$source_dir"/sub-*; do
    if [ -d "$subdir" ]; then
        subdir_name=$(basename "$subdir")
        mkdir -p "$dest_dir/$subdir_name"

        # Loop through con*.nii files in the current subdirectory
        for file in "$subdir"/con*.nii; do
            if [ -f "$file" ]; then
                filename=$(basename "$file")
                
                # Extract the numeric index from the filename, assuming it follows 'con' and precedes '.nii'
                index=$(echo "$filename" | grep -oP 'con_\K\d+')
                
                # Check if index extraction was successful
                if [ ! -z "$index" ]; then
                    # Convert the zero-padded index to a regular integer to avoid base conversion errors
                    index=$((10#$index))
                    
                    # Adjust for zero-based indexing in contrast_names array
                    contrast_name="${contrast_names[$((index-1))]}"
                    
                    # Extract the base filename without extension
                    base_filename=$(echo "$filename" | sed 's/\(.*\)\.nii/\1/')
                    
                    # Construct the new filename with contrast name inserted before the extension
                    new_name="${subdir_name}_${base_filename}_${contrast_name}.nii"
                    
                    # Copy and rename the file
                    cp "$file" "$dest_dir/$subdir_name/$new_name"
                    echo "Copied $file to $dest_dir/$subdir_name/$new_name"
                else
                    echo "Failed to extract index from $filename"
                fi
            fi
        done
    fi
done


echo "Done!"

