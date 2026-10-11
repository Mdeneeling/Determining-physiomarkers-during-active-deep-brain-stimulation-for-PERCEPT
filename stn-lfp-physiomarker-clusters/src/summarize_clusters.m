function S = summarize_clusters(T, idx, variables)
%SUMMARIZE_CLUSTERS Median and interquartile range per cluster and variable.
%
%   S = SUMMARIZE_CLUSTERS(T, idx, variables) returns a long table with one
%   row per cluster and variable: cluster, variable, n (non-missing),
%   median, q1, q3. Descriptive only; no tests between clusters.

clusters = unique(idx(:))';
rows = cell(0, 6);
for c = clusters
    in_c = idx == c;
    for v = variables
        x = T.(v{1})(in_c);
        x = x(~isnan(x));
        if isempty(x)
            q = [NaN NaN NaN];
        else
            q = quantile(x, [0.25 0.5 0.75]);
        end
        rows(end + 1, :) = {c, string(v{1}), numel(x), q(2), q(1), q(3)}; %#ok<AGROW>
    end
end
S = cell2table(rows, 'VariableNames', {'cluster', 'variable', 'n', 'median', 'q1', 'q3'});
end
