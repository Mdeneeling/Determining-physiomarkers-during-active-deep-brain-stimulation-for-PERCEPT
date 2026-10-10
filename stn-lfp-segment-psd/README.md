# STN-LFP segment-wise power spectra

MATLAB code to compute power spectral densities (PSDs) of subthalamic nucleus (STN) local field potentials recorded with the Medtronic Percept™ PC (BrainSense™ Time Domain streaming) during a resting-state period and during the MDS-UPDRS part III examination.

This code accompanies:

> **[Authors]. [Title]. *[Journal]* ([Year]). doi:[DOI]**

## What it does

For every selected recording, the pipeline computes Welch PSDs in consecutive, non-overlapping 2-s epochs for four segments, separately for the left and right hemisphere:

| Segment  | Definition |
|----------|------------|
| `rest`   | Resting-state period (start and end from the timing sheet) |
| `brady`  | UPDRS-III bradykinesia items: from the annotated start, with the same duration as the rest segment |
| `random` | Control segment with the same duration, starting at a uniformly random sample between the bradykinesia start and the end of the recording |
| `total`  | The full recording |

Spectral settings (in `config/config_template.m`): sampling rate 250 Hz; 2-s epochs; within each epoch, Welch's method with a 1-s Hamming window and 95% overlap; PSD evaluated at 2–100 Hz in 1-Hz steps.

Epochs containing missing samples (NaN, e.g. from packet loss) are dropped; the number dropped per segment is reported. A hemisphere without a recorded channel yields no epochs.

## Requirements

- MATLAB R2019b or later
- Signal Processing Toolbox

## Input data

The patient data are not part of this repository. [Data availability statement: describe how the data can be requested.]

The pipeline expects:

1. **Stream files**: one `.mat` file per recording, containing a struct `dataBSTD` with
   - `lfp_ecg`: `[samples × channels]` LFP (ECG-cleaned), sampled at 250 Hz
   - `channels`: channel labels containing `LEFT` or `RIGHT`
   - `stim.amp`: `[samples × hemispheres]` stimulation amplitude (mA)
2. **Timing sheet** (`.xlsx`): per session, the session ID and the clock times of the LFP recording start, rest start, rest end and bradykinesia start.
3. **Matching sheet** (`.xlsx`): links each session ID to its stream file name.

Column positions and file-name patterns are set in the configuration.

## Usage

```matlab
% 1. Create your local configuration (git-ignored)
copyfile('config/config_template.m', 'config/config_local.m')
% 2. In config_local.m: rename the function to config_local and set the paths
% 3. Run
run_psd_pipeline
```

Results are saved to `results/psd_results.mat`:

- `results_all`: one row per session, all conditions
- `results_selected`: the sessions used in the analysis (selected condition codes, excluded subjects removed)
- `freqs`: the frequency axis (Hz)
- `cfg_saved`, `meta`: the settings used and run information

Per session, the tables hold `psd_<segment>_<hemisphere>` (`[epochs × frequencies]`), `psd_mean_left/right` (mean over all clean epochs of the recording), `n_dropped_<segment>_<hemisphere>`, `stim_left/right` (mean amplitude), `channels` and `random_start_s`.

## Session selection

Sessions are kept when their ID ends with one of the configured condition codes ([describe codes, e.g. A = …, D = …]). The following subjects are excluded: [list with reasons, e.g. incomplete follow-up, artefacts].

## Reproducibility

The random control segment is drawn with a fixed seed (`cfg.random_seed`). Draws happen in session order, so the same input files and settings give the same segments.

## Tests

```matlab
results = runtests('tests');
```

Tests also run automatically on GitHub Actions for every push.

## Repository structure

```
run_psd_pipeline.m      main script
config/                 configuration template
src/                    functions
tests/                  unit tests
```

## Citation

If you use this code, please cite the paper above. Citation metadata is in `CITATION.cff`.

## License

MIT; see `LICENSE`.

## Contact

Martijn de Neeling, Department of Neurology, Amsterdam UMC.
