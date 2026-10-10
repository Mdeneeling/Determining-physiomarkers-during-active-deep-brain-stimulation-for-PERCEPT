function tests = test_segments
%TEST_SEGMENTS Unit tests for segment selection helpers.
tests = functiontests(localfunctions);
end

function setupOnce(~)
addpath(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'src'));
end

%% seconds_to_samples
function test_window_to_samples(tc)
idx = seconds_to_samples(10, 70, 250, 100000);
verifyEqual(tc, idx(1), 2501);
verifyEqual(tc, idx(end), 17500);
verifyEqual(tc, numel(idx), 60 * 250);
end

function test_window_clipped_to_recording(tc)
idx = seconds_to_samples(-5, 20, 250, 1000);
verifyEqual(tc, idx, 1:1000);
end

function test_window_outside_recording_is_empty(tc)
verifyEmpty(tc, seconds_to_samples(100, 160, 250, 1000));
end

%% draw_random_segment
function test_random_segment_length_and_bounds(tc)
rng(1);
ref = 2501:17500;
for k = 1:200
    idx = draw_random_segment(ref, 30000);
    verifyEqual(tc, numel(idx), numel(ref));
    verifyGreaterThanOrEqual(tc, idx(1), ref(1));
    verifyLessThanOrEqual(tc, idx(end), 30000);
end
end

function test_random_segment_reproducible(tc)
ref = 2501:17500;
rng(42); a = draw_random_segment(ref, 30000);
rng(42); b = draw_random_segment(ref, 30000);
verifyEqual(tc, a, b);
end

function test_random_segment_empty_when_it_does_not_fit(tc)
verifyEmpty(tc, draw_random_segment(900:1100, 1000));
verifyEmpty(tc, draw_random_segment(zeros(1, 0), 1000));
end

%% extract_hemispheres
function test_two_channels_by_label(tc)
lfp = [ones(10, 1), 2 * ones(10, 1)];
[l, r] = extract_hemispheres(lfp, {'ZERO_TWO_RIGHT', 'ZERO_TWO_LEFT'});
verifyEqual(tc, l, 2 * ones(10, 1));
verifyEqual(tc, r, ones(10, 1));
end

function test_missing_hemisphere_is_nan(tc)
[l, r] = extract_hemispheres(ones(10, 1), {'ZERO_TWO_LEFT'});
verifyEqual(tc, l, ones(10, 1));
verifyTrue(tc, all(isnan(r)));
end

%% select_sessions
function test_select_sessions(tc)
T = table(["sub001_5A"; "sub001_5B"; "Sub018_5D"; "sub020_5D"], (1:4)', ...
          'VariableNames', {'session_id', 'x'});
scfg.suffixes = {'A', 'D'};
scfg.exclude_subjects = {'sub018'};
S = select_sessions(T, scfg);
verifyEqual(tc, S.session_id, ["sub001_5A"; "sub020_5D"]);
end
