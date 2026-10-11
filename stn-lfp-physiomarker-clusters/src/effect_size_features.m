function [mean_d_beta, mean_d_seg, beta_peak_freq] = effect_size_features(cohensd, freqs, fcfg)
%EFFECT_SIZE_FEATURES Summarise each hemisphere's Cohen's d spectrum.
%
%   [mean_d_beta, mean_d_seg, beta_peak_freq] = EFFECT_SIZE_FEATURES(cohensd, freqs, fcfg)
%   with cohensd [hemispheres x freqs]:
%
%     beta_peak_freq  frequency of the largest |d| within fcfg.beta_search
%     mean_d_beta     mean d within +/- fcfg.beta_halfwidth Hz of that
%                     hemisphere's own beta_peak_freq
%     mean_d_seg      mean d within fcfg.seg_band

n = size(cohensd, 1);
freqs = freqs(:).';
mean_d_beta = nan(n, 1);
mean_d_seg = nan(n, 1);
beta_peak_freq = nan(n, 1);

in_search = freqs >= fcfg.beta_search(1) & freqs <= fcfg.beta_search(2);
search_freqs = freqs(in_search);
in_seg = freqs >= fcfg.seg_band(1) & freqs <= fcfg.seg_band(2);

for i = 1:n
    d = cohensd(i, :);
    d_search = d(in_search);
    if ~all(isnan(d_search))
        [~, j] = max(abs(d_search));
        beta_peak_freq(i) = search_freqs(j);
        window = abs(freqs - beta_peak_freq(i)) <= fcfg.beta_halfwidth;
        mean_d_beta(i) = mean(d(window));
    end
    mean_d_seg(i) = mean(d(in_seg));
end
end
