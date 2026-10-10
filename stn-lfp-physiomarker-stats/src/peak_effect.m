function pk = peak_effect(d, prob, freqs, freq_range, alpha, min_abs_d)
%PEAK_EFFECT Strongest effect within a frequency range and its significance.
%
%   pk = PEAK_EFFECT(d, prob, freqs, freq_range, alpha, min_abs_d) finds the
%   frequency with the largest |Cohen's d| within freq_range ([low high] Hz,
%   inclusive) and returns:
%
%     pk.freq         frequency of the peak (Hz)
%     pk.d            Cohen's d at the peak
%     pk.p            cluster-corrected p-value at the peak
%     pk.significant  pk.p < alpha
%     pk.direction    sign(pk.d) for a significant peak with |d| > min_abs_d,
%                     otherwise 0 (no physiomarker)

pk = struct('freq', NaN, 'd', NaN, 'p', NaN, 'significant', false, 'direction', 0);

in = freqs >= freq_range(1) & freqs <= freq_range(2);
f_in = freqs(in);
d_in = d(in);
p_in = prob(in);
if isempty(d_in) || all(isnan(d_in))
    return
end

[~, i] = max(abs(d_in));
pk.freq = f_in(i);
pk.d = d_in(i);
pk.p = p_in(i);
pk.significant = pk.p < alpha;
if pk.significant && abs(pk.d) > min_abs_d
    pk.direction = sign(pk.d);
end
end
