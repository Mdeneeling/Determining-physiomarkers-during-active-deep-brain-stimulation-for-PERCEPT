function cfg = config_local()
%CONFIG_LOCAL example of local settings

cfg = config_template();

analysis_dir = '';

cfg.paths.psd_results   = fullfile(analysis_dir, 'Entrained_gamma_project', 'results_psd', 'psd_results.mat');
cfg.paths.fieldtrip_dir = fullfile(analysis_dir, 'fieldtrip-20240916');
% Keep patient-derived results on the secured drive, not in the repo folder.
cfg.paths.output_dir    = fullfile(analysis_dir, 'Entrained_gamma_project', 'results_physiomarkers');

end
