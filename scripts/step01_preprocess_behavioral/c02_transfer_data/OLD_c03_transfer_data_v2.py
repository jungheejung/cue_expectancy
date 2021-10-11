import glob, os, re, shutil
# search for folder named d_beh
# copy /Users/h/Documents/projects_local/d_beh/sub-0001/task-social
# into    /Users/h/Documents/projects_local/social_influence_analysis/rawbeh

past_sub = [2,3,4,5,6,7,8,9,10,11,13,14,15,16,17,18,19,20,21,23,24,25,18,23,25,26,28,29,31,32,33,34,35,36,37,38,39,40,41,43,44]
current_subs = [11,13,14,15,16,17,18,19,20,21,23,24,25,26,28,29,30,31,32,33,34,35,36,37,38,39,40,
40,41,43,44,46,47,50,51,52,53,55,56,59,61]

#src = glob.glob(os.path.join('/Users/h/Documents/projects_local/d_beh', 'sub-*', 'task-social', 'ses-*'))
#src = glob.glob(os.path.join('/Users/h/Documents/projects_local/d_beh', 'sub-*', 'task-social', 'ses-*'))
# TODO: instead of writing out all of the current_subs, glob and extract subject numbers
# TODO: compare diff between d01_rawbeh and d_beh. only copy over the diffs
for ind, c_sub in enumerate(current_subs):
    src_fnames = glob.glob(os.path.join('/Users/h/Documents/projects_local/d_beh', 'sub-{0:04d}'.format(c_sub), 'task-social', 'ses-*'))
    for ind, src_fname in enumerate(src_fnames):
        num = re.findall('\d+', src_fname)
        print("sub: {0}, session: {1}".format(num[0], num[1]))
        dst_fname = os.path.join('/Users/h/Documents/projects_local/social_influence_analysis/data/dartmouth/d01_rawbeh', 'sub-'+num[0], 'ses-'+num[1])
        if os.path.exists(dst_fname):
            shutil.rmtree(dst_fname)
        shutil.copytree(src_fname, dst_fname)
