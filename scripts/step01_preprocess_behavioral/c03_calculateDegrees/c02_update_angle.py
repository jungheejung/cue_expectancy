# %%
import pandas as pd
import os, re
import glob
import ntpath
import numpy as np

"""
c01_extract_xycoord.m
after extracting x, y coordinates,
This code converts cartesian coordinates into angle and radians.
If radians are greater than 
"""
# __author__ = "Heejung Jung"
# __version__ = "1.0.1"
# __email__ = "heejung.jung@colorado.edu"
# __status__ = "Production"
# TODO:
# 1. calculate angle
# if angle > 0
# insert it into 

# EXPECT:
# - event02_expect_angle = angle
# - event02_expect_responseonset = event04_actual_displayonset + 4
# - event02_expect_RT = 4.0

# ACTUAL: 
# - event04_actual_angle = angle
# - event04_actual_responseonset = event04_actual_displayonset + 4
# - event04_actual_RT = 4.0

# %%
#  filepath:
# /Users/h/Documents/projects_local/social_influence_analysis/data/dartmouth/d02_preprocessed/sub-0060/ses-01
# sub-0060_ses-01_task-social_run-06-pain_trajectory_formatted.csv

# %% functions ____________________________________________________________________
def cart2pol(x, y):
    rho = np.sqrt(x**2 + y**2)
    phi = np.arctan2(y, x)
    return(rho, phi)
    
origin_x = 960
origin_y = 707

# %%
main_dir = '/Users/h/Documents/projects_local/social_influence_analysis'
data_dir = os.path.join(main_dir, 'data', 'dartmouth', 'd02_preprocessed')
sub_list = sorted(next(os.walk(data_dir))[1])
ses_list = [1,3,4]
for sub in sub_list:
    for ses in ses_list:
    # TODO: 
    # load sub-0060_ses-01_task-social_run-06-pain_beh
    # load sub-0060_ses-01_task-social_run-02-vicarious_trajectory_formatted
        
        run_list = glob.glob(os.path.join(data_dir, sub, 'ses-{0:02d}'.format(ses), '*run*_trajectory_formatted.csv'))
        for run in run_list:
            data = pd.DataFrame(); newdata = pd.DataFrame();
            run_str = re.findall(r'\b\d+\b', run)[2] # '05'
            # print("{0}_ses{1}_run-{2}".format(sub,ses,run_str))
            # print("filepath: {0}".format(run))

            data = pd.read_csv(run) #'fullfilepath'
            fname = os.path.basename(run)

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
            # new_dir = os.path.join(main_dir, 'dartmouth', 'beh_raw', 'sub-{0}'.format(num[0]), 'ses-{0}'.format(num[1]))
            # new_filename = 'sub-{0}_ses-{1:02d}_task-social_run-{2}-{3}_beh.csv'.format(sub,ses, run_str, taskname)
            beh_fname = glob.glob(os.path.join(data_dir, sub, 'ses-{0:02d}'.format(ses),'{0}_ses-{1:02d}_task-social_run-{2}-*_beh.csv'.format(sub,ses,run_str)))
            newdata = pd.read_csv(beh_fname[0])
            print("new_filename: {0}".format(beh_fname[0]))

            # mask = data.actual_radians > 0
            newdata.loc[data.actual_radians > 0, 'event04_actual_angle'] = 180*data.actual_radians/np.pi;
            newdata.loc[data.expect_radians > 0, 'event02_expect_angle'] = 180*data.expect_radians/np.pi;

            # newdata.event04_actual_angle = 180*data.actual_radians/np.pi;
            # newdata.event02_expect_angle = 180*data.expect_radians/np.pi;
            newdata.drop(newdata.filter(regex="Unname"),axis=1, inplace=True)
            newdata.to_csv(beh_fname[0], index=False)




            # data = pd.read_csv(os.path.join(data_dir, sub_list[1], 'ses-01', )
# %%
# list_sub = [3,4];list_ses = [1];list_task = ['cognitive', 'pain', 'vicarious']
# fix_file_list = [];

# sub_list  
# for ind,sub in enumerate(list_sub):
#     for task in list_task:
#         raw_dir = os.path.join(main_dir, 'data', 'dartmouth', 'd02_preprocessed',
#         'sub-{:04d}'.format(sub), 'ses-{:02d}'.format(ses))
#         csv_name = '*'+task+'*_formatted.csv'
#         files = glob.glob(os.path.join(raw_dir,csv_name))
#         fix_file_list.append(files)

# flat_list = [item for sub_list in fix_file_list for item in sub_list]



# # for loop compiled list ____________________________________________________________________
# for filepath in flat_list:
#     data = pd.DataFrame(); newdata = pd.DataFrame();
#     print("filepath: {0}".format(filepath))
#     filename = ntpath.basename(filepath)
#     num = re.findall('\d+', filename)
#     print("numbers: {0}".format(num))
#     data = pd.read_csv(filepath)

#     r = re.compile(".*run")
#     task_string = list(filter(r.match, filename.split("_")))
#     taskname = task_string[0].split("-")[2]
#     print("taskname: {0}".format(taskname))

#     # convert cartisian coordinates to polar coordinates
#     for index, row in data.iterrows():
#         actual_angle = []
#         if row.actual_ptb_coord_x >= origin_x:
#             data.loc[index, 'actual_radians'] = np.pi-np.arctan((origin_y - row.actual_ptb_coord_y )/(row.actual_ptb_coord_x-origin_x))
#         else:
#             data.loc[index, 'actual_radians'] = np.arctan((origin_y-row.actual_ptb_coord_y)/(origin_x-row.actual_ptb_coord_x))

#     for index, row in data.iterrows():
#         expect_angle = []
#         if row.expect_ptb_coord_x >= origin_x:
#             data.loc[index, 'expect_radians'] = np.pi-np.arctan((origin_y - row.expect_ptb_coord_y )/(row.expect_ptb_coord_x-origin_x))
#         else:
#             data.loc[index, 'expect_radians'] = np.arctan((origin_y-row.expect_ptb_coord_y)/(origin_x-row.expect_ptb_coord_x))

# # based on expected x and y, calculate theta
# # extract names
# # insert it in
#     new_dir = os.path.join(main_dir, 'dartmouth', 'beh_raw', 'sub-{0}'.format(num[0]), 'ses-{0}'.format(num[1]))
#     new_filename = 'sub-{0}_ses-{1}_task-social_run-{2}-{3}_beh.csv'.format(num[0], num[1], num[2], taskname)
#     newdata = pd.read_csv(os.path.join(new_dir, new_filename))
#     print("new_filename: {0}".format(new_filename))
#     newdata.event04_actual_angle = 180*data.actual_radians/np.pi;
#     newdata.event02_expect_angle = 180*data.expect_radians/np.pi;
#     newdata.drop(newdata.filter(regex="Unname"),axis=1, inplace=True)
#     newdata.to_csv(os.path.join(new_dir, new_filename), index=False)
