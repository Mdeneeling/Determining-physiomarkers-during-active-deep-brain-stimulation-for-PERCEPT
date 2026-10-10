function base = extract_base_name(names, pattern)
%EXTRACT_BASE_NAME Extract the part of each file name matching a regex.
%
%   base = EXTRACT_BASE_NAME(names, pattern) returns a string array with the
%   first match of pattern in each name, or <missing> where there is none.

base = string(regexp(cellstr(names), pattern, 'match', 'once'));
base = base(:);
base(base == "") = missing;
end
