function tests = test_resampling
%TEST_RESAMPLING Unit tests for split_half and equalize_epochs.
tests = functiontests(localfunctions);
end

function setupOnce(~)
addpath(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'src'));
end

%% split_half
function test_split_half_disjoint_and_complete(tc)
rng(1);
X = (1:11)' * [1 1];              % row k has value k
[A, B] = split_half(X);
verifySize(tc, A, [5 2]);
verifySize(tc, B, [6 2]);
verifyEqual(tc, sort([A(:, 1); B(:, 1)]), (1:11)');
verifyEmpty(tc, intersect(A(:, 1), B(:, 1)));
end

function test_split_half_reproducible(tc)
X = (1:20)';
rng(7); [A1, B1] = split_half(X);
rng(7); [A2, B2] = split_half(X);
verifyEqual(tc, [A1; B1], [A2; B2]);
end

%% equalize_epochs: subsample
function test_subsample_equal_counts_without_duplicates(tc)
rng(2);
X1 = (1:30)' * [1 1 1];
X2 = (101:112)' * [1 1 1];
[Y1, Y2] = equalize_epochs(X1, X2, 'subsample');
verifySize(tc, Y1, [12 3]);
verifySize(tc, Y2, [12 3]);
verifyEqual(tc, numel(unique(Y1(:, 1))), 12);    % no epoch drawn twice
verifyTrue(tc, all(ismember(Y1(:, 1), X1(:, 1))));
verifyEqual(tc, sort(Y2(:, 1)), X2(:, 1));        % smaller group kept whole
end

%% equalize_epochs: legacy
function test_legacy_bootstrap_shrinks_variance(tc)
% Documents why the legacy method is not recommended.
rng(3);
X = randn(5000, 1);
[Y1, ~] = equalize_epochs(X, X, 'legacy_bootstrap');
verifyEqual(tc, var(Y1), var(X) / 2, 'RelTol', 0.1);
end

function test_unknown_method_errors(tc)
verifyError(tc, @() equalize_epochs(1, 1, 'nope'), 'equalize_epochs:method');
end
