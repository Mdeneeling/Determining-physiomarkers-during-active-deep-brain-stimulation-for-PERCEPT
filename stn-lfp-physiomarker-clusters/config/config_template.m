function cfg = config_template()
%CONFIG_TEMPLATE Shared settings for the descriptive physiomarker clustering.
%
%   Machine-specific settings go in config/config_local.m (git-ignored):
%
%       function cfg = config_local()
%       cfg = config_template();
%       cfg.paths.stats_results = 'D:\results\physiomarker_stats.mat';
%       cfg.paths.clinical_file = 'D:\data\clinical.xlsx';
%       cfg.paths.output_dir    = 'D:\results\clusters';
%       end

% ---------------------------------------------------------------------
% Paths
% ---------------------------------------------------------------------
cfg.paths.stats_results = '/path/to/physiomarker_stats.mat';  % output of stn-lfp-physiomarker-stats
cfg.paths.clinical_file = '/path/to/clinical.xlsx';           % one row per hemisphere
cfg.paths.output_dir    = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'results');

% ---------------------------------------------------------------------
% Clinical data (one row per hemisphere)
% ---------------------------------------------------------------------
% A spreadsheet (.xlsx, .csv) or a .mat file with one table, containing
% Subject (e.g. sub001), Hemisphere (0 = left, 1 = right) and the
% variables below. UPDRS values are hemibody scores of the body side
% contralateral to the hemisphere. Other columns are ignored; stimulation
% amplitude is taken from the recordings (stn-lfp-segment-psd).
cfg.clinical.variables = { ...
    'DiseaseDuration', ...       % years
    'Dose', ...                  % levodopa dose per intake (mg)
    'UPDRS_OFF_hemibody', ...    % MED OFF / STIM OFF
    'UPDRS_med_on_stim', ...     % MED ON / STIM ON
    'UPDRS_med_off_stim', ...    % MED OFF / STIM ON
    'UPDRS_med_effect', ...      % MED ON / STIM ON  minus MED OFF / STIM OFF
    'UPDRS_stim_effect', ...     % MED OFF / STIM ON minus MED OFF / STIM OFF
    'UPDRS_med_effect_abs'};     % MED ON / STIM ON  minus MED OFF / STIM ON

% ---------------------------------------------------------------------
% Physiomarker types (from the medication analysis)
% ---------------------------------------------------------------------
% A hemisphere is included when its physiomarker (significant peak effect)
% falls in one of these bands with the given direction
% (-1: lower power MED ON, +1: higher power MED ON).
cfg.types.beta = struct('band', [9 20],  'direction', -1);   % alpha/low beta decrease
cfg.types.seg  = struct('band', [61 64], 'direction', +1);   % subharmonic entrained gamma increase

% ---------------------------------------------------------------------
% Effect-size features (computed for every included hemisphere)
% ---------------------------------------------------------------------
% mean_d_beta: mean Cohen's d within +/- beta_halfwidth Hz of the
%              hemisphere's own largest |d| in beta_search
% mean_d_seg:  mean Cohen's d within seg_band
cfg.features.beta_search    = [9 20];
cfg.features.beta_halfwidth = 2;
cfg.features.seg_band       = [62 64];

% ---------------------------------------------------------------------
% k-means
% ---------------------------------------------------------------------
% Variables used for clustering (z-scored). Any column of the hemisphere
% table can be listed.
cfg.kmeans.features   = {'mean_d_beta', 'mean_d_seg', 'Stimulation'};
cfg.kmeans.k          = 3;
cfg.kmeans.replicates = 100;
cfg.kmeans.k_range    = 2:8;     % range shown in the elbow and silhouette plots
cfg.kmeans.seed       = 42;

% ---------------------------------------------------------------------
% Descriptive summary per cluster (median and IQR)
% ---------------------------------------------------------------------
cfg.summary.variables = {'mean_d_beta', 'mean_d_seg', 'Stimulation', 'Dose', ...
                         'DiseaseDuration', 'UPDRS_OFF_hemibody', ...
                         'UPDRS_med_effect', 'UPDRS_med_effect_abs'};

% ---------------------------------------------------------------------
% Figures
% ---------------------------------------------------------------------
cfg.plot.colors = [255 128 0; 0 102 255; 175 38 38; 150 150 150] / 255;
cfg.plot.save       = true;
cfg.plot.resolution = 300;
end
