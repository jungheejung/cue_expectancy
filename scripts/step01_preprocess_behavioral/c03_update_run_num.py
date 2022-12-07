# %% NOTE: load modules
import pandas as pd
from os.path import join
import os, re, glob, sys
# TODO:
# [ ] beh_fname_num :: check behavioral filename. extract runnumber
# [ ] meta_num :: check metadata run number. extract list of runnumber
# [ ] beh_df_num :: if runnumber in behavioral file does not match metadata nor filename, update

# %%
beh_dir = '/Users/h/Dropbox/projects_dropbox/social_influence_analysis/data/beh/beh01_raw'
save_dir = '/Users/h/Dropbox/projects_dropbox/social_influence_analysis/data/beh/beh02_preproc'
flist = glob.glob(join(beh_dir, 'sub-*', '**', '*_beh.csv'))
orig_stdout = sys.stdout
f = open('./update_run_num_OUT.txt', 'w')
sys.stdout = f

# %% for behavioral files that start with session 4

def extract_bids_num(filename: str, key: str) -> int:
    """
    Extracts BIDS information based on input "key" prefix.
    If filename includes an extention, code will remove it.

    Parameters
    ----------
    filename: str
        acquisition filename
    key: str
        BIDS prefix, such as 'sub', 'ses', 'task'
    """
    bids_info = [match for match in filename.split('_') if key in match][0]
    # bids_info_rmext = os.path.splitext(bids_info)[0]
    bids_info_rmext = bids_info.split(os.extsep, 1)
    bids_num =  int(re.findall(r'\d+', bids_info_rmext[0] )[0].lstrip('0'))
    return bids_num
def extract_bids(filename: str, key: str) -> str:
    """
    Extracts BIDS information based on input "key" prefix.
    If filename includes an extention, code will remove it.

    Parameters
    ----------
    filename: str
        acquisition filename
    key: str
        BIDS prefix, such as 'sub', 'ses', 'task'
    """
    bids_info = [match for match in filename.split('_') if key in match][0]
    bids_info_rmext = bids_info.split(os.extsep, 1)
    # print(bids_info_rmext)
    # 'filename.ext1.ext2'.split(os.extsep, 1)
    # bids_info_rmext = os.path.splitext(bids_info)[0]
    return bids_info_rmext[0]

# %%
for beh_fpath in flist:
    beh_fname = os.path.basename(beh_fpath)
    # load behavioral dataframe and check dataframe number
    behdf = pd.read_csv(beh_fpath)
    # extract bids info
    beh_fname_num = extract_bids_num(beh_fname, 'run')
    behdf_num = behdf['param_run_num'].unique()[0]
    behdf_runtype = behdf['param_task_name'].unique()[0]
    sub = extract_bids(beh_fname, 'sub')
    ses = extract_bids(beh_fname, 'ses')
    behfname_runtype = extract_bids(beh_fname, 'run').split('-')[-1]
    print(f"---------------{sub} {ses} {behfname_runtype}---------------")
    # meta_num :: metadata extract run number list
    meta_fname = '/Users/h/Dropbox/projects_dropbox/social_influence_analysis/data/spacetop_task-social_run-metadata.csv'
    meta_df = pd.read_csv(meta_fname)
    subset_df = meta_df[(meta_df['sub'] == sub )& (meta_df['ses'] == ses)]
    run_list = subset_df.apply(lambda row: row[row == behfname_runtype].index.tolist(), axis=1)
    K = run_list.tolist()[0]
    meta_num = [int(i.split('-')[1]) for i in K]

    #  NOTE: [ ] is beh_fname in meta_num?
    if beh_fname_num in meta_num:
        print(f"Pass 1 SUCCESS: behavioral filename and metadata match")
    # [ ] does beh_fname_num match behdf_num
        if beh_fname_num != behdf_num:
            print(f"Pass 2 mismatch: need to harmonize")
            try:
                new_num = behdf_num + 3
                if beh_fname_num == new_num:
                    behdf['param_run_num'] = new_num
                    behdf.to_csv(join(save_dir, sub, ses, beh_fname))
                    print(f"--------- update complete ---------\n")
                else:

                    print(f"Pass 3 FAIL: adding + 3 doesn't solve the problem -- dig in deeper for {sub} {ses} {behfname_runtype} mismath: behfname is {beh_fname_num}, metadata is {meta_num}, dataframe is {behdf_num}")
            except:
                print(f"other error")
        else:
            print(f"Pass 2 SUCCESS: match")

    else:
        print(f"Pass 1 FAIL: {sub} {ses} {behfname_runtype} mismath: behfname is {beh_fname_num}, metadata is {meta_num}, dataframe is {behdf_num}")
        break

sys.stdout = orig_stdout
f.close()
# %%
