function tests = test_helpers
%TEST_HELPERS Unit tests for pairing, outlier removal, peak effect and data format.
tests = functiontests(localfunctions);
end

function setupOnce(~)
addpath(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'src'));
end

%% pair_sessions
function results = fake_results()
session_id = ["sub001_5A"; "sub001_5D"; "sub002_5A"; "sub003_5A"; "sub003_5D"];
stim_left  = [2.0; 2.0; 1.5; 3.0; 3.0];
stim_right = [2.5; 2.5; 1.5; 3.5; 3.5];
psd_total_left  = arrayfun(@(k) k * ones(4, 3), (1:5)', 'UniformOutput', false);
psd_total_right = arrayfun(@(k) -k * ones(4, 3), (1:5)', 'UniformOutput', false);
results = table(session_id, stim_left, stim_right, psd_total_left, psd_total_right);
end

function test_pairs_on_off_per_hemisphere(tc)
cond.med_on = 'A'; cond.med_off = 'D';
pairs = verifyWarning(tc, @() pair_sessions(fake_results(), cond, 'psd_total'), ...
                      'pair_sessions:incomplete');   % sub002 has no D session
verifyEqual(tc, pairs.subject, ["sub001"; "sub001"; "sub003"; "sub003"]);
verifyEqual(tc, pairs.hemisphere, ["left"; "right"; "left"; "right"]);
verifyEqual(tc, pairs.stim_mA, [2.0; 2.5; 3.0; 3.5]);
verifyEqual(tc, pairs.psd_on{1}, 1 * ones(4, 3));
verifyEqual(tc, pairs.psd_off{1}, 2 * ones(4, 3));
verifyEqual(tc, pairs.psd_off{4}, -5 * ones(4, 3));
end

%% remove_epoch_outliers
function test_outlier_replaced_by_median(tc)
rng(4);
P = 1 + 0.01 * randn(200, 2);
P(50, 1) = 10;
[Q, n] = remove_epoch_outliers(P, 5);
verifyEqual(tc, n, 1);
verifyEqual(tc, Q(50, 1), median(P(:, 1)));
verifyEqual(tc, Q(:, 2), P(:, 2));
end

function test_outlier_removal_disabled(tc)
P = [1; 10; 1; 1];
[Q, n] = remove_epoch_outliers(P, 0);
verifyEqual(tc, Q, P);
verifyEqual(tc, n, 0);
end

%% peak_effect
function test_peak_significant_negative(tc)
freqs = 2:100;
d = zeros(size(freqs)); d(freqs == 20) = -0.9; d(freqs == 2) = 3;   % 2 Hz outside range
p = ones(size(freqs)); p(freqs == 20) = 0.01;
pk = peak_effect(d, p, freqs, [4 99], 0.05, 0.2);
verifyEqual(tc, pk.freq, 20);
verifyEqual(tc, pk.d, -0.9);
verifyTrue(tc, pk.significant);
verifyEqual(tc, pk.direction, -1);
end

function test_peak_not_significant_has_no_direction(tc)
freqs = 2:100;
d = zeros(size(freqs)); d(freqs == 70) = 0.8;
p = ones(size(freqs));
pk = peak_effect(d, p, freqs, [4 99], 0.05, 0.2);
verifyEqual(tc, pk.freq, 70);
verifyFalse(tc, pk.significant);
verifyEqual(tc, pk.direction, 0);
end

function test_peak_small_effect_has_no_direction(tc)
freqs = 2:100;
d = 0.1 * ones(size(freqs));
p = zeros(size(freqs));
pk = peak_effect(d, p, freqs, [4 99], 0.05, 0.2);
verifyTrue(tc, pk.significant);
verifyEqual(tc, pk.direction, 0);
end

function test_peak_all_nan(tc)
freqs = 2:100;
pk = peak_effect(nan(size(freqs)), ones(size(freqs)), freqs, [4 99], 0.05, 0.2);
verifyTrue(tc, isnan(pk.freq));
verifyEqual(tc, pk.direction, 0);
end

%% to_timelock
function test_timelock_layout(tc)
Y = reshape(1:12, 4, 3);
data = to_timelock(Y, [2 3 4]);
verifyEqual(tc, data.dimord, 'subj_chan_time');
verifySize(tc, data.individual, [4 1 3]);
verifyEqual(tc, squeeze(data.individual(2, 1, :))', Y(2, :));
verifyEqual(tc, data.time, [2 3 4]);
verifyEqual(tc, data.label, {'STN'});
end
