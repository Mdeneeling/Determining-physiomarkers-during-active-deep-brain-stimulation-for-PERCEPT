function save_figure(fig, cfg, name)
%SAVE_FIGURE Save a figure as .png and .fig in cfg.paths.output_dir.
%
%   SAVE_FIGURE(fig, cfg, name) does nothing when cfg.plot.save is false.

if ~cfg.plot.save
    return
end
fig_dir = fullfile(cfg.paths.output_dir, 'figures');
if ~exist(fig_dir, 'dir')
    mkdir(fig_dir);
end
exportgraphics(fig, fullfile(fig_dir, [name '.png']), 'Resolution', cfg.plot.resolution);
savefig(fig, fullfile(fig_dir, [name '.fig']));
end
