function cfg = config_local()
%CONFIG_LOCAL Local settings for this machine (git-ignored, never committed).

cfg = config_template();

analysis_dir = 'L:\Basic\divd\knf\Onderzoek_projecten\AI_DBS\Analyse\scripts_medicatie';

cfg.paths.psd_results   = fullfile(analysis_dir, 'Entrained_gamma_project', 'results_psd', 'psd_results.mat');
cfg.paths.fieldtrip_dir = fullfile(analysis_dir, 'fieldtrip-20240916');
% Keep patient-derived results on the secured drive, not in the repo folder.
cfg.paths.output_dir    = fullfile(analysis_dir, 'Entrained_gamma_project', 'results_physiomarkers');

% To reproduce the original implementation for comparison:
% cfg.stats.resample    = 'legacy_bootstrap';
% cfg.stats.correcttail = 'no';
end
