# STN-LFP physiomarker clustering

MATLAB code for the descriptive k-means clustering of hemispheres by their levodopa physiomarker: an alpha/low-beta power decrease or a subharmonic entrained gamma (SEG) increase. The clustering combines effect sizes with stimulation and clinical variables.

This code accompanies:

> **[Authors]. [Title]. *[Journal]* ([Year]). doi:[DOI]**

It is the third stage of the analysis:

1. [stn-lfp-segment-psd]([URL]): epoch-wise power spectra
2. [stn-lfp-physiomarker-stats]([URL]): per-hemisphere medication effect and physiomarker
3. **stn-lfp-physiomarker-clusters** (this repository)

## Method

1. **Selection.** Hemispheres whose physiomarker is a significant decrease at 9–20 Hz (*beta*) or a significant increase at 61–64 Hz (*SEG*).
2. **Effect-size features**, from each hemisphere's Cohen's d spectrum (medication effect):
   - `mean_d_beta`: the mean d within ±2 Hz of the hemisphere's largest |d| between 9 and 20 Hz
   - `mean_d_seg`: the mean d at 62–64 Hz
3. **Clustering.** The clustering variables (default: `mean_d_beta`, `mean_d_seg` and `Stimulation`, the stimulation amplitude) are z-scored and grouped with k-means (k = 3, k-means++ start, best of 100 replicates, fixed seed). Clusters are numbered by ascending centroid on the first variable.
4. **Choice of k.** Elbow (within-cluster sum of squares) and silhouette values for k = 2–8.
5. **Description.** Per cluster: median and IQR of effect sizes, stimulation amplitude, levodopa dose per intake, disease duration and MDS-UPDRS-III (hemibody score of the contralateral body side); counts of physiomarker type and hemisphere.

The clustering is descriptive. No statistical tests compare the clusters, because the clustering variables define them, so such tests would be circular.

All settings are in `config/config_template.m`.

## Requirements

- MATLAB R2020b or later
- Statistics and Machine Learning Toolbox

## Input data

The patient data are not part of this repository. [Data availability statement.]

1. **`physiomarker_stats.mat`**, from stn-lfp-physiomarker-stats.
2. **Clinical table** with one row per hemisphere. This can be a spreadsheet (`.xlsx`, `.csv`) or a `.mat` file containing one MATLAB table. Rows are matched on `Subject` and `Hemisphere`; other columns are ignored.

| Column | Description |
|--------|-------------|
| `Subject` | Subject ID matching the session IDs, e.g. `sub001` (case-insensitive) |
| `Hemisphere` | 0 = left, 1 = right |
| `DiseaseDuration` | Disease duration (years) |
| `Dose` | Levodopa dose per intake (mg) |
| `UPDRS_OFF_hemibody` | MDS-UPDRS-III, MED OFF / STIM OFF |
| `UPDRS_med_on_stim` | MED ON / STIM ON |
| `UPDRS_med_off_stim` | MED OFF / STIM ON |
| `UPDRS_med_effect` | MED ON / STIM ON minus MED OFF / STIM OFF (medication and stimulation combined) |
| `UPDRS_stim_effect` | MED OFF / STIM ON minus MED OFF / STIM OFF |
| `UPDRS_med_effect_abs` | MED ON / STIM ON minus MED OFF / STIM ON (medication effect under stimulation) |

All UPDRS values are hemibody scores of the body side contralateral to the hemisphere. The stimulation amplitude (`Stimulation`) comes from the recordings, not from this table.

## Usage

1. Create `config/config_local.m` (git-ignored):

   ```matlab
   function cfg = config_local()
   cfg = config_template();
   cfg.paths.stats_results = 'D:\results\physiomarker_stats.mat';
   cfg.paths.clinical_file = 'D:\data\clinical.mat';   % or .xlsx / .csv
   cfg.paths.output_dir    = 'D:\results\clusters';
   end
   ```

2. Run from the repository root:

   ```matlab
   run_physiomarker_clusters
   ```

## Output

The output folder contains:

- **`physiomarker_clusters.mat`**:
  - `clusters`: one row per clustered hemisphere, with physiomarker type, features, clinical variables and `cluster`
  - `centroids`: in z-units
  - `summary`
  - the elbow and silhouette values
  - the settings used
- **`cluster_summary.csv`**: median and IQR per cluster and variable
- **`figures/`**: clusters in principal-component space, box/swarm charts per variable, and the elbow and silhouette plots

## Tests

```matlab
results = runtests('tests');
```

The tests run on GitHub Actions for every push.

## Citation

If you use this code, please cite the paper above. Citation metadata is in `CITATION.cff`.

## License

MIT; see `LICENSE`.

## Contact

Martijn de Neeling, Department of Neurology, Amsterdam UMC.
