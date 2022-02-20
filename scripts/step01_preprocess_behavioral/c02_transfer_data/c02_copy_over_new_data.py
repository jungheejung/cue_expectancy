# %%
import glob, os, re, shutil
from pathlib import Path
import filecmp
from os.path import join

# TODO:
# identify data existing in d02_preprocessed
# cross check and copy over only that doesn't exist in d02_preprocessed
# %%
current_dir = os.getcwd()
analysis_repo_dir = Path(current_dir).parents[2]
data_repo_dir = "/Users/h/Dropbox/projects_dropbox/d_beh" # USER, INSERT PATH


"""
search for folder named d_beh
copy /Users/h/Dropbox/projects_dropbox/d_beh/sub-0001/task-social
into /Users/h/Documents/projects_local/social_influence_analysis/data/dartmouth/d01_rawbeh
"""


src = sorted(glob.glob(os.path.join(data_repo_dir, 'sub-*', 'task-social', 'ses-*', '*.csv')))
# %%
for ind, src_fname in enumerate(src):

    num = re.findall('\d+', src[ind])
    print("sub: {0}, session: {1}".format(num[0], num[1]))
    dst_fname = os.path.join( analysis_repo_dir, 'data', 'dartmouth', 'd01_rawbeh', 'sub-'+num[0], 'ses-'+num[1])
    dst_fname2 = os.path.join( analysis_repo_dir, 'data', 'dartmouth', 'd02_preprocessed', 'sub-'+num[0], 'ses-'+num[1])
    behavioral_fname = glob.glob(os.path.join(dst_fname, '*_beh.csv'))
    # if os.path.exists(dst_fname):
    # if behavioral_fname:
    #     print("copy exists")
    # else:
    fbase = os.path.basename(src_fname)
    if not os.path.exists(join(dst_fname2, fbase)) or not filecmp.cmp(src_fname, join(dst_fname2, fbase)):
        shutil.copy(src_fname, dst_fname)
        shutil.copy(src_fname, dst_fname2)

# %%
