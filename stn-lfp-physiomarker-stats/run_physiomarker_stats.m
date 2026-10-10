%RUN_PHYSIOMARKER_STATS Per-hemisphere medication physiomarkers in STN-LFP spectra.
%
%   For every hemisphere with a med-ON and a med-OFF recording, this script
%   compares the epoch-wise power spectra of the two sessions with a
%   cluster-based permutation test over frequency (FieldTrip) and computes
%   Cohen's d per frequency. The physiomarker of a hemisphere is the
%   frequency with the largest |Cohen's d| within the search range, counted
%   when its cluster p-value is below alpha and |d| exceeds a minimum.
%
%   As a null control, the same procedure compares two random halves of
%   the med-ON recording ('split_half'), which should rarely yield a
%   physiomarker.
%
%   Input:  psd_results.mat from stn-lfp-segment-psd.
%   Output: <output_dir>/physiomarker_stats.mat and figures.
%   Settings: config/config_local.m (see config/config_template.m).

root = fileparts(mfilename('fullpath'));
addpath(fullfile(root, 'src'), fullfile(root, 'config'));

if exist('config_local', 'file') ~= 2
    error(['config/config_local.m not found. Create it with a function ' ...
           'config_local that calls config_template() and sets cfg.paths ' ...
           '(see README).']);
end
cfg = config_local();

addpath(cfg.paths.fieldtrip_dir);
ft_defaults;

rng(cfg.stats.random_seed, 'twister');

%% Load epoch PSDs and pair med-ON / med-OFF sessions per hemisphere
in = load(cfg.paths.psd_results, 'results_all', 'freqs'); %replace by results_selected if you deleted some subjects
freqs = in.freqs(:).';
pairs = pair_sessions(in.results_all, cfg.conditions, cfg.input.psd_field);

%% Replace transient outlier epochs
n_replaced = 0;
n_values = 0;
for i = 1:height(pairs)
    [pairs.psd_on{i}, r_on]   = remove_epoch_outliers(pairs.psd_on{i},  cfg.preprocessing.outlier_sd);
    [pairs.psd_off{i}, r_off] = remove_epoch_outliers(pairs.psd_off{i}, cfg.preprocessing.outlier_sd);
    n_replaced = n_replaced + r_on + r_off;
    n_values = n_values + numel(pairs.psd_on{i}) + numel(pairs.psd_off{i});
end
fprintf('Outlier values replaced by the median: %d of %d (%.2f%%)\n', ...
        n_replaced, n_values, 100 * n_replaced / max(n_values, 1));

%% Keep hemispheres with enough epochs in both sessions
n_on  = cellfun(@(x) size(x, 1), pairs.psd_on);
n_off = cellfun(@(x) size(x, 1), pairs.psd_off);
min_epochs = max(cfg.preprocessing.min_epochs, 2);
% The split-half test needs at least min_epochs epochs in each half.
enough = n_on >= 2 * min_epochs & n_off >= min_epochs;
if any(~enough)
    fprintf('Skipping %d hemisphere(s) with too few epochs: %s\n', sum(~enough), ...
            strjoin(pairs.subject(~enough) + " " + pairs.hemisphere(~enough), ', '));
end
pairs = pairs(enough, :);
fprintf('%d hemispheres from %d subjects.\n', height(pairs), numel(unique(pairs.subject)));

%% Run analyses
stats = struct();
for a = cfg.analyses
    fprintf('Running %s analysis...\n', a{1});
    stats.(a{1}) = run_analysis(pairs, a{1}, freqs, cfg);
end

%% Summary
for a = cfg.analyses
    T = stats.(a{1});
    fprintf('%-11s: %d/%d hemispheres with a physiomarker (%d positive, %d negative); %d with p < %.3g at the peak.\n', ...
            a{1}, sum(T.direction ~= 0), height(T), sum(T.direction > 0), ...
            sum(T.direction < 0), sum(T.significant), cfg.stats.alpha);
end

%% Save results
if ~exist(cfg.paths.output_dir, 'dir')
    mkdir(cfg.paths.output_dir);
end
cfg_saved = rmfield(cfg, 'paths');   % keep machine-specific paths out of the output
meta = struct('created', string(datetime('now')), 'matlab_version', version);
try
    meta.fieldtrip_version = ft_version;
catch
    meta.fieldtrip_version = 'unknown';
end
out_file = fullfile(cfg.paths.output_dir, 'physiomarker_stats.mat');
save(out_file, 'stats', 'freqs', 'cfg_saved', 'meta', '-v7.3');
fprintf('Saved %s\n', out_file);

%% Figures
c = cfg.conditions;
titles.medication = sprintf('Medication effect (%s vs %s)', c.med_on_label, c.med_off_label);
titles.split_half = sprintf('Split-half null control (%s session)', c.med_on_label);
legend_labels.medication = {sprintf('Power %s > %s', c.med_on_label, c.med_off_label), ...
                            sprintf('Power %s > %s', c.med_off_label, c.med_on_label)};
legend_labels.split_half = {'Power half 1 > half 2', 'Power half 2 > half 1'};

for a = cfg.analyses
    T = stats.(a{1});
    for h = ["left", "right"]
        fig = plot_cohens_d_heatmap(T(T.hemisphere == h, :), freqs, cfg.stats.alpha, ...
                                    cfg.plot.clim, sprintf('%s, %s hemispheres', titles.(a{1}), h));
        save_figure(fig, cfg, sprintf('cohens_d_%s_%s', a{1}, h));
    end
    lbl = legend_labels.(a{1});
    fig = plot_peak_histogram(T, cfg.peak.freq_range, lbl{1}, lbl{2}, ...
                              sprintf('Physiomarker frequencies: %s', titles.(a{1})));
    save_figure(fig, cfg, sprintf('physiomarker_histogram_%s', a{1}));
end
