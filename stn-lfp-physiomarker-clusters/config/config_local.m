function cfg = config_local()
%CONFIG_LOCAL Local settings for this machine (git-ignored, never committed).

cfg = config_template();

project_dir = fullfile('L:\Basic\divd\knf\Onderzoek_projecten\AI_DBS\Analyse\scripts_medicatie', ...
                       'Entrained_gamma_project');

cfg.paths.stats_results = fullfile(project_dir, 'results_physiomarkers', 'physiomarker_stats.mat');
cfg.paths.clinical_file = fullfile(project_dir, 'clinical_data.mat');    % TODO: your table T (one row per hemisphere), or .xlsx/.csv
% Keep patient-derived results on the secured drive, not in the repo folder.
cfg.paths.output_dir    = fullfile(project_dir, 'results_clusters');
end
