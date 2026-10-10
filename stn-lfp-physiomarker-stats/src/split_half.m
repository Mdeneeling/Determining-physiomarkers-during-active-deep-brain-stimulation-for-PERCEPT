function [A, B] = split_half(X)
%SPLIT_HALF Randomly split the rows of X into two disjoint halves.
%
%   [A, B] = SPLIT_HALF(X) returns floor(n/2) randomly chosen rows of X in
%   A and the remaining rows in B. Set the seed with RNG for reproducibility.

n = size(X, 1);
p = randperm(n);
n_a = floor(n / 2);
A = X(sort(p(1:n_a)), :);
B = X(sort(p(n_a + 1:end)), :);
end
