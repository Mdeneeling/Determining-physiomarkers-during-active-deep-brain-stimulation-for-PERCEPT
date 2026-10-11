%RUN_PHYSIOMARKER_CLUSTERS Descriptive k-means clustering of medication physiomarkers.
%
%   Hemispheres whose medication physiomarker is an alpha/low-beta decrease
%   or a subharmonic entrained gamma (SEG) increase are summarised by their
%   Cohen's d spectrum (mean d around the beta peak and in the SEG band)
%   and clinical/stimulation variables, z-scored, and grouped with k-means.
%   The clusters are described (median, IQR, counts); no inferential tests
%   are performed between clusters, because the clustering variables would
%   make such tests circular.
%
%   Input:  physiomarker_stats.mat from stn-lfp-physiomarker-stats, and a
%           clinical table (one row per hemisphere).
%   Output: <output_dir>/physiomarker_clusters.mat, cluster_summary.csv
%           and figures.
%   Settings: config/config_local.m (see config/config_template.m).

root = fileparts(mfilename('fullpath'));
addpath(fullfile(root, 'src'), fullfile(root, 'config'));

if exist('config_local', 'file') ~= 2
    error(['config/config_local.m not found. Create it with a function ' ...
           'config_local that calls config_template() and sets cfg.paths ' ...
           '(see README).']);
end
cfg = config_local();

%% Load physiomarkers and clinical data
in = load(cfg.paths.stats_results, 'stats', 'freqs');
freqs = in.freqs(:).';
clinical = read_clinical_data(cfg.paths.clinical_file, cfg.clinical.variables);
T = build_hemisphere_table(in.stats.medication, clinical);

%% Select hemispheres with a beta or SEG physiomarker
T.type = classify_physiomarker(T.peak_freq, T.direction, cfg.types);
fprintf('Physiomarkers: %d beta, %d SEG, %d other/none (of %d hemispheres).\n', ...
        sum(T.type == "beta"), sum(T.type == "seg"), sum(T.type == ""), height(T));
T = T(T.type ~= "", :);

%% Effect-size features
[mean_d_beta, mean_d_seg, beta_peak_freq] = effect_size_features(T.cohensd, freqs, cfg.features);
T.mean_d_beta = mean_d_beta;
T.mean_d_seg = mean_d_seg;
T.beta_peak_freq = beta_peak_freq;

%% k-means on z-scored features
X = T{:, cfg.kmeans.features};
complete = all(~isnan(X), 2);
if any(~complete)
    fprintf('Excluding %d hemisphere(s) with missing clustering variables: %s\n', ...
            sum(~complete), strjoin(T.Subject(~complete) + " (Hemisphere " + T.Hemisphere(~complete) + ")", ', '));
end
T = T(complete, :);
X = X(complete, :);

rng(cfg.kmeans.seed, 'twister');
[cluster, centroids, Xz] = run_kmeans(X, cfg.kmeans.k, cfg.kmeans.replicates);
T.cluster = cluster;

rng(cfg.kmeans.seed, 'twister');
k_range = cfg.kmeans.k_range(:).';
[total_sumd, silhouettes] = k_selection(Xz, k_range, cfg.kmeans.replicates);

%% Describe clusters
summary = summarize_clusters(T, T.cluster, cfg.summary.variables);

fprintf('\nClustering variables: %s (k = %d, %d hemispheres)\n', ...
        strjoin(cfg.kmeans.features, ', '), cfg.kmeans.k, height(T));
fprintf('Mean silhouette value at k = %d: %.2f\n', cfg.kmeans.k, ...
        mean(silhouettes(:, k_range == cfg.kmeans.k)));
for c = 1:cfg.kmeans.k
    in_c = T.cluster == c;
    fprintf('\nCluster %d: %d hemispheres (%d beta, %d SEG; %d left, %d right)\n', c, ...
            sum(in_c), sum(in_c & T.type == "beta"), sum(in_c & T.type == "seg"), ...
            sum(in_c & T.Hemisphere == 0), sum(in_c & T.Hemisphere == 1));
    S = summary(summary.cluster == c, :);
    for r = 1:height(S)
        fprintf('  %-22s %8.2f  [IQR %.2f to %.2f]  n = %d\n', ...
                S.variable(r), S.median(r), S.q1(r), S.q3(r), S.n(r));
    end
end

% Subjects with both hemispheres included: same cluster or not?
[subjects, ~, s_idx] = unique(T.Subject);
bilateral = accumarray(s_idx, 1) == 2;
same_cluster = accumarray(s_idx, T.cluster, [], @(c) numel(unique(c)) == 1);
fprintf('\nSubjects with both hemispheres clustered: %d, of which %d in the same cluster.\n', ...
        sum(bilateral), sum(bilateral & same_cluster));

%% Save
if ~exist(cfg.paths.output_dir, 'dir')
    mkdir(cfg.paths.output_dir);
end
clusters = removevars(T, 'cohensd');
cfg_saved = rmfield(cfg, 'paths');   % keep machine-specific paths out of the output
meta = struct('created', string(datetime('now')), 'matlab_version', version, ...
              'n_subjects', numel(subjects));
save(fullfile(cfg.paths.output_dir, 'physiomarker_clusters.mat'), ...
     'clusters', 'centroids', 'summary', 'k_range', 'total_sumd', 'silhouettes', ...
     'freqs', 'cfg_saved', 'meta');
writetable(summary, fullfile(cfg.paths.output_dir, 'cluster_summary.csv'));
fprintf('Saved results to %s\n', cfg.paths.output_dir);

%% Figures
fig = plot_clusters_pca(Xz, T.cluster, cfg.plot.colors, ...
                        'k-means clusters of alpha/low-beta and SEG physiomarkers');
save_figure(fig, cfg, 'clusters_pca');

for v = cfg.summary.variables
    fig = plot_cluster_variable(T.(v{1}), T.cluster, cfg.plot.colors, v{1});
    save_figure(fig, cfg, ['cluster_' v{1}]);
end

fig = plot_k_selection(k_range, total_sumd, silhouettes);
save_figure(fig, cfg, 'k_selection');
