function [ Aj ] = GenHND( N )
%GENHND
%   Author: Edgar Pan (edgar.pan@mail.mcgill.ca)
%   Generates a Hypercube of N dimensions

%Base Adjacency
Q1 = [0 1 ; 1 0];

Aj = Q1;
if N >= 2
    for n=2:N
        Q = Aj;
        Aj=kron(Q,eye(2)) + kron(eye(2^(n-1)),Q1);
    end
end

end