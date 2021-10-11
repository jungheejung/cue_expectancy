import pandas as pd
import os, re
import pathlib, glob
import ntpath
import numpy as np
# if filename has keyword - vicarious
list_sub = [18,23,25]
main_dir = '/Users/h/Documents/projects_local/d_beh'
fix_file_list = []
for ind,sub in enumerate(list_sub):

    raw_dir = os.path.join(main_dir, 'sub-{:04d}'.format(sub),
    'task-social')
    csv_name = '*vicarious_beh.csv'
    files = glob.glob(os.path.join(raw_dir,'*',csv_name))
    fix_file_list.append(files)
flat_list = [item for sub_list in fix_file_list for item in sub_list]

# load and insert "vicarious" to param_task_name
for filepath in flat_list:
    data = pd.DataFrame();
    #print("filepath: {0}".format(filepath))
    #filename = ntpath.basename(filepath)
    #num = re.findall('\d+', filename)
    #print("numbers: {0}".format(num))
    data = pd.read_csv(filepath)
    data['param_task_name'] = 'vicarious'
    data.drop(data.filter(regex="Unname"),axis=1, inplace=True)
    data.to_csv(filepath, index=False)
