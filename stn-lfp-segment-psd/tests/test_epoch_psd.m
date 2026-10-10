function tests = test_epoch_psd
%TEST_EPOCH_PSD Unit tests for epoch_psd.
tests = functiontests(localfunctions);
end

function setupOnce(~)
addpath(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'src'));
end

function [x, fs, freqs] = sine(f_hz, dur_s)
fs = 250;
t = (0:round(dur_s * fs) - 1)' / fs;
x = sin(2 * pi * f_hz * t);
freqs = 2:1:100;
end

function test_one_row_per_epoch(tc)
[x, fs, freqs] = sine(20, 10);
psd = epoch_psd(x, fs, 500, 250, 237, freqs);
verifySize(tc, psd, [5, numel(freqs)]);
end

function test_peak_at_signal_frequency(tc)
[x, fs, freqs] = sine(20, 10);
psd = epoch_psd(x, fs, 500, 250, 237, freqs);
[~, i_max] = max(mean(psd, 1));
verifyEqual(tc, freqs(i_max), 20);
end

function test_epochs_do_not_overlap_or_skip(tc)
% Each epoch must cover its own samples: put a burst only in epoch 2.
fs = 250; freqs = 2:1:100;
x = zeros(2500, 1);
x(501:1000) = sin(2 * pi * 20 * (0:499)' / fs);
psd = epoch_psd(x, fs, 500, 250, 237, freqs);
power = sum(psd, 2);
verifyGreaterThan(tc, power(2), 0);
verifyEqual(tc, power([1 3 4 5]), zeros(4, 1));
end

function test_partial_epoch_discarded(tc)
[x, fs, freqs] = sine(20, 4.4);   % 1100 samples -> 2 full epochs
psd = epoch_psd(x, fs, 500, 250, 237, freqs);
verifySize(tc, psd, [2, numel(freqs)]);
end

function test_nan_epochs_dropped(tc)
[x, fs, freqs] = sine(20, 10);
x(600) = NaN;                       % inside epoch 2
[psd, n_dropped] = epoch_psd(x, fs, 500, 250, 237, freqs);
verifySize(tc, psd, [4, numel(freqs)]);
verifyEqual(tc, n_dropped, 1);
verifyFalse(tc, any(isnan(psd(:))));
end

function test_short_or_empty_signal_gives_no_epochs(tc)
freqs = 2:1:100;
verifySize(tc, epoch_psd(zeros(100, 1), 250, 500, 250, 237, freqs), [0, numel(freqs)]);
verifySize(tc, epoch_psd(zeros(0, 1),   250, 500, 250, 237, freqs), [0, numel(freqs)]);
end
