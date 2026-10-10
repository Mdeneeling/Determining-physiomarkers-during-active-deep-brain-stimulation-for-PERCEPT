function idx = seconds_to_samples(t_start, t_end, fs, n_samples)
%SECONDS_TO_SAMPLES Sample indices of a time window, clipped to the recording.
%
%   idx = SECONDS_TO_SAMPLES(t_start, t_end, fs, n_samples) returns the
%   1-based sample indices covering [t_start, t_end) seconds from the start
%   of a recording of n_samples samples at fs Hz. Parts of the window
%   outside the recording are clipped; an empty vector is returned if
%   nothing remains.

i_start = max(round(t_start * fs) + 1, 1);
i_end   = min(round(t_end * fs), n_samples);
if i_end < i_start
    idx = zeros(1, 0);
else
    idx = i_start:i_end;
end
end
