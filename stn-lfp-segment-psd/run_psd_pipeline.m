%RUN_PSD_PIPELINE Compute segment-wise power spectra of STN local field potentials.
%
%   Written by M.G.J. de Neeling
%
%   For every selected Percept BrainSense Time Domain recording, this script
%   computes Welch power spectral densities (PSDs) in non-overlapping epochs
%   for four segments of the recording:
%
%     rest                      - the resting-state segment
%     bradykinesia (brady)      - the UPDRS-III bradykinesia segment (same duration as rest)
%     random                    - a randomly placed segment of 1 minute, drawn from
%                                 the bradykinesia start onward (control segment)
%     total                     - the full recording
%
%   Settings are read from config/config_local.m (see config_template.m).
%   Results are saved to <output_dir>/psd_results.mat.

root = fileparts(mfilename('fullpath'));
addpath(fullfile(root, 'src'), fullfile(root, 'config'));

if exist('config_local', 'file') ~= 2
    error(['config/config_local.m not found. Copy config/config_template.m ' ...
           'to config/config_local.m, rename the function to config_local ' ...
           'and fill in your paths.']);
end
cfg = config_local();

rng(cfg.random_seed, 'twister');

%% Select stream files and link them to session timings
files    = list_stream_files(cfg.paths.stream_dir, cfg.files);
sessions = build_session_table(cfg, files);
sessions = apply_timing_overrides(sessions, cfg.timing_overrides);
fprintf('%d sessions with a stream file and complete timings.\n', height(sessions));

%% Compute PSDs per session
results = cell(height(sessions), 1);
for i = 1:height(sessions)
    fprintf('[%d/%d] %s\n', i, height(sessions), sessions.session_id(i));
    S = load(sessions.stream_path(i), 'dataBSTD');
    r = compute_session_psd(S.dataBSTD, sessions(i, :), cfg);
    results{i} = r;
end
results_all = results_to_table(results, sessions);

%% Select sessions for the final dataset
% Only use if you need to remove subjects due to incomplete data
% results_selected = select_sessions(results_all, cfg.sessions);

%% Save
if ~exist(cfg.paths.output_dir, 'dir')
    mkdir(cfg.paths.output_dir);
end
freqs = cfg.spectral.freqs;
meta = struct('created', string(datetime('now')), ...
              'matlab_version', version, ...
              'n_sessions_all', height(results_all), ...
              'n_sessions_selected', height(results_all)); %replace by results_all if you did not remove subjects in block before or use results_selected if you did. 
cfg_saved = rmfield(cfg, 'paths');   % keep machine-specific paths out of the output
out_file = fullfile(cfg.paths.output_dir, 'psd_results.mat');
save(out_file, 'results_all', 'results_all', 'freqs', 'cfg_saved', 'meta', '-v7.3');
fprintf('Saved %s\n', out_file);


function T = results_to_table(results, sessions)
%RESULTS_TO_TABLE Combine per-session result structs into one table.
T = sessions(:, {'session_id', 'stream_file'});
if isempty(results)
    return
end
fn = fieldnames(results{1});
for f = fn'
    vals = cellfun(@(r) r.(f{1}), results, 'UniformOutput', false);
    is_scalar = cellfun(@(v) isnumeric(v) && isscalar(v), vals);
    if all(is_scalar)
        T.(f{1}) = vertcat(vals{:});
    else
        T.(f{1}) = vals;
    end
end
end
