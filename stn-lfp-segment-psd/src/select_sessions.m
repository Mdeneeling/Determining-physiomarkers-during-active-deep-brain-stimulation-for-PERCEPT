function T = select_sessions(T, scfg)
%SELECT_SESSIONS Keep sessions with the requested condition codes and subjects.
%
%   T = SELECT_SESSIONS(T, scfg) keeps rows whose session_id (e.g.
%   'sub018_5A') ends with one of scfg.suffixes and whose subject
%   (the part before the first '_') is not in scfg.exclude_subjects.
%   Remove scfg.exclude_subjects if this is not relevant for your
%   experiment
%   Subject matching is case-insensitive.

ids = string(T.session_id);
by_condition = endsWith(ids, scfg.suffixes);

subjects = lower(extractBefore(ids, "_"));
excluded = ismember(subjects, lower(string(scfg.exclude_subjects)));

keep = by_condition & ~excluded;
fprintf('Selected %d of %d sessions (%d other conditions, %d excluded subjects).\n', ...
        sum(keep), numel(keep), sum(~by_condition), sum(by_condition & excluded));
T = T(keep, :);
end
