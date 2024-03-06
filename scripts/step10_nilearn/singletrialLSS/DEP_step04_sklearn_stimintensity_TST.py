# %%
from sklearn.model_selection import KFold
from sklearn.linear_model import LassoCV
from sklearn.metrics import r2_score
import numpy as np
from nilearn import image
from nilearn import plotting
import os, glob

singletrial_dir = 'TODO:INSEERT'
sub = '*'
ses = '*'
run = '*'
runtype = 'pain'
event = 'stimulus'
img_flist = glob.glob(os.path.join(singletrial_dir, sub,
                      f'{sub}_{ses}_{run}_runtype-{runtype}_event-{event}*.nii.gz'))
print(img_flist)
img_flist = sorted(img_flist)
stacked_singletrial = image.concat_imgs(sorted(img_flist))

X = brain_maps # subject x voxel
y = target_diffs # must be same lengths

outer_cv = KFold(n_splits=10)
#outer_cv = KFold(n_splits=n_subjects)
#StratifiedKFold, PredefinedSplit

inner_cv = KFold(n_splits=10)

alphas = [1e-3, 1e-2, 1e-1, 1, 1e2]
lasso = LassoCV(cv=inner_cv)
lasso = LassoCV(alphas=alphas, cv=inner_cv)

y_preds = []
for train, test in outer_cv.split(X):
    lasso.fit(X[train], y[train])
    y_pred = lasso.predict(X[test])
    # evaluate here?

    # or
    y_preds.append(y_pred)

y_preds = np.vstack(y_preds)

r2_score(y, y_pred)