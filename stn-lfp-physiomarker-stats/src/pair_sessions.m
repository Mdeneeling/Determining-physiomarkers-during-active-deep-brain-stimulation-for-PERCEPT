function pairs = pair_sessions(results, conditions, psd_field)
%PAIR_SESSIONS Pair the med-ON and med-OFF session of each hemisphere.
%
%   pairs = PAIR_SESSIONS(results, conditions, psd_field) takes the
%   per-session table from stn-lfp-segment-psd (results_selected) and
%   returns one row per subject and hemisphere with:
%
%     subject, hemisphere ("left"/"right"), session_on, session_off,
%     stim_mA (mean amplitude in the med-ON session),
%     psd_on, psd_off ({[epochs x freqs]} epoch PSDs)
%
%   Sessions are identified by session_id '<subject>_<visit><code>', with
%   the condition codes conditions.med_on and conditions.med_off. Subjects
%   without exactly one session of each condition are skipped with a warning.

ids = string(results.session_id);
subjects_all = extractBefore(ids, "_");
subjects = unique(subjects_all(~ismissing(subjects_all)), 'stable');

subject = strings(0, 1); hemisphere = strings(0, 1);
session_on = strings(0, 1); session_off = strings(0, 1);
stim_mA = zeros(0, 1); psd_on = cell(0, 1); psd_off = cell(0, 1);

for s = subjects'
    i_on  = find(subjects_all == s & endsWith(ids, conditions.med_on));
    i_off = find(subjects_all == s & endsWith(ids, conditions.med_off));
    if numel(i_on) ~= 1 || numel(i_off) ~= 1
        warning('pair_sessions:incomplete', ...
                '%s: %d %s and %d %s session(s); skipped.', s, ...
                numel(i_on), conditions.med_on, numel(i_off), conditions.med_off);
        continue
    end
    for h = ["left", "right"]
        subject(end + 1, 1)     = s;
        hemisphere(end + 1, 1)  = h;
        session_on(end + 1, 1)  = ids(i_on);
        session_off(end + 1, 1) = ids(i_off);
        stim_mA(end + 1, 1)     = results.(char("stim_" + h))(i_on);
        psd_on{end + 1, 1}      = results.(char(psd_field + "_" + h)){i_on};
        psd_off{end + 1, 1}     = results.(char(psd_field + "_" + h)){i_off};
    end
end

pairs = table(subject, hemisphere, session_on, session_off, stim_mA, psd_on, psd_off);
end
