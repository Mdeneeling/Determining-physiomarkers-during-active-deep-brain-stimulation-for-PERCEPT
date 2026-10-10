function [psd, n_dropped] = epoch_psd(x, fs, epoch_len, window, overlap, freqs)
%EPOCH_PSD Welch PSD for consecutive non-overlapping epochs.
%
%   [psd, n_dropped] = EPOCH_PSD(x, fs, epoch_len, window, overlap, freqs)
%   splits signal x into consecutive, non-overlapping epochs of epoch_len
%   samples (a trailing partial epoch is discarded) and computes a Welch PSD
%   for each with PWELCH(epoch, window, overlap, freqs, fs, 'psd').
%
%   Epochs containing any NaN (e.g. packet loss) are dropped; their number
%   is returned in n_dropped. psd is [n_kept_epochs x numel(freqs)].

x = x(:);
n_epochs = floor(numel(x) / epoch_len);
psd  = nan(n_epochs, numel(freqs));
keep = false(n_epochs, 1);

for k = 1:n_epochs
    seg = x((k - 1) * epoch_len + 1 : k * epoch_len);
    if any(isnan(seg))
        continue
    end
    p = pwelch(seg, window, overlap, freqs, fs, 'psd');
    psd(k, :) = p(:).';
    keep(k) = true;
end

n_dropped = sum(~keep);
psd = psd(keep, :);
end
