function sessions = apply_timing_overrides(sessions, overrides)
%APPLY_TIMING_OVERRIDES Replace rest-segment timings for listed sessions.
%
%   sessions = APPLY_TIMING_OVERRIDES(sessions, overrides) sets rest_start_s
%   and rest_end_s for each session in the struct array overrides (fields
%   session_id, rest_start_s, rest_end_s). The bradykinesia end is
%   recomputed so that its duration still equals the rest duration.

for k = 1:numel(overrides)
    o = overrides(k);
    idx = find(sessions.session_id == string(o.session_id));
    if isempty(idx)
        warning('apply_timing_overrides:notFound', ...
                'Override for %s: session not found.', o.session_id);
        continue
    end
    sessions.rest_start_s(idx) = o.rest_start_s;
    sessions.rest_end_s(idx)   = o.rest_end_s;
    sessions.brady_end_s(idx)  = sessions.brady_start_s(idx) + ...
                                 (o.rest_end_s - o.rest_start_s);
    fprintf('Applied timing override for %s.\n', o.session_id);
end
end
