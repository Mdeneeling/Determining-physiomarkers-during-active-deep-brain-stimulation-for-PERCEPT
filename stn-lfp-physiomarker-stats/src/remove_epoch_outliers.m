function [P, n_replaced] = remove_epoch_outliers(P, threshold_sd)
%REMOVE_EPOCH_OUTLIERS Replace transient outlier epochs by the bin median.
%
%   [P, n_replaced] = REMOVE_EPOCH_OUTLIERS(P, threshold_sd) treats each
%   column of P ([epochs x freqs]) as a series over epochs. Epochs that are
%   peaks exceeding both neighbouring epochs by more than threshold_sd times
%   the column's standard deviation (FINDPEAKS with 'Threshold') are
%   replaced by the column median (computed before replacement).

n_replaced = 0;
if threshold_sd <= 0 || size(P, 1) < 3
    return
end
for f = 1:size(P, 2)
    x = P(:, f);
    [~, locs] = findpeaks(x, 'Threshold', threshold_sd * std(x));
    x(locs) = median(x);
    P(:, f) = x;
    n_replaced = n_replaced + numel(locs);
end
end
