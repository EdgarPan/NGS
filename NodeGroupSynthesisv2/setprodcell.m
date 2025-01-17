function C = setprodcell(X)
% SETMATPROD product of multiple columns of a matrix.
%
%   This version of the code setprod takes a Cell array directly.
%
%   For X = {A, B, C}
%   C = setprodcell(X) returns the cartesian product of the sets 
%   A,B,C, etc, where A,B,C, are numeric or character arrays.  
%
%   Example: A = [-1 -3 -5];   B = [10 11];   C = [0 1];
% 
%   X = SETPROD(A,B,C)
%   X =
% 
%     -5    10     0
%     -3    10     0
%     -1    10     0
%     -5    11     0
%     -3    11     0
%     -1    11     0
%     -5    10     1
%     -3    10     1
%     -1    10     1
%     -5    11     1
%     -3    11     1
%     -1    11     1

% Mukhtar Ullah
% mukhtar.ullah@informatic.uni-rostock.de
% September 20, 2004

% Adapted into Cell version by Edgar Pan
% edgar.pan@mail.mcgill.ca
% January 18, 2019

args = X;

if any([cellfun('isclass',args,'cell') cellfun('isclass',args,'struct')])
    error(' SETPROD only supports numeric/character arrays ')
end

% n = nargin;
n = length(args);

[F{1:n}] = ndgrid(args{:});

for i=n:-1:1
    G(:,i) = F{i}(:);
end

C = unique(G , 'rows');