# %%
import re
import glob
from os.path import join

folder_path = '/Volumes/spacetop_projects_cue/scripts/step04_SPM/6conditions/log_con'
pattern = r"sub-(\d+)"

# Get a list of log file paths in the folder
log_files = glob.glob(join(folder_path, 'contrast_6530783_*.e'))
failed_sub = []
failed_fname = []
for log_file in log_files:
    with open(log_file, 'r') as file:
        file_contents = file.read()
        
        # Search for the error message pattern in the file contents
        if "Error using load\nUnable to read file" in file_contents:
            match = re.search(pattern, file_contents)
            
            if match:
                sub_id = match.group(1)
                print(f"Subject ID in {log_file}: {sub_id}")
                failed_sub.append(f"sub-{sub_id}")
                failed_fname.append(log_file)
                # Perform additional actions as needed
            else:
                print(f"Subject ID not found in {log_file}")
        else:
            print(f"No error message found in {log_file}")

# %%
# June 7 2023
# failed participants:
['sub-0016',
 'sub-0017',
 'sub-0025',
 'sub-0029',
 'sub-0030',
 'sub-0031',
 'sub-0040',
 'sub-0043',
 'sub-0050',
 'sub-0051',
 'sub-0053',
 'sub-0055',
 'sub-0058',
 'sub-0059',
 'sub-0070',
 'sub-0079',
 'sub-0081',
 'sub-0082',
 'sub-0090',
 'sub-0092',
 'sub-0094',
 'sub-0097',
 'sub-0100',
 'sub-0102',
 'sub-0111',
 'sub-0114',
 'sub-0118',
 'sub-0122',
 'sub-0127']

['/Volumes/spacetop_projects_cue/scripts/step04_SPM/6conditions/log_con/contrast_6530783_3.e',
 '/Volumes/spacetop_projects_cue/scripts/step04_SPM/6conditions/log_con/contrast_6530783_4.e',
 '/Volumes/spacetop_projects_cue/scripts/step04_SPM/6conditions/log_con/contrast_6530783_5.e',
 '/Volumes/spacetop_projects_cue/scripts/step04_SPM/6conditions/log_con/contrast_6530783_8.e',
 '/Volumes/spacetop_projects_cue/scripts/step04_SPM/6conditions/log_con/contrast_6530783_9.e'
 '/Volumes/spacetop_projects_cue/scripts/step04_SPM/6conditions/log_con/contrast_6530783_10.e',
 '/Volumes/spacetop_projects_cue/scripts/step04_SPM/6conditions/log_con/contrast_6530783_18.e',
 '/Volumes/spacetop_projects_cue/scripts/step04_SPM/6conditions/log_con/contrast_6530783_20.e',
 '/Volumes/spacetop_projects_cue/scripts/step04_SPM/6conditions/log_con/contrast_6530783_23.e',
 '/Volumes/spacetop_projects_cue/scripts/step04_SPM/6conditions/log_con/contrast_6530783_24.e',
 '/Volumes/spacetop_projects_cue/scripts/step04_SPM/6conditions/log_con/contrast_6530783_25.e',
 '/Volumes/spacetop_projects_cue/scripts/step04_SPM/6conditions/log_con/contrast_6530783_26.e',
 '/Volumes/spacetop_projects_cue/scripts/step04_SPM/6conditions/log_con/contrast_6530783_29.e',
 '/Volumes/spacetop_projects_cue/scripts/step04_SPM/6conditions/log_con/contrast_6530783_30.e',
 '/Volumes/spacetop_projects_cue/scripts/step04_SPM/6conditions/log_con/contrast_6530783_38.e',
 '/Volumes/spacetop_projects_cue/scripts/step04_SPM/6conditions/log_con/contrast_6530783_46.e',
 '/Volumes/spacetop_projects_cue/scripts/step04_SPM/6conditions/log_con/contrast_6530783_48.e',
 '/Volumes/spacetop_projects_cue/scripts/step04_SPM/6conditions/log_con/contrast_6530783_49.e',
 '/Volumes/spacetop_projects_cue/scripts/step04_SPM/6conditions/log_con/contrast_6530783_55.e',
 '/Volumes/spacetop_projects_cue/scripts/step04_SPM/6conditions/log_con/contrast_6530783_56.e',
 '/Volumes/spacetop_projects_cue/scripts/step04_SPM/6conditions/log_con/contrast_6530783_58.e',
 '/Volumes/spacetop_projects_cue/scripts/step04_SPM/6conditions/log_con/contrast_6530783_60.e',
 '/Volumes/spacetop_projects_cue/scripts/step04_SPM/6conditions/log_con/contrast_6530783_63.e',
 '/Volumes/spacetop_projects_cue/scripts/step04_SPM/6conditions/log_con/contrast_6530783_65.e',
 '/Volumes/spacetop_projects_cue/scripts/step04_SPM/6conditions/log_con/contrast_6530783_71.e',
 '/Volumes/spacetop_projects_cue/scripts/step04_SPM/6conditions/log_con/contrast_6530783_72.e',
 '/Volumes/spacetop_projects_cue/scripts/step04_SPM/6conditions/log_con/contrast_6530783_75.e',
 '/Volumes/spacetop_projects_cue/scripts/step04_SPM/6conditions/log_con/contrast_6530783_78.e',
 '/Volumes/spacetop_projects_cue/scripts/step04_SPM/6conditions/log_con/contrast_6530783_82.e',
]