function idx = draw_random_segment(ref_idx, n_samples)
%DRAW_RANDOM_SEGMENT Randomly placed segment with the same length as a reference.
%
%   idx = DRAW_RANDOM_SEGMENT(ref_idx, n_samples) returns sample indices of
%   a segment with numel(ref_idx) samples, starting at a uniformly drawn
%   sample between the start of the reference segment and the last start
%   that still fits in the recording. Returns empty if the reference is
%   empty or no such segment fits. Set the seed with RNG for reproducibility.

idx = zeros(1, 0);
if isempty(ref_idx)
    return
end
len = numel(ref_idx);
first_start = ref_idx(1);
last_start  = n_samples - len + 1;
if last_start < first_start
    return
end
start = randi([first_start, last_start]);
idx = start:(start + len - 1);
end
