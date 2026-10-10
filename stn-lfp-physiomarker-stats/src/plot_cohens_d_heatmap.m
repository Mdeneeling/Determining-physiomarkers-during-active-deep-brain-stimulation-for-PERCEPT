function fig = plot_cohens_d_heatmap(T, freqs, alpha, clim_d, title_text)
%PLOT_COHENS_D_HEATMAP Cohen's d per hemisphere and frequency.
%
%   fig = PLOT_COHENS_D_HEATMAP(T, freqs, alpha, clim_d, title_text) shows
%   T.cohensd as a heatmap with rows sorted by stimulation amplitude
%   (highest at the top). White dots mark frequencies with a
%   cluster-corrected p < alpha. Row labels and data are sorted together.

[~, order] = sort(T.stim_mA, 'descend');
T = T(order, :);
n = height(T);

fig = figure('Color', 'white', 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);
imagesc(freqs, 1:n, T.cohensd);
colormap(diverging_colormap(256));
caxis(clim_d);
cb = colorbar;
cb.Label.String = 'Cohen''s d';
hold on

[rows, cols] = find(T.prob < alpha);
plot(freqs(cols), rows, '.w', 'MarkerSize', 10);
hold off

labels = compose("%s %.1f mA", T.subject, T.stim_mA);
set(gca, 'YTick', 1:n, 'YTickLabel', labels, 'FontSize', 14, 'TickLabelInterpreter', 'none');
xlabel('Frequency (Hz)');
ylabel('Subject (stimulation amplitude)');
title(title_text, 'Interpreter', 'none');
end


function cmap = diverging_colormap(m)
%DIVERGING_COLORMAP Blue-white-red colormap with white at zero.
half = floor(m / 2);
up = linspace(0, 1, half)';
blue = [up, up, ones(half, 1)];
red = [ones(m - half, 1), flipud(linspace(0, 1, m - half)'), flipud(linspace(0, 1, m - half)')];
cmap = [blue; red];
end
