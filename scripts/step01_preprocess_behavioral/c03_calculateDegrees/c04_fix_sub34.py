import pandas as pd
import os, re
import pathlib, glob
import ntpath
import numpy as np

# vicarious ____________________________________________________________________
def cart2pol(x, y):
    rho = np.sqrt(x**2 + y**2)
    phi = np.arctan2(y, x)
    return(rho, phi)
origin_x = 960
origin_y = 707

main_dir = '/Users/h/Documents/projects_local/social_influence_analysis'
list_sub = [3,4];list_ses = [1];list_task = ['cognitive', 'pain', 'vicarious']
fix_file_list = [];ses = 1
for ind,sub in enumerate(list_sub):
    for task in list_task:
        raw_dir = os.path.join(main_dir, 'dartmouth', 'rawbeh',
        'sub-{:04d}'.format(sub), 'task-social', 'ses-{:02d}'.format(ses))
        csv_name = '*'+task+'*_formatted.csv'
        files = glob.glob(os.path.join(raw_dir,csv_name))
        fix_file_list.append(files)

flat_list = [item for sub_list in fix_file_list for item in sub_list]


# for loop compiled list ____________________________________________________________________
for filepath in flat_list:
    data = pd.DataFrame(); newdata = pd.DataFrame();
    print("filepath: {0}".format(filepath))
    filename = ntpath.basename(filepath)
    num = re.findall('\d+', filename)
    print("numbers: {0}".format(num))
    data = pd.read_csv(filepath)

    r = re.compile(".*run")
    task_string = list(filter(r.match, filename.split("_")))
    taskname = task_string[0].split("-")[2]
    print("taskname: {0}".format(taskname))

    # convert cartisian coordinates to polar coordinates
    for index, row in data.iterrows():
        actual_angle = []
        if row.actual_ptb_coord_x >= origin_x:
            data.loc[index, 'actual_radians'] = np.pi-np.arctan((origin_y - row.actual_ptb_coord_y )/(row.actual_ptb_coord_x-origin_x))
        else:
            data.loc[index, 'actual_radians'] = np.arctan((origin_y-row.actual_ptb_coord_y)/(origin_x-row.actual_ptb_coord_x))

    for index, row in data.iterrows():
        expect_angle = []
        if row.expect_ptb_coord_x >= origin_x:
            data.loc[index, 'expect_radians'] = np.pi-np.arctan((origin_y - row.expect_ptb_coord_y )/(row.expect_ptb_coord_x-origin_x))
        else:
            data.loc[index, 'expect_radians'] = np.arctan((origin_y-row.expect_ptb_coord_y)/(origin_x-row.expect_ptb_coord_x))

# based on expected x and y, calculate theta
# extract names
# insert it in
    new_dir = os.path.join(main_dir, 'dartmouth', 'beh_raw', 'sub-{0}'.format(num[0]), 'ses-{0}'.format(num[1]))
    new_filename = 'sub-{0}_ses-{1}_task-social_run-{2}-{3}_beh.csv'.format(num[0], num[1], num[2], taskname)
    newdata = pd.read_csv(os.path.join(new_dir, new_filename))
    print("new_filename: {0}".format(new_filename))
    newdata.event04_actual_angle = 180*data.actual_radians/np.pi;
    newdata.event02_expect_angle = 180*data.expect_radians/np.pi;
    newdata.drop(newdata.filter(regex="Unname"),axis=1, inplace=True)
    newdata.to_csv(os.path.join(new_dir, new_filename), index=False)
