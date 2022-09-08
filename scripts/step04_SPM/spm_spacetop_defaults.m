global defaults
% fMRI design defaults
%==========================================================================
defaults.stats.fmri.hpf = 180; % tor changed; 128 can be too low; should choose yourself % 128;
defaults.stats.fmri.cvi = 'None'; % tor changed. 'AR(1)', 'None', 'FAST'
% Mask defaults
%==========================================================================
defaults.mask.thresh = -Inf; % tor changed; Was 0.8. 0.8 performed implicit masking and made explicit 
masking impossible (may be fixed?)
% Stats defaults
%==========================================================================
defaults.stats.maxmem = 2^33; % tor modified. 2^33 = 8.59 GB. Was 2^28; depends on your memory.
defaults.stats.topoFDR = 0; % tor modified. Was 1 for "topological FDR" on peaks. 
