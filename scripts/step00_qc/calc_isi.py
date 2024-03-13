

# %% load design file
import os, glob
from os.path import join
import pandas as pd
## flist glob
task_dir = "/Users/h/Documents/projects_local/task-social"
# %%
flist = glob.glob(join(task_dir, 'design/s04_counterbalance_with_onset', 'task-*_counterbalance_*.csv'))



# Use glob to find all files matching the pattern


# Load and concatenate all matching files into a single DataFrame
df_list = [pd.read_csv(file) for file in flist]
stacked_df = pd.concat(df_list, ignore_index=True)

# %%Now stacked_df contains all the data combined from the CSV files
stacked_df
stacked_df['ITI'].mean(), stacked_df['ISI1'].mean(), stacked_df['ISI2'].mean(), stacked_df['ISI3'].mean()
stacked_df['ITI'].min(), stacked_df['ISI1'].min(), stacked_df['ISI2'].min(), stacked_df['ISI3'].min()
stacked_df['ITI'].max(), stacked_df['ISI1'].max(), stacked_df['ISI2'].max(), stacked_df['ISI3'].max()

# %%
means = stacked_df[['ITI', 'ISI1', 'ISI2', 'ISI3']].mean()
mins = stacked_df[['ITI', 'ISI1', 'ISI2', 'ISI3']].min()
maxs = stacked_df[['ITI', 'ISI1', 'ISI2', 'ISI3']].max()

# Create a new DataFrame to hold the summary
summary_df = pd.DataFrame([means, mins, maxs], index=['Mean', 'Min', 'Max'])

# Transpose the DataFrame if you prefer the statistics as columns rather than rows
summary_df = summary_df.T

# %%
