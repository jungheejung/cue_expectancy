% Assuming 'ic' is the contrast of interest
ic = 1; % You can change this to the index of your desired contrast

% Extract contrast values for the given contrast
contrast_values = SPM.xCon(ic).c;

% Find indices where contrast values are not zero
non_zero_indices = find(contrast_values ~= 0);

% Extract corresponding regressor names
non_zero_regressor_names = SPM.xX.name(non_zero_indices);

% Display the regressor names and their associated non-zero contrast values
for i = 1:length(non_zero_indices)
    disp(['Regressor: ', non_zero_regressor_names{i}, ' - Value: ', num2str(contrast_values(non_zero_indices(i)))]);
end
