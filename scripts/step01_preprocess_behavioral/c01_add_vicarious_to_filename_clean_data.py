import pandas as pd
import os, re
import pathlib, glob
import ntpath
import numpy as np
# if filename has keyword - vicarious

# TODO: 
# 1. get subject list
# 2. remove unwanted participants e.g. 0999
# 3. run script
list_sub = list(range(107))
main_dir = '/Users/h/Dropbox/projects_dropbox/d_beh'
fix_file_list = []
items_to_remove = [1, 26 ]
for item in items_to_remove:
    if item in list_sub:
        list_sub.remove(item)
sub_list = sorted(list_sub)

for ind,sub in enumerate(sub_list):

    raw_dir = os.path.join(main_dir, 'sub-{:04d}'.format(sub),
    'task-social')
    csv_name = '*vicarious_beh.csv'
    files = glob.glob(os.path.join(raw_dir,'*',csv_name))
    fix_file_list.append(files)
flat_list = [item for sub_list in fix_file_list for item in sub_list]

# load and insert "vicarious" to param_task_name
if flat_list:
    for filepath in flat_list:
        data = pd.DataFrame();
        data = pd.read_csv(filepath)
        data['param_task_name'] = 'vicarious'
        data.drop(data.filter(regex="Unname"),axis=1, inplace=True)
        data.to_csv(filepath, index=False)
