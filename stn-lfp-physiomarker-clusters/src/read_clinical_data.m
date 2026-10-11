function C = read_clinical_data(clinical_file, variables)
%READ_CLINICAL_DATA Read the per-hemisphere clinical table.
%
%   C = READ_CLINICAL_DATA(clinical_file, variables) reads a spreadsheet
%   (.xlsx, .csv) or a .mat file containing one table, with one row per
%   hemisphere and the columns Subject, Hemisphere (0 = left, 1 = right)
%   and the names in variables (cell array). Other columns are ignored.
%
%   Returns Subject as a lower-case string and all other columns as double;
%   categorical or text columns holding numbers (e.g. a categorical
%   Hemisphere of 0/1) are converted by their value, not their category index.

[~, ~, ext] = fileparts(clinical_file);
if strcmpi(ext, '.mat')
    S = load(clinical_file);
    names = fieldnames(S);
    is_table = false(size(names));
    for k = 1:numel(names)
        is_table(k) = istable(S.(names{k}));
    end
    if nnz(is_table) ~= 1
        error('read_clinical_data:mat', '%s must contain exactly one table.', clinical_file);
    end
    raw = S.(names{is_table});
else
    raw = readtable(clinical_file, 'VariableNamingRule', 'preserve');
end

needed = [{'Subject', 'Hemisphere'}, reshape(variables, 1, [])];
missing = setdiff(needed, raw.Properties.VariableNames, 'stable');
if ~isempty(missing)
    error('read_clinical_data:missingColumn', 'Column(s) not found in %s: %s', ...
          clinical_file, strjoin(missing, ', '));
end

C = table();
C.Subject = lower(strtrim(string(raw.Subject)));
for v = needed(2:end)
    x = raw.(v{1});
    if iscategorical(x) || iscell(x) || isstring(x)
        x = str2double(string(x));
    end
    C.(v{1}) = double(x);
end

if any(~ismember(C.Hemisphere, [0 1]))
    error('read_clinical_data:hemisphere', 'Hemisphere must be 0 (left) or 1 (right).');
end
end
