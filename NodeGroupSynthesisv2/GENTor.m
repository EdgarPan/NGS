function [ T_Aj ] = GENTor( X, varargin )
%GENTor Generate a Torus Function
%   Given a set of dimensions, generates a Torus graph.
%   Does not work for any dimensions lower than 2.
%--------------------------
% Define the adjacency matrix of the n-D Torus.
%   Input length of each dimension separated by commas.
%   Example: GENTor(4,4,2)
%   
%   Additional options - Add specific tags after list of dimensions
%       'noloop' - Creates a mesh matrix with no wraparound
%       'sglloop' - Creates a torus matrix with only a maximum of single
%            link during wraparound.
%       'dblloop' - Default. Creates Torus matrix with maximum of double
%            loop. Only applicable for any dimension of length 2.
%   Example
%       GENTor(4,4,2,'noloop') - 4x4x2 Mesh with no looping
%       
%   
%   Written by Edgar Pan
%   Version 2.0.0
%   Created 2019-05-10

    %%
    %Parses the inputs
    if any([cellfun('isclass',varargin,'cell') cellfun('isclass',varargin,'struct')])
        error(' GENTor only supports numeric/character arrays ')
    end

    N = nargin; %Full n arg in

    %Finds where options arguments, if any, begins
    optIdx = cellfun(@ischar,varargin);

    if any(optIdx)
        optStart = find(optIdx,1);
        vars = varargin(1:optStart-1);
        opts = varargin(optStart:N-1);
        n = optStart; 
        %Number of numeric entries, including X. The index shift cancels.
    else
        vars = varargin;
        opts = [];
        n = N;
    end

    %Catches input errors, any vectors/matrices.
    if any([length(X)>1 cellfun(@(x) length(x)>1,vars)])
        error('GENTor: Please do not enter any matrices. Separate dimensions with commas.')
    end

    %Catches input errors, anything with 0-length dimension
    if (X < 1) || any(cellfun(@(x) x<1,vars))
        error ('GENTor: Please input dimensions for an existing graph.');
    end

    %%
    %Parses the options
    optLoop = -1;
    if ~isempty(opts)
        if any(cellfun(@(x) strcmpi(x,'noloop'),opts))
            optLoop = 0;
        elseif any(cellfun(@(x) strcmpi(x,'sglloop'),opts))
            optLoop = 1;
        elseif any(cellfun(@(x) strcmpi(x,'dblloop'),opts))
            optLoop = 2;
        end
    end

    %%
    %Start Compiling all the numbers in.

    T_Aj = GetTorusBasis(X,optLoop);
    for d = 2:n
        if vars{d-1} > 1
            Y = GetTorusBasis(vars{d-1},optLoop);
%             T_Aj = kronSum(T_Aj,Y);
			T_Aj = kronSum(Y,T_Aj); %Keeps original numbering orientation.
        else
            disp('GENTor: WARNING - Dimension of length 1 detected and ignored.')
        end
    end

    %%
    %Internal Functions
    function B = GetTorusBasis(y,optLoop)
        B = zeros(y);
        B(2:y+1:end) = 1;
        B(y+1:y+1:end) = 1;
        if nargin < 2
            optLoop = 2;
        end
        %Asks whether double looping allowed.
        if optLoop == 0
            %Does nothing
        elseif optLoop == 1
            B(y,1) = 1;
            B(1,y) = 1;
        else
            B(y,1) = B(y,1) + 1;
            B(1,y) = B(1,y) + 1;
        end
        
    end
    
    function KS = kronSum(A,B)
        if size(A,1) ~= size(A,2) || size(B,1) ~= size(B,2)
            error('GENTor - kronSum: Invalid Input. Must be square matrices')
        end
        KS = kron(A,eye(length(B))) + kron(eye(length(A)),B);
    end

end

