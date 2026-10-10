# STN-LFP medication physiomarkers

MATLAB code to identify, per hemisphere, the frequency at which levodopa changes subthalamic nucleus (STN) local field potential power most (the *physiomarker*). It uses a cluster-based permutation test over frequency and Cohen's d. Recordings were made with the Medtronic Percept™ PC during the MDS-UPDRS part III examination.

This code accompanies:

> **[Authors]. [Title]. *[Journal]* ([Year]). doi:[DOI]**

It is the second stage of the analysis. The first stage, which computes the epoch-wise power spectra, is in [stn-lfp-segment-psd]([GitHub URL]).

## Method

For each hemisphere with both a med-ON and a med-OFF recording (both ON stimulation):

1. **Input.** Welch PSDs of consecutive 2-s epochs (2–100 Hz, 1-Hz steps) from `psd_results.mat`. By default, the full recording is used.
2. **Outlier epochs.** Per frequency bin, an epoch that exceeds both neighbouring epochs by more than 5 SD of that bin (`findpeaks`, `'Threshold'`) is replaced by the bin median.
3. **Equal epoch counts.** The larger session is randomly subsampled, without replacement, to the epoch count of the smaller one.
4. **Statistics.** Epochs are the observations, and med-ON is compared with med-OFF using FieldTrip's `ft_timelockstatistics`. The test is an independent-samples t-test with a two-sided Monte Carlo cluster-based permutation test over adjacent frequencies (maxsum, cluster-forming α = 0.05, 10,000 permutations). The two-tail correction is `correcttail = 'prob'`. Cohen's d is computed per frequency; positive d means higher power med-ON.
5. **Physiomarker.** The frequency with the largest |d| between 4 and 99 Hz. It counts as a physiomarker when its cluster-corrected p < 0.05 and |d| > 0.2.

**Null control (split-half).** The same procedure is applied to two random, disjoint halves of the med-ON recording. Because both halves come from the same condition, physiomarkers should rarely be found. The detection rate here estimates the false-positive rate of the procedure.

All settings are in `config/config_template.m`.

## Requirements

- MATLAB R2020a or later
- Signal Processing Toolbox
- [FieldTrip](https://www.fieldtriptoolbox.org) (tested with version 20240916)

## Input data

The patient data are not part of this repository. [Data availability statement.]

The input is `psd_results.mat` from stn-lfp-segment-psd. It must contain the table `results_selected` and the frequency vector `freqs`. Sessions are matched by their ID `<subject>_<visit><condition>`, for example `sub001_5A`. The condition codes for med-ON and med-OFF are set in the configuration.

## Usage

1. Create `config/config_local.m` (git-ignored) that loads the defaults and sets your paths:

   ```matlab
   function cfg = config_local()
   cfg = config_template();
   cfg.paths.psd_results   = 'D:\results\psd_results.mat';
   cfg.paths.fieldtrip_dir = 'D:\toolboxes\fieldtrip-20240916';
   cfg.paths.output_dir    = 'D:\results\physiomarkers';
   end
   ```

2. Run the analysis from the repository root:

   ```matlab
   run_physiomarker_stats
   ```

With 10,000 permutations, the run takes [duration] for [N] hemispheres.

## Output

`physiomarker_stats.mat` in the output folder contains:

- `stats.medication` and `stats.split_half`: one row per hemisphere with:
  - `subject`, `hemisphere`, `stim_mA`
  - epochs per group (`n_per_group`)
  - per frequency: `cohensd`, `prob` (cluster-corrected p) and `tstat`
  - clusters (`posclusters`, `negclusters`: p-value and cluster statistic)
  - the physiomarker: `peak_freq`, `peak_d`, `peak_p`, `significant`, `direction` (+1, −1 or 0 for none)
- `freqs`, plus the settings used (`cfg_saved`) and run information (`meta`)

The `figures/` subfolder contains:

- Cohen's d heatmaps per analysis and hemisphere, with rows sorted by stimulation amplitude and significant frequencies marked
- Histograms of physiomarker frequencies by direction of effect

## Reproducibility

The random split, the epoch subsampling and each permutation test use fixed seeds (`cfg.stats.random_seed`). The same input and settings give the same results.

## Tests

```matlab
results = runtests('tests');
```

The unit tests do not need FieldTrip. They run on GitHub Actions for every push.

## Citation

If you use this code, please cite the paper above. Citation metadata is in `CITATION.cff`. This code uses FieldTrip:

> Oostenveld R, Fries P, Maris E, Schoffelen JM. FieldTrip: Open source software for advanced analysis of MEG, EEG, and invasive electrophysiological data. *Comput Intell Neurosci.* 2011;2011:156869. doi:10.1155/2011/156869

## License

MIT; see `LICENSE`.

## Contact

Martijn de Neeling, Department of Neurology, Amsterdam UMC.
