% 2 class classfication by linear SLR
% Simple classification when multiple features are relevant but either of
% them is not so strongly relevant.
% 
% discriminant fucntion : linear function 
% training data : simulated data generated from Gaussian Mixtures 
% test data     : simulated data generated from Gaussian Mixtures 

clear
close all

data = 3;

fprintf('This is a demo how the sparse logistic regression model works...\n');
%----------------------------
% Generate Data
%----------------------------
switch data
     case 1,

        D = 400;
        Ntr = 200;
        Nte = 100;
        % mean
        mu1 = zeros(D,1);
        mu2 = [1.5; 0; zeros(D-2,1)];
        % covariance
        S = diag(ones(D,1));
        ro = 0.8;
        S(1,2) = ro;
        S(2,1) = ro;


        [ttr, xtr, tte, xte, g] = gen_simudata([mu1 mu2], S, Ntr, Nte);

        fprintf('\nThe data is generated from 2 Gaussian Mixture model of which centers (mean) are different.\n');
        fprintf('Input feature dimension is %d. \n',D);
        fprintf('But only the first dimension has difference in mean value between two classes,\n');
        fprintf('and the other dimension has same mean value.\n');
        fprintf('Therefore only the first dimension is detected as a meaningful feature,\n')
        fprintf('if you select features by feature-wise t-value ranking method.\n');
        fprintf('However due to the correlataion between the second dimension and the first dimension,\n')
        fprintf('inclusion of the second dimension makes classfication more accurate.\n');
        fprintf('For comparison, this demo also computes the classification performance of linear RVM, \n');
        fprintf('which is Bayesian counterpart of support vector machine (SVM).');

    case 2,
        D = 100;
        Ntr = 200;
        Nte = 100;
        % mean
        mu1 = zeros(D,1);
        mu2 = [[1:-0.02:0]'; zeros(D-51,1)];
        % covariance
        S = diag(ones(D,1));

        [ttr, xtr, tte, xte, g] = gen_simudata([mu1 mu2], S, Ntr, Nte);

        fprintf('\nThe data is generated from 2 Gaussian Mixture model of which centers (mean) are different.\n');
        fprintf('Input feature dimension is %d. \n',D);
        fprintf('The first 50 dimension has difference in mean value between two classes,\n');
        fprintf('and the other dimension has same mean value.\n');
        fprintf('The degree of relevance in the first 50 dimensions are manipulated by the mean values in class 1.\n')
        fprintf('For comparison, this demo also computes the classification performance of linear RVM, \n');
        fprintf('which is Bayesian counterpart of support vector machine (SVM).');
    
    case 3,
        load('../TESTDATA/real_binary', 'TRAIN_DATA', 'TEST_DATA', 'TRAIN_LABEL', 'TEST_LABEL');
        ttr = TRAIN_LABEL;
        tte = TEST_LABEL;
        xtr = TRAIN_DATA;
        xte = TEST_DATA;
        [Ntr,D] = size(TRAIN_DATA);
        [Nte] = size(TEST_DATA,1);
        
        fprintf('\nThe data is generated from a real experimental EEG data.\n');
        fprintf('In the experiment a subject executed either left or right finger tapping.\n');
        fprintf('The data has already been processed appropriately for classification.\n');
end

%--------------------------------
% Plot data (First 2 dimension)
%--------------------------------
slr_view_data(ttr, xtr);
axis equal;
title('Training Data')

% fprintf('\n\nPress any key to proceed \n\n');
% pause

%--------------------------------
% Learn Paramters
%--------------------------------
% tic
% fprintf('\nOLD version (ARD-Laplace)!!\n')
% [ww_o, ix_eff_o, errTable_tr_o, errTable_te_o] = run_smlr_bi(xtr, ttr, xte, tte,...
%     'wdisp_mode', 'off', 'nlearn', 300, 'mean_mode', 'none', 'scale_mode', 'none');
% toc

tic
fprintf('\nFast version (ARD-Variational)!!\n')
[ww_f, ix_eff_f, errTable_tr_f, errTable_te_f, parm, AXall_f, ptr, pte] = run_rlr_bi_var(xtr, ttr, xte, tte,...
    'nlearn', 300, 'mean_mode', 'none', 'scale_mode', 'none');
toc

tic
fprintf('\nFast version (ARD-Variational)!!\n')
[ww_fn, ix_eff_fn, errTable_tr_fn, errTable_te_fn, parmn, AXall_fn, ptrn, pten] =...
    biclsfy_rlrvar(xtr, ttr, xte, tte,...
    'nlearn', 300, 'mean_mode', 'none', 'scale_mode', 'none', 'invhessian', 1);
toc

tic
fprintf('\nFast version (ARD-Variational)!!\n')
[ww_fn2, ix_eff_fn2, errTable_tr_fn2, errTable_te_fn2, parmn2, AXall_fn2, ptrn2, pten2] =...
    biclsfy_rlrlap(xtr, ttr, xte, tte,...
    'nlearn', 300, 'mean_mode', 'none', 'scale_mode', 'none', 'wdisp_mode', 'off');
toc


ww_f(:,1) - ww_fn
ix_eff_f{1} - ix_eff_fn{1}
errTable_tr_f - errTable_tr_fn
errTable_te_f - errTable_te_fn
ptr - ptrn
pte - pten
AXall_f-AXall_fn

ww_fn - ww_fn2
ix_eff_fn{1} - ix_eff_fn2{1}
errTable_tr_fn - errTable_tr_fn2
errTable_te_fn - errTable_te_fn2
ptrn - ptrn2
pten - pten2
AXall_fn-AXall_fn2
% fprintf('\nNew Fast version (ARD-Variational)!!\n')
% [ww_fn, ix_eff_fn, errTable_tr_fn, errTable_te_fn, parm, AXall_fn, ptr_n, pte_n] = biclsfy_slrvar(xtr, ttr, xte, tte,...
%     'nlearn', 300, 'mean_mode', 'none', 'scale_mode', 'none', 'invhessian', 1);
% toc
% 
% ww_f(:,1) + ww_fn
% ix_eff_f{1} - ix_eff_fn{1}
% errTable_tr_f - errTable_tr_fn
% errTable_te_f - errTable_te_fn
% ptr - ptr_n
% pte - pte_n


% tic
% fprintf('\n\nLinear RVM (ARD-Variational)!!\n')
%     [ww_rvm, ix_eff_rvm, errTable_tr_rvm, errTable_te_rvm, g_rvm] = run_rvm(xtr, ttr, xte, tte, 0, ...
%         'nlearn', 1000, 'nstep', 1000, 'mean_mode', 'none', 'scale_mode', 'none', 'amax', 1e8);
% toc

