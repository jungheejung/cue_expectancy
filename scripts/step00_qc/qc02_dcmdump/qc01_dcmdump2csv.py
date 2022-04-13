#!/usr/bin/env python3  


"""
1. grab the latest file of the "odd dicom"

TODO: think of a way to streamline this
ssh ini python
scp heejung@rolando.cns.dartmouth.edu:/afs/dbic.dartmouth.edu/usr/wager/heejung/odd_dicoms_01-21-2022.txt ~/Downloads
list_of_files = glob.glob('/path/to/folder/*') # * means all if need specific format then *.csv
latest_file = max(list_of_files, key=os.path.getctime)
print(latest_file)

2. load txt into pandas
3. 
"""
# %%
import glob
import os
import pandas as pd

__author__ = "Heejung Jung"
__copyright__ = "Spatial Topology Project"
__credits__ = ["Heejung"] # people who reported bug fixes, made suggestions, etc. but did not actually write the code.
__license__ = "GPL"
__version__ = "0.0.1"
__maintainer__ = "Heejung Jung"
__email__ = "heejung.jung@colorado.edu"
__status__ = "Development" 

# %% TODO: no header
# TODO: split filename with /
# extract accession number and file name

filename = '/Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step00_qc/qc02_dcmdump/odd_dicoms_01-21-2022.txt'
dcm = pd.read_csv(filename)
dcm
# %% split txt file values (divider is '/')
dcm['Col1'].str.split().str[0]
sub = [match for match in filename.split('_') if "sub" in match][0]