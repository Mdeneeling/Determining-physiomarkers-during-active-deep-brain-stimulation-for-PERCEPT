function T = build_hemisphere_table(M, C)
%BUILD_HEMISPHERE_TABLE Combine physiomarker results with clinical data.
%
%   T = BUILD_HEMISPHERE_TABLE(M, C) takes the medication results table M
%   (stats.medication from stn-lfp-physiomarker-stats; one row per
%   hemisphere) and the clinical table C (from READ_CLINICAL_DATA; one row
%   per hemisphere) and returns one row per hemisphere with:
%
%     Subject, Hemisphere (0 = left, 1 = right)
%     Stimulation           mean stimulation amplitude in the recording (mA)
%     peak_freq, peak_d, direction, cohensd   physiomarker and d spectrum
%     all clinical variables of C (e.g. DiseaseDuration, Dose,
%     UPDRS_OFF_hemibody, UPDRS_med_effect, ...)
%
%   Rows are matched on Subject and Hemisphere. Hemispheres missing from C
%   get NaN clinical values (with a warning).

n = height(M);
T = table();
T.Subject     = string(M.subject);
T.Hemisphere  = double(string(M.hemisphere) == "right");   % 0 = left, 1 = right
T.Stimulation = M.stim_mA;
T.peak_freq   = M.peak_freq;
T.peak_d      = M.peak_d;
T.direction   = M.direction;
T.cohensd     = M.cohensd;

key_T = lower(T.Subject) + "_" + string(T.Hemisphere);
key_C = string(C.subject) + "_" + string(C.hemisphere);
if numel(unique(key_C)) < numel(key_C)
    error('build_hemisphere_table:duplicateRows', ...
          'Clinical data has more than one row for the same Subject and Hemisphere.');
end
[found, loc] = ismember(key_T, key_C);
if any(~found)
    warning('build_hemisphere_table:noClinical', ...
            'No clinical data for (Subject, Hemisphere): %s', strjoin(key_T(~found), ', '));
end

vars = setdiff(C.Properties.VariableNames, {'Subject', 'Hemisphere'}, 'stable');
for k = 1:numel(vars)
    v = nan(n, 1);
    v(found) = C.(vars{k})(loc(found));
    T.(vars{k}) = v;
end
end
