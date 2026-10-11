function tests = test_features
%TEST_FEATURES Unit tests for classification, features and the hemisphere table.
tests = functiontests(localfunctions);
end

function setupOnce(~)
addpath(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'src'));
end

%% classify_physiomarker
function test_classify(tc)
types.beta = struct('band', [9 20], 'direction', -1);
types.seg  = struct('band', [61 64], 'direction', 1);
peak = [12; 12; 62; 62; 40; 20];
dir  = [-1;  1;  1;  0; -1; -1];
verifyEqual(tc, classify_physiomarker(peak, dir, types), ...
            ["beta"; ""; "seg"; ""; ""; "beta"]);
end

%% effect_size_features
function test_beta_window_follows_each_hemispheres_own_peak(tc)
% Regression test: the original code centred every hemisphere's beta
% window on the first hemisphere's peak.
freqs = 2:100;
d = zeros(2, numel(freqs));
d(1, ismember(freqs, 10:14)) = -[0.2 0.4 1.0 0.4 0.2];   % peak at 12 Hz
d(2, ismember(freqs, 16:20)) = -[0.1 0.3 0.5 0.3 0.1];   % peak at 18 Hz
d(:, ismember(freqs, 62:64)) = [0.3 0.6 0.3; 0 0 0];
fcfg = struct('beta_search', [9 20], 'beta_halfwidth', 2, 'seg_band', [62 64]);
[mb, ms, pk] = effect_size_features(d, freqs, fcfg);
verifyEqual(tc, pk, [12; 18]);
verifyEqual(tc, mb, [-0.44; -0.26], 'AbsTol', 1e-12);
verifyEqual(tc, ms, [0.4; 0], 'AbsTol', 1e-12);
end

function test_beta_peak_ignores_frequencies_outside_search(tc)
freqs = 2:100;
d = zeros(1, numel(freqs));
d(freqs == 5) = -3;       % larger, but outside 9-20 Hz
d(freqs == 15) = -1;
fcfg = struct('beta_search', [9 20], 'beta_halfwidth', 2, 'seg_band', [62 64]);
[~, ~, pk] = effect_size_features(d, freqs, fcfg);
verifyEqual(tc, pk, 15);
end

%% build_hemisphere_table
function M = fake_stats()
M = table(["sub001"; "sub001"; "sub002"], ["left"; "right"; "left"], [2; 2.5; 3], ...
          [12; 62; 15], [-1; 1; -1], [-1; 1; -1], zeros(3, 2), ...
          'VariableNames', {'subject', 'hemisphere', 'stim_mA', 'peak_freq', 'peak_d', 'direction', 'cohensd'});
end

function test_matched_on_subject_and_hemisphere(tc)
% Clinical rows deliberately in the order right (1), left (0).
C = table(["sub001"; "sub001"], [1; 0], [8; 8], [200; 200], [20; 30], ...
          'VariableNames', {'Subject', 'Hemisphere', 'DiseaseDuration', 'Dose', 'UPDRS_OFF_hemibody'});
T = verifyWarning(tc, @() build_hemisphere_table(fake_stats(), C), 'build_hemisphere_table:noClinical');
verifyEqual(tc, T.Hemisphere, [0; 1; 0]);
verifyEqual(tc, T.Stimulation, [2; 2.5; 3]);
verifyEqual(tc, T.UPDRS_OFF_hemibody, [30; 20; NaN]);
verifyEqual(tc, T.DiseaseDuration, [8; 8; NaN]);
end

function test_duplicate_clinical_rows_error(tc)
C = table(["sub001"; "sub001"], [0; 0], [8; 9], ...
          'VariableNames', {'Subject', 'Hemisphere', 'DiseaseDuration'});
verifyError(tc, @() build_hemisphere_table(fake_stats(), C), 'build_hemisphere_table:duplicateRows');
end

%% read_clinical_data
function test_read_mat_with_categorical_columns(tc)
% Table as built in MATLAB: categorical Subject and Hemisphere (0/1).
T = table(categorical({'Sub001'; 'Sub001'}), categorical([0; 1]), categorical([3; 3]), [8; 8], ...
          'VariableNames', {'Subject', 'Hemisphere', 'State', 'DiseaseDuration'});
f = [tempname '.mat'];
save(f, 'T');
cleanup = onCleanup(@() delete(f));
C = read_clinical_data(f, {'DiseaseDuration'});
verifyEqual(tc, C.Subject, ["sub001"; "sub001"]);
verifyEqual(tc, C.Hemisphere, [0; 1]);          % value, not category index
verifyEqual(tc, C.DiseaseDuration, [8; 8]);
verifyFalse(tc, ismember('State', C.Properties.VariableNames));
end

function test_read_missing_column_errors(tc)
T = table("sub001", 0, 'VariableNames', {'Subject', 'Hemisphere'});
f = [tempname '.mat'];
save(f, 'T');
cleanup = onCleanup(@() delete(f));
verifyError(tc, @() read_clinical_data(f, {'Dose'}), 'read_clinical_data:missingColumn');
end
