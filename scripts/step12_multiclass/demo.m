nii = fmri_data()
df = nii.dat'; % voxel x participant
t = templateSVM('Standardize',true,'KernelFunction','linear');
t = templateSVM('Standardize',true,'KernelFunction','gaussian');

Mdl = fitcecoc(X,Y,'Learners',t,'FitPosterior',true,...
    'ClassNames',{'setosa','versicolor','virginica'},...
    'Verbose',2);
% train on train
    [label,~,~,Posterior] = resubPredict(Mdl,'Verbose',1);
% train on test
table(Y(idx),label(idx),Posterior(idx,:),...
    'VariableNames',{'TrueLabel','PredLabel','Posterior'})

% confusion matrix
oofLabel = kfoldPredict(CVMdl,'Options',options);
ConfMat = confusionchart(Y,oofLabel,'RowSummary','total-normalized');
ConfMat.InnerPosition = [0.10 0.12 0.85 0.85];