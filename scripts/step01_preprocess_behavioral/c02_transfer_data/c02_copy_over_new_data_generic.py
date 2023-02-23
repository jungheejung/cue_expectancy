# %%
import glob, os, re, shutil
from pathlib import Path
import filecmp
from os.path import join

# TODO:
# identify data existing in d02_preprocessed
# cross check and copy over only that doesn't exist in d02_preprocessed
# %%
# USER INPUT (MAKE THIS INTO ARGS ARGUMENTS)
current_dir = os.getcwd()
analysis_repo_dir = '/Users/h/Dropbox/projects_dropbox/other_sideprojects/narrative'
data_repo_dir = "/Users/h/Dropbox/projects_dropbox/d_beh" # USER, INSERT PATH
task_name = 'task-narratives'


"""
search for folder named d_beh
copy /Users/h/Dropbox/projects_dropbox/d_beh/sub-0001/task-social
into /Users/h/Documents/projects_local/social_influence_analysis/data/dartmouth/d01_rawbeh
"""

src = sorted(glob.glob(os.path.join(data_repo_dir, 'sub-*', task_name,'*.csv')))
src2 = sorted(glob.glob(os.path.join(data_repo_dir, 'sub-*', task_name, '*.mat')))
for i in src2 :
    src.append(i)
# %%
for ind, src_fname in enumerate(src):

    num = re.findall('\d+', src[ind])
    print("sub: {0}, session: {1}".format(num[0], num[1]))
    dst_fname = os.path.join( analysis_repo_dir, 'data', 'beh01_raw', 'sub-'+num[0], 'ses-'+num[1])
    dst_fname2 = os.path.join( analysis_repo_dir, 'data','beh', 'beh02_preproc', 'sub-'+num[0], 'ses-'+num[1])
    behavioral_fname = glob.glob(os.path.join(dst_fname, '*_beh.csv'))
    # if os.path.exists(dst_fname):
    # if behavioral_fname:
    #     print("copy exists")
    # else:
    fbase = os.path.basename(src_fname)
    if not os.path.exists(join(dst_fname2, fbase)) or not filecmp.cmp(src_fname, join(dst_fname2, fbase)):
        # d01_path = Path(dst_fname)
        Path(dst_fname).mkdir(parents = True, exist_ok = True)
        Path(dst_fname2).mkdir(parents = True, exist_ok = True)
        shutil.copy(src_fname, dst_fname)
        shutil.copy(src_fname, dst_fname2)

# %%
