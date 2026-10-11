function tests = test_clustering
%TEST_CLUSTERING Unit tests for k-means labelling, k selection and summaries.
tests = functiontests(localfunctions);
end

function setupOnce(~)
addpath(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'src'));
end

function X = three_blobs()
rng(5);
X = [randn(20, 2) * 0.2 + [-5 0]; ...
     randn(20, 2) * 0.2 + [5 0]; ...
     randn(20, 2) * 0.2 + [0 5]];
end

function test_labels_ordered_by_first_variable(tc)
X = three_blobs();
for seed = 1:5   % same labels whatever the random start
    rng(seed);
    idx = run_kmeans(X, 3, 5);
    verifyEqual(tc, idx, [ones(20, 1); 3 * ones(20, 1); 2 * ones(20, 1)]);
end
end

function test_k_selection_prefers_true_k(tc)
X = zscore(three_blobs());
rng(1);
[sumd, sil] = k_selection(X, 2:5, 5);
verifySize(tc, sil, [60 4]);
[~, best] = max(mean(sil, 1));
verifyEqual(tc, best, 2);            % k = 3 is the 2nd entry of 2:5
verifyTrue(tc, all(diff(sumd) <= 1e-9));
end

function test_summary(tc)
T = table([1; 2; 3; 4; NaN; 10], 'VariableNames', {'x'});
idx = [1; 1; 1; 1; 2; 2];
S = summarize_clusters(T, idx, {'x'});
verifyEqual(tc, S.cluster, [1; 2]);
verifyEqual(tc, S.n, [4; 1]);
verifyEqual(tc, S.median, [2.5; 10]);
verifyEqual(tc, [S.q1(1), S.q3(1)], quantile([1 2 3 4], [0.25 0.75]));
end
