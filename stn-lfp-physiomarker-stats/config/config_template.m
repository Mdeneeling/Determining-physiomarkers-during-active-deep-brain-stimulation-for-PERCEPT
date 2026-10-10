function cfg = config_template()
%CONFIG_TEMPLATE Shared settings for the physiomarker statistics.
%
%   Machine-specific settings go in config/config_local.m (git-ignored):
%
%       function cfg = config_local()
%       cfg = config_template();
%       cfg.paths.psd_results  = 'D:\results\psd_results.mat';
%       cfg.paths.fieldtrip_dir = 'D:\toolboxes\fieldtrip-20240916';
%       cfg.paths.output_dir   = 'D:\results\physiomarkers';
%       end

% ---------------------------------------------------------------------
% Paths
% ---------------------------------------------------------------------
cfg.paths.psd_results   = '/path/to/psd_results.mat';  % output of stn-lfp-segment-psd
cfg.paths.fieldtrip_dir = '/path/to/fieldtrip';        % tested with fieldtrip-20240916
cfg.paths.output_dir    = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'results');

% ---------------------------------------------------------------------
% Input
% ---------------------------------------------------------------------
% Which epoch PSDs to use from psd_results.mat:
% 'psd_total' (full recording), 'psd_rest', 'psd_brady' or 'psd_random'.
cfg.input.psd_field = 'psd_total';

% ---------------------------------------------------------------------
% Conditions (session-ID suffixes)
% ---------------------------------------------------------------------
% The medication effect compares med_on (group 1) with med_off (group 2);
% a positive Cohen's d means higher power in med_on.
% Both sessions are recorded ON stimulation.
cfg.conditions.med_on        = 'A';
cfg.conditions.med_off       = 'D';
cfg.conditions.med_on_label  = 'MED ON';
cfg.conditions.med_off_label = 'MED OFF';

% Analyses to run:
%   'medication'  - med_on vs med_off epochs
%   'split_half'  - null control: two random, disjoint halves of the
%                   med_on session compared with the same test
cfg.analyses = {'medication', 'split_half'};

% ---------------------------------------------------------------------
% Preprocessing
% ---------------------------------------------------------------------
% Per frequency bin, epochs that stand out from their neighbouring epochs
% by more than outlier_sd standard deviations (FINDPEAKS 'Threshold') are
% replaced by the median of that bin. Set to 0 to disable.
cfg.preprocessing.outlier_sd = 5;

% Hemispheres with fewer epochs than this in either session are skipped.
cfg.preprocessing.min_epochs = 2;

% ---------------------------------------------------------------------
% Statistics (FieldTrip cluster-based permutation test)
% ---------------------------------------------------------------------
cfg.stats.n_permutations = 10000;
cfg.stats.cluster_alpha  = 0.05;     % threshold for cluster-forming samples
cfg.stats.alpha          = 0.05;     % significance of the cluster p-value
% Two-sided test: 'prob' doubles the per-tail cluster p-values so they can
% be compared with alpha directly (see FieldTrip FAQ on cfg.correcttail).
cfg.stats.correcttail    = 'prob';
% How epoch counts are equalised between the two groups:
%   'subsample'        - draw the smaller group's count from each group
%                        without replacement (recommended)
%   'legacy_bootstrap' - original implementation: each sample is the mean
%                        of two draws with replacement; inflates Cohen's d.
%                        Only for comparison with earlier results.
cfg.stats.resample       = 'subsample';
cfg.stats.random_seed    = 42;

% ---------------------------------------------------------------------
% Physiomarker (peak effect) definition
% ---------------------------------------------------------------------
cfg.peak.freq_range = [4 99];   % Hz; search range for the max |Cohen's d|
cfg.peak.min_abs_d  = 0.2;      % peaks with |d| <= this are not counted

% ---------------------------------------------------------------------
% Figures
% ---------------------------------------------------------------------
cfg.plot.clim       = [-1.3 1.3];   % Cohen's d colour range
cfg.plot.save       = true;
cfg.plot.resolution = 300;          % dpi
end
