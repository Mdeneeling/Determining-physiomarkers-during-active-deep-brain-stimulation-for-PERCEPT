function files = list_stream_files(stream_dir, fcfg)
%LIST_STREAM_FILES List the stream .mat files selected for analysis.
%
%   files = LIST_STREAM_FILES(stream_dir, fcfg) returns a table with the
%   columns stream_file, stream_path and base_name for every .mat file in
%   stream_dir whose name contains all of fcfg.must_contain and none of
%   fcfg.exclude, and whose name matches fcfg.base_name_regex.

listing = dir(fullfile(stream_dir, '*.mat'));
if isempty(listing)
    error('list_stream_files:noFiles', 'No .mat files found in %s', stream_dir);
end
names = string({listing.name})';

keep = true(size(names));
for p = fcfg.must_contain
    keep = keep & contains(names, p{1});
end
for p = fcfg.exclude
    keep = keep & ~contains(names, p{1});
end
names = names(keep);

files = table();
files.stream_file = names;
files.stream_path = fullfile(string(stream_dir), names);
files.base_name   = extract_base_name(names, fcfg.base_name_regex);
files = files(~ismissing(files.base_name), :);
end
