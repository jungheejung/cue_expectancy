import glob, os, re, shutil
from pathlib import Path

# TODO:
# identify data existing in d02_preprocessed
# cross check and copy over only that doesn't exist in d02_preprocessed

current_dir = os.getcwd()
analysis_repo_dir = Path(current_dir).parents[2]
data_repo_dir = "/Users/h/Documents/projects_local/d_beh" # USER, INSERT PATH


"""
search for folder named d_beh
copy /Users/h/Documents/projects_local/d_beh/sub-0001/task-social
into /Users/h/Documents/projects_local/social_influence_analysis/data/dartmouth/d01_beh_raw
"""


src = glob.glob(os.path.join(data_repo_dir, 'sub-*', 'task-social', 'ses-*'))
for ind, src_fname in enumerate(src):

    num = re.findall('\d+', src[ind])
    print("sub: {0}, session: {1}".format(num[0], num[1]))
    dst_fname = os.path.join( analysis_repo_dir, 'data', 'dartmouth', 'd01_beh_raw', 'sub-'+num[0], 'ses-'+num[1])
    if os.path.exists(dst_fname):
        print("folder exists")
    else:
        shutil.copytree(src_fname, dst_fname)
