function r = compute_session_psd(dataBSTD, timing, cfg)
%COMPUTE_SESSION_PSD Epoch-wise PSDs for all segments of one recording.
%
%   r = COMPUTE_SESSION_PSD(dataBSTD, timing, cfg) returns a struct with,
%   for each segment (rest, brady, random, total) and hemisphere (left,
%   right), an [n_epochs x n_freqs] matrix of Welch PSDs, plus:
%
%     psd_mean_left/right   mean PSD over all clean epochs of the recording
%     stim_left/right       mean stimulation amplitude (mA)
%     channels              channel labels
%     random_start_s        start of the random segment (s), NaN if none
%     n_dropped_*           epochs dropped because they contained NaNs
%
%   dataBSTD needs the fields lfp_ecg ([samples x channels]), channels and
%   stim.amp ([samples x hemispheres]). timing is one row of the session
%   table (seconds from recording start).

sp = cfg.spectral;
fs = sp.fs;
epoch_len = round(sp.epoch_s * fs);

lfp = dataBSTD.lfp_ecg;
n = size(lfp, 1);
[left, right] = extract_hemispheres(lfp, dataBSTD.channels);

% Segment sample indices
idx.rest   = seconds_to_samples(timing.rest_start_s,  timing.rest_end_s,  fs, n);
idx.brady  = seconds_to_samples(timing.brady_start_s, timing.brady_end_s, fs, n);
idx.random = draw_random_segment(idx.brady, n);
idx.total  = 1:n;

r = struct();
for seg = fieldnames(idx)'
    s = seg{1};
    [r.(['psd_' s '_left']),  r.(['n_dropped_' s '_left'])]  = ...
        epoch_psd(left(idx.(s)),  fs, epoch_len, sp.window, sp.overlap, sp.freqs);
    [r.(['psd_' s '_right']), r.(['n_dropped_' s '_right'])] = ...
        epoch_psd(right(idx.(s)), fs, epoch_len, sp.window, sp.overlap, sp.freqs);
end

r.psd_mean_left  = mean(r.psd_total_left, 1);
r.psd_mean_right = mean(r.psd_total_right, 1);

amp = dataBSTD.stim.amp;
r.stim_left  = mean(amp(:, 1), 'omitnan');
r.stim_right = NaN;
if size(amp, 2) >= 2
    r.stim_right = mean(amp(:, 2), 'omitnan');
end

r.channels = dataBSTD.channels;
if isempty(idx.random)
    r.random_start_s = NaN;
else
    r.random_start_s = (idx.random(1) - 1) / fs;
end
end
