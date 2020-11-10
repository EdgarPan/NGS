function [ NC, Nec, Common ] = GenConnList( M )
%GenConnList Creates list of switching connections between topologies.
%   Author: Edgar Pan (edgar.pan@mail.mcgill.ca)
%     The program scans through the adjacency matrices of the various
%     network configurations. The adjacency matrices are listed as a single
%     3D matrix, with each pages representing a specific configuration.
%     The program is capable of handling more than two configurations,
%     however, that is not recommended, since it has not been fully tested
%     nor explored (i.e. useful output format?)
%     
%   Input:
%       M - 'Adjacency Matrices' describing the topologies.
% 			3 Dimensional Array. [Rows, Columns, Topology]
% 				Every layer of array indicates a new topology
% 				Square matrix
% 				Mn: Number of Matrices (minimum 2)
% 	Output:
% 		NC - "Node Connection" (Note: Old term for Delta Link)
% 			1 + Mn columns, ? rows
% 				[SrcNod (Column/Row), Topo1Node, Topo2Node, … TopoMnNode]
%       Nec - "Necessary Connections"
%           Lists all node connections necessary to fully describe all
%           topologies
%       Common - "Common Links"
%           List of all Common links filtered out due to being irrelevant
%           to the process.
    %%
    %Basic dimension data
    sizeM = size(M);
    
    %%
    %Ensures there are multiple topologies entered.
    if sizeM(3)<2
        NC = 0;
        Nec = [];
        Common = M;
        disp('No changing connection required for a single topology')
        return
    end
    
    %%
    %Common Link Filtering Process
    
    Common = all(M,3);
    
    %Allocating Switching Link space
    dM = zeros(sizeM);
    
    %Filters out all common links from individual layers
    for k = 1:sizeM(3)
        dM(:,:,k) = xor(M(:,:,k),Common);
    end
    

    %%
    %Finding maximum radix of every columns
    %By first going through each topologies and finding how many links
    %each columns have. Then comparing every column's value and
    %then picking the highest one of all of them.
    max_radix = max(sum(dM),[],3);
    
    %Preallocating NC space
    NC = zeros(sum(max_radix.^sizeM(3)),1+sizeM(3));
    %row = highest radix to the power of the number of topologies
    %column = number of topologies + 1 to indicate source
    
    %The reasoning behind squaring the maximum radix is to have room to
    %place 0's in order to represent Loose/Ghost Links.
    
    for j = 1:sizeM(2)
        %%
        %Version 2 (variable topology compatibility)
        %Allocates cell space for the connection data
        xCell = cell(1,sizeM(3));
        
        for k = 1:sizeM(3)
            y = find(dM(:,j,k));
            xCell{k} = y;
        end
        z = setprodcell(xCell);
        
        %%
        %Compilation process. Puts the returned cross products into a
        %single list.
        sizeZ = size(z);
        z = cat(2,j*ones(sizeZ(1),1),z); %Creates a column for source idx
        shift = sum(max_radix(1:(j-1)).^sizeM(3));
        NC(1 + shift : sizeZ(1) + shift,:) = z;
    end
    
    %%
    %Section for Listing out all Necessary Connections
    dM_flat = any(dM,3);
    [a,b] = find(dM_flat);
    Nec = [a,b];
    Nec = Nec(a<b,:);
end