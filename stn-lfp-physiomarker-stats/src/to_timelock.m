function data = to_timelock(Y, freqs, label)
%TO_TIMELOCK Wrap epoch PSDs in a FieldTrip timelock structure.
%
%   data = TO_TIMELOCK(Y, freqs, label) puts Y ([epochs x freqs]) in a
%   'subj_chan_time' structure with epochs as observations, one channel
%   (label) and frequency (Hz) on the 'time' axis, so FT_TIMELOCKSTATISTICS
%   forms clusters over adjacent frequencies.

if nargin < 3
    label = 'STN';
end
data = struct();
data.dimord     = 'subj_chan_time';
data.individual = reshape(Y, size(Y, 1), 1, size(Y, 2));
data.time       = freqs(:).';
data.label      = {label};
end
