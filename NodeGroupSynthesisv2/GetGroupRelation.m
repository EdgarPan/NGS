function [ Count, Data ] = GetGroupRelation( NodeGroups )
%GraphNodeGroup Takes a list of NodeGroups and Graph their relation to each
%other
%   Simply takes of list of Node Group Pairs (probably generated by
%   ChainPairs.m) and creates 2 relations matrices.
%   Input
%       NodeGroups - List of Node Group Pairs
%   Output
%       Count - Cell containing 
%           {1} - the intersection matrix (how alike two groups pairs are)
%           {2} - the difference matrix (how different two group pairs are)
%       Data - Cell containing
%           {1} - Cell matrix containing the actual intersecting links
%           {2} - Cell matrix containing the actual differing links
    %%
    %Initialization
    sizeNG = [size(NodeGroups,1), size(NodeGroups,2), size(NodeGroups,3)];
    LinkCount = sizeNG(1)*(sizeNG(2)-1);
    NGCount = sizeNG(3);
    
    %Preallocates Link Data Space
    Links = zeros(LinkCount, 2, NGCount);
    
    %Preallocates difference and intersection cell space
    Diff = cell(NGCount);
    Intersection = cell(NGCount);
    
    %%
    %Extract Link Data from Node Groups
    for g = 1:NGCount
        Links(:,:,g) = GetGroupLinks(NodeGroups(:,:,g));
    end
    
    %%
    %Create the Difference and Intersection Table
    for i = 1:NGCount
        for j = i:NGCount
            %Only compares upper triangle of matrix to save computation
            %time
            intersection = ...
                intersect(Links(:,:,i),Links(:,:,j),'rows');
            diff = ...
                setdiff(Links(:,:,i),Links(:,:,j),'rows');
            
            if size(diff,1) + size(intersection,1) ~= LinkCount
                disp('GetGroupRelation.m: Link Count Mismatch')
                disp([i j])
                disp(size(diff,1) + size(intersection,1))
            end
            
            if i == j
                Intersection{i,i} = Links(:,:,i);
            else
                Intersection{i,j} = intersection;
                Intersection{j,i} = intersection;
                Diff{i,j} = diff;
                Diff{j,i} = diff;
            end
            
        end
    end
    
    IntersectCount = cellfun('size',Intersection,1);
    DiffCount = cellfun('size',Diff,1);
    
    %%
    %Output compilation
    Count = cell(2,1);
    Count{1} = IntersectCount;
    Count{2} = DiffCount;
    
    Data = cell(2,1);
    Data{1} = Intersection;
    Data{2} = Diff;
end

