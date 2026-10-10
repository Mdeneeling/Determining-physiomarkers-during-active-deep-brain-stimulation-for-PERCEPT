function res = cluster_test(Y1, Y2, freqs, scfg, seed)
%CLUSTER_TEST Cluster-based permutation test and Cohen's d over frequency.
%
%   res = CLUSTER_TEST(Y1, Y2, freqs, scfg, seed) compares the epoch PSDs
%   Y1 (group 1) and Y2 (group 2), both [epochs x freqs], with an
%   independent-samples t-test and a two-sided cluster-based permutation
%   test over adjacent frequencies (FieldTrip, Monte Carlo, maxsum).
%   Cohen's d is computed per frequency (positive: group 1 > group 2).
%
%   res fields (all 1 x n_freqs unless noted):
%     prob          cluster-corrected p-value per frequency
%     stat          t-value per frequency
%     cohensd       Cohen's d per frequency
%     n_per_group   [n1 n2]
%     posclusters, negclusters   [n_clusters x 2] = [p, cluster statistic]
%
%   Requires FieldTrip on the path.

data1 = to_timelock(Y1, freqs);
data2 = to_timelock(Y2, freqs);
n1 = size(Y1, 1);
n2 = size(Y2, 1);
design = [ones(1, n1), 2 * ones(1, n2)];

cfg = [];
cfg.channel          = 'all';
cfg.neighbours       = [];
cfg.latency          = 'all';
cfg.method           = 'montecarlo';
cfg.statistic        = 'indepsamplesT';
cfg.correctm         = 'cluster';
cfg.clusteralpha     = scfg.cluster_alpha;
cfg.clusterstatistic = 'maxsum';
cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.correcttail      = scfg.correcttail;
cfg.alpha            = scfg.alpha;
cfg.numrandomization = scfg.n_permutations;
cfg.randomseed       = seed;
cfg.design           = design;
cfg.ivar             = 1;
cfg.feedback         = 'no';
stat = ft_timelockstatistics(cfg, data1, data2);

cfg = [];
cfg.channel   = 'all';
cfg.latency   = 'all';
cfg.method    = 'analytic';
cfg.statistic = 'cohensd';
cfg.design    = design;
cfg.ivar      = 1;
es = ft_timelockstatistics(cfg, data1, data2);

res.prob        = reshape(stat.prob, 1, []);
res.stat        = reshape(stat.stat, 1, []);
res.cohensd     = reshape(es.cohensd, 1, []);
res.n_per_group = [n1, n2];
res.posclusters = cluster_summary(stat, 'posclusters');
res.negclusters = cluster_summary(stat, 'negclusters');
end


function c = cluster_summary(stat, field)
%CLUSTER_SUMMARY [n_clusters x 2] matrix of cluster p-value and statistic.
c = zeros(0, 2);
if isfield(stat, field) && ~isempty(stat.(field))
    cl = stat.(field);
    c = [[cl.prob]', [cl.clusterstat]'];
end
end
