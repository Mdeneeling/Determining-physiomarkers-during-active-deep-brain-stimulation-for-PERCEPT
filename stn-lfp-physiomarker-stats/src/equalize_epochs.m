function [Y1, Y2] = equalize_epochs(X1, X2, method)
%EQUALIZE_EPOCHS Give two groups of epochs the same number of epochs.
%
%   [Y1, Y2] = EQUALIZE_EPOCHS(X1, X2, method), with X1 and X2 [epochs x freqs]:
%
%   'subsample'        Draw min(n1, n2) epochs from each group without
%                      replacement. Every epoch in the output is a distinct
%                      original epoch.

    case 'subsample'
        n = min(size(X1, 1), size(X2, 1));
        Y1 = X1(sort(randperm(size(X1, 1), n)), :);
        Y2 = X2(sort(randperm(size(X2, 1), n)), :);
end
end
