# %%
import glob, os, sys
main_dir = '/Volumes/spacetop_projects_social/'
script_dir = os.path.join(main_dir, 'scripts/step04_SPM/model02_CcEScA/log_glm_cueonly')
log_g = glob.glob(os.path.join(script_dir,'GLM_*.o'))

# TODO:
# append to existing text file
# %%
compile_list = []
for fname in sorted(log_g):
    with open(fname, 'r') as f:
        last_line = f.readlines()[-1]
        compile_list.append(f"{fname} {last_line}")
        # compile_list.append('\n')
# %%
from datetime import datetime
date = datetime.now().strftime("%m-%d-%Y")
with open(os.path.join(script_dir, f'glmlog_{date}.txt'), 'w') as f:
    for row in compile_list:
        f.write(str(row) + '\n')
