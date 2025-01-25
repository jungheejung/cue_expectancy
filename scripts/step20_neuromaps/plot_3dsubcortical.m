[test_images, names] = load_image_set('kragel18_alldata', 'noverbose');

% This field contains a table object with metadata for each image:

metadata = test_images.metadata_table;
metadata(1:5, :)                        % Show the first 5 rows

% Here are the 3 domains:

disp(unique(metadata.Domain))

% Find all the images of "Neg_Emotion" and pull those into a separate
% fmri_data object:

wh = find(strcmp(metadata.Domain, 'Neg_Emotion'));
neg_emo = get_wh_image(test_images, wh);

% Do a t-test on these images, and store the results in a statistic_image
% object called "t". Threshold at q < 0.001 FDR. This is an unusual
% threshold, but we have lots of power here, and want to restrict the
% number of significant voxels for display purposes below.

t = ttest(neg_emo, .001, 'fdr');

% Find the images for other conditions and save them for later:

t_emo = t;

wh = find(strcmp(metadata.Domain, 'Cog_control'));
cog_control = get_wh_image(test_images, wh);
t_cog = ttest(cog_control, .001, 'fdr');

wh = find(strcmp(metadata.Domain, 'Pain'));
pain = get_wh_image(test_images, wh);
t_pain = ttest(pain, .001, 'fdr');


%% surface
% This generates a series of 6 surfaces of different types, including a
% subcortical cutaway

surface(t);
drawnow, snapnow

% This generates a different plot

create_figure('lateral surfaces');
surface_handles = surface(t, 'foursurfaces', 'noverbose');
snapnow

% You can see more options with:
% |help statistic_image.surface| or |help t.surface|

% You can also use the |render_on_surface()| to method to change the colormap:

render_on_surface(t, surface_handles, 'colormap', 'summer');
snapnow


%% subcortical
create_figure('cutaways'); axis off
surface_handles = addbrain('brainstem_group');

surface_handles = [surface_handles addbrain('pbn')];
surface_handles = [surface_handles addbrain('rn')];
surface_handles = [surface_handles addbrain('pag')];
% surface_handles = [surface_handles addbrain('thalamus_group')];
% surface_handles = [surface_handles addbrain('midbrain_group')];

drawnow, snapnow
set(surface_handles, 'FaceAlpha', 1);
drawnow, snapnow
