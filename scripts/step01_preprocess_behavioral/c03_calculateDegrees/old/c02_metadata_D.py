import pandas as pd
import os
import glob

# vicarious ____________________________________________________________________
# import 3 datasets
main_dir = '/Users/h/Documents/projects_local/social_influence_analysis'
sublist = [3,4]
ses = 1
taskname = ['pain', 'vicarious', 'cognitive']

for ind,sub in enumerate(sublist):
    for task in taskname:
    # for b_num in list(range(1,3)):
        metadata = []
        for blk in range(2):
            coord_file = glob.glob(os.path.join(main_dir ,'dartmouth', 'rawbeh',
            'sub-'+str(('%04d' % int(sub))), 'task-social','ses-'+str('%02d' % ses),
            'sub-'+str(('%04d' % int(sub)))+'_ses-'+str(('%02d' % ses))+ '_task-social*-' + task + '*_formatted.csv'))
            # print(coord_file)
            beh_file =glob.glob(os.path.join(main_dir ,'dartmouth', 'rawbeh',
            'sub-'+str(('%04d' % int(sub))), 'task-social','ses-'+str('%02d' % ses),
            'sub-'+str(('%04d' % int(sub)))+'_ses-'+str(('%02d' % ses))+ '_task-social*-' + task + '*_beh.csv'))
            # read
            coord = pd.read_csv(coord_file[blk])
            beh = pd.read_csv(beh_file[blk])

            # concat
            result = pd.concat([coord, beh ], axis=1, sort=False)
            result['src_subject_id'] = sub
            result['block'] = blk
            metadata.append(result)

        appended_metadata = pd.concat(metadata)
        # save
        savefile_dir = main_dir + '/dartmouth/beh_withcoord/sub-'+ str(('%04d' % sub))
        if not os.path.exists(savefile_dir):
            os.makedirs(savefile_dir)
        savefilename = os.path.join(savefile_dir ,'sub-' + str(('%04d' % sub)) + '_ses-'+str(('%02d' % ses))+ '_task-'+task+'_meta_beh.csv')
        appended_metadata.to_csv(savefilename, index = False)

#
# # cognitive ____________________________________________________________________
# for ind,sub in enumerate(sublist):
#
#         coord_file = main_dir +'/dartmouth/rawbeh/sub-' + str(('%04d' % sub)) + '/beh/sub-' + str(('%04d' % sub)) + '_task-cognitive_beh_trajectory_formatted.csv'
#         beh_file = main_dir + '/dartmouth/rawbeh/sub-' + str(('%04d' % sub)) + '/beh/sub-' + str(('%04d' % sub)) + '_task-cognitive_beh.csv'
#         # counterbalance_file = main_dir + '/design/task-cognitive_counterbalance_ver-01_block-01.csv'
#
#         # read
#         coord = pd.read_csv(coord_file)
#         beh = pd.read_csv(beh_file)
#         # counterbalance = pd.read_csv(counterbalance_file)
#
#         # concat
#         result = pd.concat([coord, beh ], axis=1, sort=False)
#         result['src_subject_id'] = sub
#
#         # save
#         savefile_dir = main_dir + '/dartmouth/beh_withcoord/sub-'+ str(('%04d' % sub))
#         if not os.path.exists(savefile_dir):
#             os.makedirs(savefile_dir)
#         savefilename = savefile_dir + os.sep + 'sub-' + str(('%04d' % sub))  + '_task-cognitive_meta_beh.csv'
#         result.to_csv(savefilename, index = False)
#
#
# # pain _________________________________________________________________________
# # for ind,sub in enumerate([96]):
# for ind,sub in enumerate([95,97]):
#         coord_file = main_dir +'/data/sub-0' + str(sub) + '/beh/sub-0' + str(sub) + '_task-pain_beh_trajectory_formatted.csv'
#         beh_file = main_dir + '/data/sub-0' + str(sub) + '/beh/sub-0' + str(sub) + '_task-pain_beh.csv'
#         counterbalance_file = main_dir + '/design/task-pain_counterbalance_ver-01_block-01.csv'
#
#         # read
#         coord = pd.read_csv(coord_file)
#         beh = pd.read_csv(beh_file)
#         counterbalance = pd.read_csv(counterbalance_file)
#
#         # concat
#         result = pd.concat([counterbalance,coord, beh ], axis=1, sort=False)
#         result['src_subject_id'] = sub
#
#         # save
#         savefile_dir = main_dir + '/data/sub-0'+ str(sub) + '/metadata'
#         if not os.path.exists(savefile_dir):
#             os.makedirs(savefile_dir)
#         savefilename = savefile_dir + os.sep + 'sub-0' + str(sub) + '_task-pain_meta_beh.csv'
#         result.to_csv(savefilename, index = False)
