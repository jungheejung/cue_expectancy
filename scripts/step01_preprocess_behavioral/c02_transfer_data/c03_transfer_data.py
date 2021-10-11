import glob, os, re, shutil
# search for folder named d_beh
# copy /Users/h/Documents/projects_local/d_beh/sub-0001/task-social
# into    /Users/h/Documents/projects_local/social_influence_analysis/rawbeh

src = glob.glob(os.path.join('/Users/h/Documents/projects_local/d_beh', 'sub-*', 'task-social', 'ses-*'))
for ind, src_fname in enumerate(src):

    num = re.findall('\d+', src[ind])
    print("sub: {0}, session: {1}".format(num[0], num[1]))
    dst_fname = os.path.join('/Users/h/Documents/projects_local/social_influence_analysis/dartmouth/beh_raw', 'sub-'+num[0], 'ses-'+num[1])
    if os.path.exists(dst_fname):
        shutil.rmtree(dst_fname)
    shutil.copytree(src_fname, dst_fname)
