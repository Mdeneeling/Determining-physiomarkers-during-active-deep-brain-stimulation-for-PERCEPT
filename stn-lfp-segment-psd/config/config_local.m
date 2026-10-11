function cfg = config_local()
%CONFIG_LOCAL example local settings
%
%   Starts from the shared defaults in config_template.m and only overrides
%   what is specific to this machine. Changes to analysis settings belong
%   in config_template.m so they are versioned with the code.

cfg = config_template();

% ---------------------------------------------------------------------
% Paths
% ---------------------------------------------------------------------
project_dir = '';
analysis_dir = fullfile(project_dir, 'Analyse', 'scripts_medicatie', 'Entrained_gamma_project');

cfg.paths.stream_dir    = fullfile(project_dir, 'Data_unpacked', 'BrainSenseTimeDomain');
cfg.paths.timing_file   = fullfile(analysis_dir, 'UPDRS-III_tijden.xlsx');
cfg.paths.matching_file = fullfile(analysis_dir, 'Troubleshoot.xlsx');
% Keep patient-derived results on the secured drive, not in the repo folder.
cfg.paths.output_dir    = fullfile(analysis_dir, 'results_psd');

end
