
# This code exists in the preprocessing github repo
# https://github.com/spatialtopology/preprocessing
csv_fname = './IndividualizedSpatia_DATA_LABELS_2022-06-28_1136.csv'
df = pd.read_csv(csv_fname)

# multiindex
# grab rows that have "Consent" in it. "
sub = df[df['Record ID'].str.contains('sub-')]
sub = sub[~sub['Record ID'].str.contains('old')]
sub_i = sub.set_index('Record ID').copy()
sub_consent = sub_i[sub_i['Event Name'].str.contains('Consent')]
sub_screen = sub_i[sub_i['Event Name'].str.contains('Screening')]
df_consent = sub_screen.loc[list(sub_consent.index) ]
df_ier = df_consent[['Sex:', 'Race', 'Ethnicity']]

piv = df_ier.pivot_table(index='Race',
               columns=['Ethnicity', 'Sex:'],
               aggfunc=len,
               fill_value=0)
piv.to_csv('./output_table_.csv', index = False)