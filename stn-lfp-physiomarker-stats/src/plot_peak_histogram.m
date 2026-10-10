function fig = plot_peak_histogram(T, freq_range, label_pos, label_neg, title_text)
%PLOT_PEAK_HISTOGRAM Distribution of physiomarker frequencies by direction.
%
%   fig = PLOT_PEAK_HISTOGRAM(T, freq_range, label_pos, label_neg, title_text)
%   counts, per 1-Hz bin, the hemispheres whose physiomarker (significant
%   peak effect, T.direction ~= 0) lies at that frequency, separately for
%   positive (label_pos) and negative (label_neg) effects.

edges = (freq_range(1) - 0.5):1:(freq_range(2) + 0.5);
centers = edges(1:end - 1) + 0.5;
pos_counts = histcounts(T.peak_freq(T.direction > 0), edges);
neg_counts = histcounts(T.peak_freq(T.direction < 0), edges);

fig = figure('Color', 'white');
hold on
bar(centers - 0.2, neg_counts, 0.4, 'FaceColor', [255 140 0] / 255, 'DisplayName', label_neg);
bar(centers + 0.2, pos_counts, 0.4, 'FaceColor', [57 98 224] / 255, 'DisplayName', label_pos);
hold off
xlim([0, freq_range(2) + 1]);
xlabel('Frequency (Hz)');
ylabel('Number of hemispheres');
title(title_text, 'Interpreter', 'none');
legend('Location', 'northeast');
legend boxoff
set(gca, 'FontSize', 20);
end
