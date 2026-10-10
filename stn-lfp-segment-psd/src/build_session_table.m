function sessions = build_session_table(cfg, files)
%BUILD_SESSION_TABLE Link session timings to their stream files.
%
%   sessions = BUILD_SESSION_TABLE(cfg, files) reads the timing and matching
%   spreadsheets, joins them on session ID, and joins the result with the
%   stream files (from LIST_STREAM_FILES) on the file base name. Sessions
%   without a stream file or with missing timings are dropped.

timings  = read_task_timings(cfg.paths.timing_file, cfg.timing_cols);
matching = read_session_matching(cfg.paths.matching_file, cfg.matching_cols, ...
                                 cfg.files.matching_rename);

sessions = innerjoin(timings, matching, 'Keys', 'session_id');
sessions.base_name = extract_base_name(sessions.matched_file, cfg.files.base_name_regex);
sessions = sessions(~ismissing(sessions.base_name), :);

sessions = innerjoin(sessions, files, 'Keys', 'base_name');

timing_vars = {'rest_start_s', 'rest_end_s', 'brady_start_s', 'brady_end_s'};
complete = all(~ismissing(sessions(:, timing_vars)), 2);
if any(~complete)
    fprintf('Dropping %d session(s) with missing timings: %s\n', sum(~complete), ...
            strjoin(sessions.session_id(~complete), ', '));
end
sessions = sessions(complete, :);
end


function timings = read_task_timings(timing_file, cols)
%READ_TASK_TIMINGS Read task timings as seconds from the LFP recording start.
raw = readtable(timing_file);

lfp_start   = to_datetime(raw{:, cols.lfp_start});
rest_start  = to_datetime(raw{:, cols.rest_start});
rest_end    = to_datetime(raw{:, cols.rest_end});
brady_start = to_datetime(raw{:, cols.brady_start});

timings = table();
timings.session_id    = string(raw{:, cols.session_id});
timings.rest_start_s  = seconds(rest_start  - lfp_start);
timings.rest_end_s    = seconds(rest_end    - lfp_start);
timings.brady_start_s = seconds(brady_start - lfp_start);
% The bradykinesia segment has the same duration as the rest segment.
timings.brady_end_s   = timings.brady_start_s + ...
                        (timings.rest_end_s - timings.rest_start_s);
end


function matching = read_session_matching(matching_file, cols, rename)
%READ_SESSION_MATCHING Read the stream-file-to-session matching sheet.
raw = readtable(matching_file);
matching = table();
matching.session_id   = string(raw{:, cols.session_id});
matching.matched_file = strrep(string(raw{:, cols.file_name}), rename{1}, rename{2});
end


function t = to_datetime(x)
%TO_DATETIME Convert an Excel time column to datetime, whatever readtable made of it.
if isdatetime(x)
    t = x;
elseif isduration(x)
    t = datetime(2000, 1, 1) + x;
else
    t = datetime(x, 'ConvertFrom', 'excel');
end
end
