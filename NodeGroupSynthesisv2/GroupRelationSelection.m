function [ NodeGroupList, gGraph ] = GroupRelationSelection( GNGCount, tolerance )
%GroupRelationSelection Selects Node Groups based on their relationship
%   INPUT
%   GNGCount - Matrix of similarity relationships between NodeGroups in a
%   NodeGroupList.
%   tolerance - Tolerance level. 0 for no similarity. 1 for next minimum
%   similarity.
%   OUTPUT
%   NodeGroupList - Output of the index for the Node Groups
%   gGraph - Similarity graph as per the tolerance value.
    
    %Rather than having the user manually entering the exact similarity
    %values that are tolerated, system finds the key tolerance values and
    %user picks "first tolerance values" or so on.
    tolLvls = unique([0;GNGCount(:)]);
    
    if nargin < 2 || isempty(tolerance) || tolerance < 0
        tolerance = 0;
    elseif tolerance > length(tolLvls) - 2
        disp('GroupRelationSelection.m Warning: ')
        disp('Tolerance value exceeds levels available in system.')
        tolerance = length(tolLvls) - 2; %-2 to prevent self-connection
    end
    
    %First, convert the relationship data to graph format based on the
    %tolerance value. The default state is tolerance 0, meaning that for
    %ANY common links between the Node Groups, there is a link.
    gGraph = graph(GNGCount>tolLvls(tolerance+1));
    
    %Identifies isolated components (subgroup of nodes) in graph
    [bins,binsizes] = conncomp(gGraph,'OutputForm','cell');
    subList = cell(1,length(bins));
    
    for i=1:length(bins)
        %Extracts subgraph
        subgGraph = subgraph(gGraph,bins{i});
        gdist = distances(subgGraph);
        
        
        %List of Node Groups to use. Logic Array format.
        shortlist = false(1, length(gdist));
        priorlist = shortlist; %stores prior shortlist state before any changes

        %Selection of Initial Node Group
        potStartIdxList = find( sum(rem(gdist,2)==0)==max(sum(rem(gdist,2)==0)) );
%         potStartIdxList = find( sum(rem(gdist,2)==0)==min(sum(rem(gdist,2)==0)) );
        
        startIndex = potStartIdxList(ceil(rand*length(potStartIdxList)));
        %of the possible options, randomly selects one.
        
        shortlist(startIndex) = 1;

        unchanged = isequal(shortlist, priorlist);

        while ~unchanged

            priorlist = shortlist;
            %tdist: test gdist that will get further and further reduced
            %Resets the reduced gdist matrix
            tdist = -ones(length(gdist));

            %Creates list of potential Next Indices
                %The rem(gdist([shortlist,:),2)==0) part creates a matrix
                %where every row represents one of the prospective indices. We
                %find every index that is a multiple of 2 steps away.
                %The all is an "and" for every rows. the &~prospective removes
                %past indices from the potential Index list.
            ptnlIdx = rem(gdist(shortlist,:),2)==0;
            
            if size(ptnlIdx,1)>1
                ptnlIdx = all(ptnlIdx) & ~shortlist;
            else
                ptnlIdx = ptnlIdx & ~shortlist;
            end
            
            %Creates a reduced gdist matrix while maintaining size (and index)
            tdist(ptnlIdx,:) = gdist(ptnlIdx,:);
            tdist(:,ptnlIdx) = gdist(:,ptnlIdx);

            %Selection of Next Node Group
            if any(ptnlIdx) && max(sum(rem(tdist,2)==0))>0
%             if any(ptnlIdx) && min(sum(rem(tdist,2)==0))>0
                potNextIdx=ptnlIdx;
                potNextIdx(ptnlIdx) = sum(rem(tdist(ptnlIdx,ptnlIdx),2)==0)==...
                    max(sum(rem(tdist(ptnlIdx,ptnlIdx),2)==0));
                potNextIdxList = find(potNextIdx & ptnlIdx);
                if ~isempty(potNextIdxList)
                    nextIndex = potNextIdxList(ceil(rand*length(potNextIdxList)));

                    %Once selected, modifies the shortlist
                    shortlist(nextIndex) = 1;
                end
            end

            unchanged = isequal(shortlist, priorlist);
        end
        subList{i} = find(shortlist) + sum(binsizes(1:i-1));
    end
    %Finalizes the shortlist as output
    NodeGroupList = cell2mat(subList);
end

