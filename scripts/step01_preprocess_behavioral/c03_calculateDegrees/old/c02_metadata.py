import pandas as pd
import os

# vicarious ____________________________________________________________________
# import 3 datasets
main_dir = '/Users/h/Documents/projects_local/social_influence_analysis'
sublist = [1,2,3,4,5,6,7,8,9,10,11,12,15,16,19,25,26,27,28]
for ind,sub in enumerate(sublist):
    # for b_num in list(range(1,3)):
        coord_file = main_dir +'/boulder/rawbeh/sub-' + str(('%04d' % sub)) + '/beh/sub-' + str(('%04d' % sub)) + '_task-vicarious_beh_trajectory_formatted.csv'
        beh_file = main_dir + '/boulder/rawbeh/sub-' + str(('%04d' % sub)) + '/beh/sub-' + str(('%04d' % sub)) + '_task-vicarious_beh.csv'
        # counterbalance_file = main_dir + '/design/task-vicarious_counterbalance_ver-01_block-0' + str(b_num)  + '.csv'

        # read
        coord = pd.read_csv(coord_file)
        beh = pd.read_csv(beh_file)
        # counterbalance = pd.read_csv(counterbalance_file)

        # concat
        result = pd.concat([coord, beh ], axis=1, sort=False)
        result['src_subject_id'] = sub

        # save

        savefile_dir = main_dir + '/boulder/beh_withcoord/sub-'+ str(('%04d' % sub))
        if not os.path.exists(savefile_dir):
            os.makedirs(savefile_dir)
        savefilename = savefile_dir + os.sep + 'sub-' + str(('%04d' % sub)) +  '_task-vicarious_meta_beh.csv'
        result.to_csv(savefilename)


# cognitive ____________________________________________________________________
for ind,sub in enumerate(sublist):

        coord_file = main_dir +'/boulder/rawbeh/sub-' + str(('%04d' % sub)) + '/beh/sub-' + str(('%04d' % sub)) + '_task-cognitive_beh_trajectory_formatted.csv'
        beh_file = main_dir + '/boulder/rawbeh/sub-' + str(('%04d' % sub)) + '/beh/sub-' + str(('%04d' % sub)) + '_task-cognitive_beh.csv'
        # counterbalance_file = main_dir + '/design/task-cognitive_counterbalance_ver-01_block-01.csv'

        # read
        coord = pd.read_csv(coord_file)
        beh = pd.read_csv(beh_file)
        # counterbalance = pd.read_csv(counterbalance_file)

        # concat
        result = pd.concat([coord, beh ], axis=1, sort=False)
        result['src_subject_id'] = sub

        # save
        savefile_dir = main_dir + '/boulder/beh_withcoord/sub-'+ str(('%04d' % sub))
        if not os.path.exists(savefile_dir):
            os.makedirs(savefile_dir)
        savefilename = savefile_dir + os.sep + 'sub-' + str(('%04d' % sub))  + '_task-cognitive_meta_beh.csv'
        result.to_csv(savefilename)


# pain _________________________________________________________________________
# for ind,sub in enumerate([96]):
for ind,sub in enumerate([95,97]):
        coord_file = main_dir +'/data/sub-0' + str(sub) + '/beh/sub-0' + str(sub) + '_task-pain_beh_trajectory_formatted.csv'
        beh_file = main_dir + '/data/sub-0' + str(sub) + '/beh/sub-0' + str(sub) + '_task-pain_beh.csv'
        counterbalance_file = main_dir + '/design/task-pain_counterbalance_ver-01_block-01.csv'

        # read
        coord = pd.read_csv(coord_file)
        beh = pd.read_csv(beh_file)
        counterbalance = pd.read_csv(counterbalance_file)

        # concat
        result = pd.concat([counterbalance,coord, beh ], axis=1, sort=False)
        result['src_subject_id'] = sub

        # save
        savefile_dir = main_dir + '/data/sub-0'+ str(sub) + '/metadata'
        if not os.path.exists(savefile_dir):
            os.makedirs(savefile_dir)
        savefilename = savefile_dir + os.sep + 'sub-0' + str(sub) + '_task-pain_meta_beh.csv'
        result.to_csv(savefilename)
