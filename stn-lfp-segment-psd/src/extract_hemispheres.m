function [left, right] = extract_hemispheres(lfp, channels)
%EXTRACT_HEMISPHERES Split LFP channels into left and right hemisphere.
%
%   [left, right] = EXTRACT_HEMISPHERES(lfp, channels) assigns each column
%   of lfp to a hemisphere based on whether its label contains 'LEFT' or
%   'RIGHT'. A hemisphere without a recorded channel is returned as NaN,
%   so it yields no epochs instead of a spectrum of zeros.

n = size(lfp, 1);
left  = nan(n, 1);
right = nan(n, 1);

labels = cellstr(string(channels));
if numel(labels) ~= size(lfp, 2)
    error('extract_hemispheres:sizeMismatch', ...
          '%d channel labels for %d LFP columns.', numel(labels), size(lfp, 2));
end

for c = 1:numel(labels)
    if contains(labels{c}, 'LEFT', 'IgnoreCase', true)
        left = lfp(:, c);
    elseif contains(labels{c}, 'RIGHT', 'IgnoreCase', true)
        right = lfp(:, c);
    else
        warning('extract_hemispheres:unknownLabel', ...
                'Channel label "%s" has no hemisphere; ignored.', labels{c});
    end
end
end
