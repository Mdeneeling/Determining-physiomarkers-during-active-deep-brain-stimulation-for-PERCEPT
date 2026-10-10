function [Y1, Y2] = equalize_epochs(X1, X2, method)
%EQUALIZE_EPOCHS Give two groups of epochs the same number of epochs.
%
%   [Y1, Y2] = EQUALIZE_EPOCHS(X1, X2, method), with X1 and X2 [epochs x freqs]:
%
%   'subsample'        Draw min(n1, n2) epochs from each group without
%                      replacement. Every epoch in the output is a distinct
%                      original epoch.
%   'legacy_bootstrap' Original implementation, kept for comparison only:
%                      n2 samples per group, each the mean of two epochs
%                      drawn with replacement from that group. Averaging
%                      shrinks within-group variance, which inflates the
%                      t-statistic and Cohen's d.

switch method
    case 'subsample'
        n = min(size(X1, 1), size(X2, 1));
        Y1 = X1(sort(randperm(size(X1, 1), n)), :);
        Y2 = X2(sort(randperm(size(X2, 1), n)), :);
    case 'legacy_bootstrap'
        n = size(X2, 1);
        draw = @(X) X(randi(size(X, 1), n, 1), :);
        Y1 = (draw(X1) + draw(X1)) / 2;
        Y2 = (draw(X2) + draw(X2)) / 2;
    otherwise
        error('equalize_epochs:method', 'Unknown method "%s".', method);
end
end
