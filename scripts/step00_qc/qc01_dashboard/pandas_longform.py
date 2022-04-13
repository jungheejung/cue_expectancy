
# %%
import pandas as pd  
filename = '/Users/h/Dropbox/projects_dropbox/social_influence_analysis/resources/spacetop-scannotes_01-27-2022.csv'
df = pd.read_csv(filename) 

# %%
df_dp = df.drop(['ses-01', 'ses-02', 'ses-03', 'ses-04'], axis = 1)  
t1 = df_dp[['sub-ID','ses-01_accession','T1_01status','T1_02quality','T1_03actions','DWI']]
df_ses = df_dp.drop(['T1_01status','T1_02quality','T1_03actions','DWI'], axis = 1) 
pd.wide_to_long(df_ses,stubnames="ses-", i = ["sub-ID"]  , j = "task_run")                            