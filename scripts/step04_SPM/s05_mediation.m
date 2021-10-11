
%% Step 1 load single trials__________________________________________________
% File names
mount_dir = '/Users/h/Documents/MATLAB/test_social/';
M = cell(4,1);
for i = 1:4
    simpleP_t = dir(fullfile(mount_dir, strcat('sub-0', num2str(i)), '*stim*.nii')); 
    simpleP_fldr = {simpleP_t.folder}; fname = {simpleP_t.name};
    simpleP_files = strcat(simpleP_fldr,'/', fname)';

    B = regexp(fname,'(?<=-stim-)\d+(?=.nii$)','once','match');
    Xtrial_num = cellfun(@str2num, B) + 1;

    M{i} = char(simpleP_files);
end
%% Step 2 __________________________________________________
% extract number from ev information Xtrial_num
% load csv and grab the corresponding row and stim rating information
for i = 1:4
Y{i} = [26.04888695,0,...
18.50775155,74.18080605,...
9.68878656,46.46048251,...
50.25380275,2.070030653,...
18.50775155,3.561533089,...
0.69586594,83.33038016]';
end

for i = 1:4
X{i} = [ 1, -1,...   
        1, 1,...
        1, 1,...
        -1, -1,... 
        1, -1,...
        -1, -1]';% cue type
end

% mask = '/Users/h/Documents/MATLAB/CanlabCore/CanlabCore/canlab_canonical_brains/Canonical_brains_surfaces/brainmask.nii';
mask = which('gray_matter_mask.img');
SETUP.TR=0.46;
SETUP.HPlength = 100;
SETUP.dummyscans = 6;
SETUP.scans_per_session = [872 872 872 872 872 872 872 872 872 872 872 872];
SETUP.wh_is_mediator = 'M';
SETUP.outputnames = 'ouput.nii';
SETUP.mask = mask;
 
    
% mediation_brain_multilevel(SETUP.data.X, SETUP.data.Y, SETUP.data.M, struct('mask', spm_get(1), 'startslice', 7), 'boot', 'nopreproc','bootsamples', 10000);
names = {'X:Cue' 'Y:Actual Rating' 'M:BrainMediator'};

% results = mediation_brain(X, Y, M{1},'names',names,'mask', mask,'boot','pvals',5, 'bootsamples', 10);
mediation_brain_multilevel(X, Y, M',struct('mask', mask, 'startslice', 7), SETUP, 'boot', 'nopreproc')
% [SETUP.cmdstring, SETUP.wh_is_mediator] = get_cmdstring(X, Y, M);

% Step 1 __________________________________________________
% format X, M, Y
% first mediation: M will be stimulus phase contrast
% Y will be actual behavioral rating

% con-12_stimXcue_G * con-16_stimXactual_G

% def _prepare_xdat(movie_num):
%     # list of all subjects 
%     # load con 12 
%     # load con 16
%     # dot product
%     # average across data
% 
%     all_subjects = glob.glob(fMRI_DIR + f'*/MNINonLinear/Results/tfMRI_MOVIE{movie_num}_7T_*/tfMRI_MOVIE{movie_num}_7T_*_hp2000_clean.nii.gz')
% 
%     subj_data = None
%     for subj in all_subjects:
%         fmridat = nib.load(subj)
%         fmridd = np.expand_dims(fmridat.get_fdata(),0)
% 
%         if subj_data is None:
%             subj_data = fmridd
%         else:
%             subj_data = np.concatenate([subj_data, fmridd],axis=0)
%     
%     return subj_data
% % second mediation: M will be expectation phase contrast
% % recovered M from first mediation will serve as Y
function [preprochandle, SETUP] = filter_setup(SETUP, X, varargin)

    preprochandle = [];
    %wh_elim = [];
    hpflag = 1;  % only does it if requested, though

    for i = 1:length(varargin)
        if ischar(varargin{i})
            switch varargin{i}
                % reserved keywords
                case 'custompreproc'
                    preprochandle = varargin{i + 1};  % e.g., 'custompreproc', @(data) scale(data) for z=scores;
                
                    hpflag = 0;
                    SETUP.TR = NaN;
                    SETUP.HPlength = [];
                    SETUP.dummyscans = [];
                    %wh_elim = i;
                    
                case {'nopreproc'}
                    hpflag = 0;
                    SETUP.preprocX = 0; SETUP.preprocY = 0; SETUP.preprocM = 0;
                    SETUP.TR = NaN;
                    SETUP.HPlength = [];
                    SETUP.dummyscans = [];
                    %wh_elim = i;
                        
                    % We need to allow mediation SETUPions here, so eliminate this from list and do not error check here.
                    %otherwise, warning(['Unknown input string SETUPion:' varargin{i}]);
            end
        end
    end

    %varargin(wh_elim) = [];

    N = fieldnames(SETUP);
    for i = 1:length(N)
        if ~isfield(SETUP, N{i}) || isempty(SETUP.(N{i}))
            switch N{i}
                case {'TR', 'mask', 'scans_per_session', 'preprocY'}
                    error(['Enter SETUP.' N{i}]);

                case 'HPlength'
                    SETUP.(N{i}) = [];

                case 'dummyscans'
                    SETUP.(N{i}) = 1:2;

                otherwise
                    disp('Warning! Unrecognized field in SETUPions structure SETUP.');
            end
        end
    end

    SETUP.preproc_any = SETUP.preprocX || SETUP.preprocY || SETUP.preprocM;

    if SETUP.preproc_any && hpflag

        [tmp, I, S] = hpfilter(X(:,1), SETUP.TR, SETUP.HPlength, SETUP.scans_per_session, SETUP.dummyscans); % creates intercept and smoothing matrices

        preprochandle = @(Y) hpfilter(Y,  [], S, SETUP.scans_per_session, I);  % function handle with embedded fixed inputs

    end

end
