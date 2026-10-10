function T = run_analysis(pairs, analysis, freqs, cfg)
%RUN_ANALYSIS Cluster test and peak effect for every hemisphere.
%
%   T = RUN_ANALYSIS(pairs, analysis, freqs, cfg) runs one analysis on each
%   row of pairs (from PAIR_SESSIONS):
%
%     'medication'  psd_on (group 1) vs psd_off (group 2)
%     'split_half'  two random halves of psd_on (null control)
%
%   Returns a table with one row per hemisphere: identifiers, stimulation
%   amplitude, epochs per group, Cohen's d / p / t per frequency
%   ([n_hemispheres x n_freqs] columns), clusters, and the peak effect
%   (peak_freq, peak_d, peak_p, significant, direction).

n = height(pairs);
nf = numel(freqs);
cohensd = nan(n, nf);
prob = nan(n, nf);
tstat = nan(n, nf);
n_per_group = nan(n, 2);
posclusters = cell(n, 1);
negclusters = cell(n, 1);
peak_freq = nan(n, 1); peak_d = nan(n, 1); peak_p = nan(n, 1);
significant = false(n, 1); direction = zeros(n, 1);

% Separate seed ranges per analysis, so each test is reproducible on its own.
seed_offset = 100000 * find(strcmp(analysis, {'medication', 'split_half'}));

for i = 1:n
    fprintf('  [%s %d/%d] %s %s\n', analysis, i, n, pairs.subject(i), pairs.hemisphere(i));
    switch analysis
        case 'medication'
            X1 = pairs.psd_on{i};
            X2 = pairs.psd_off{i};
        case 'split_half'
            [X1, X2] = split_half(pairs.psd_on{i});
        otherwise
            error('run_analysis:unknown', 'Unknown analysis "%s".', analysis);
    end
    [Y1, Y2] = equalize_epochs(X1, X2, cfg.stats.resample);
    res = cluster_test(Y1, Y2, freqs, cfg.stats, cfg.stats.random_seed + seed_offset + i);

    cohensd(i, :) = res.cohensd;
    prob(i, :) = res.prob;
    tstat(i, :) = res.stat;
    n_per_group(i, :) = res.n_per_group;
    posclusters{i} = res.posclusters;
    negclusters{i} = res.negclusters;

    pk = peak_effect(res.cohensd, res.prob, freqs, cfg.peak.freq_range, ...
                     cfg.stats.alpha, cfg.peak.min_abs_d);
    peak_freq(i) = pk.freq;
    peak_d(i) = pk.d;
    peak_p(i) = pk.p;
    significant(i) = pk.significant;
    direction(i) = pk.direction;
end

T = pairs(:, {'subject', 'hemisphere', 'session_on', 'session_off', 'stim_mA'});
T.n_per_group = n_per_group;
T.cohensd = cohensd;
T.prob = prob;
T.tstat = tstat;
T.posclusters = posclusters;
T.negclusters = negclusters;
T.peak_freq = peak_freq;
T.peak_d = peak_d;
T.peak_p = peak_p;
T.significant = significant;
T.direction = direction;
end
