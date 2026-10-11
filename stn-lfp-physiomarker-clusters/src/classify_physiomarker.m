function type = classify_physiomarker(peak_freq, direction, types)
%CLASSIFY_PHYSIOMARKER Assign each physiomarker to a predefined type.
%
%   type = CLASSIFY_PHYSIOMARKER(peak_freq, direction, types) returns a
%   string array with, per hemisphere, the name of the field of types
%   (e.g. "beta", "seg") whose band contains peak_freq (inclusive) and whose
%   direction equals direction; "" when none matches (including hemispheres
%   without a physiomarker, direction 0).

type = strings(numel(peak_freq), 1);
for f = fieldnames(types)'
    t = types.(f{1});
    match = peak_freq(:) >= t.band(1) & peak_freq(:) <= t.band(2) & ...
            direction(:) == t.direction & type == "";
    type(match) = f{1};
end
end
