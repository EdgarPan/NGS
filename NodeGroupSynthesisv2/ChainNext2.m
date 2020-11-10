function [ CL, filter_meta_update ] = ChainNext2( dL, radix, List, Chain, ...
    filter, filter_meta )
%ChainPairs Synthesizes list of potential node groups by chaining
%connection pairs. At present only handles 2 topology systems.
%   Author: Edgar Pan (edgar.pan@mail.mcgill.ca)
%   Input:
%       NC - "Node Connection" list, most likely generated by GenConnList.m
%               Format: [SourceNode Topology1Node Topology2Node ...]
%       radix - determines the number of ports on a one side of a
%               crosspoint switch.
%       List - The Completed Chain List that's been fed in.
%       Chain - The Node Group Template Fed in. i.e. Current Chain.
%       filter - Settings input for filter activation
%       filter_meta - Metadata for filters.
%   Output:
%       CL - "Chains List" A returned list of the node groups
    
    %Default Safety Response
    CL = List;
    filter_meta_update=filter_meta;
    
    %Check Tail end of current Chain
    Tail = Chain(end);
    Head = Chain(1,2);
    
    %Generate Potential Links List
    Link_Index = dL(:,2)==Tail; %Creates logic array
    Link_List = dL(Link_Index,:); %Which then this scans faster
    Link_Length = size(Link_List(:,1),1);
    
    %The amount of topologies system will switch between. Should be 2.
    Modes = size(Chain,2)-1;
    
    %Preallocation
    %Allocating Reference to store all Mismatched Combinations
    Mismatch = [];
    
    %Variable for checking any occurrence of a Complete List
    Disable_Mismatch = false;
    
    %List Data
    sizeList = size(List{1});
    
    %Filter Settings
    OverlapFil = filter(2);
    EquivFil = filter(3);
    
    %Catching Minimum Chains, puts them in a cell array for variable sizes
    %Put in this early stage such that it will not account for "Completed"
    %Chains
    if Head == Tail
        %Number of Minimum GP cases found
        minCases = length(CL{2});
        CL{2}{minCases+1} = Chain;
    end
    
    %Cycle through Link List
    for i = 1:Link_Length
        
        skip = 0;
        
        %Checks for Overlap Filter
        if OverlapFil
            for m = 2:Modes+1
                if any(ismember(Chain(:,[1 m]),Link_List(i,[1 m]),'rows'))
                    %Assumption: A specific link will only happen in
                    %specific topology mode.
                    skip = 1;
                    break;
                elseif any(ismember(Chain(:,[1 m]),...
                        fliplr(Link_List(i,[1 m])),'rows'))
                    %Checks also for cases where a backwards link also
                    %overlaps
                    skip = 1;
                    break;
                end
            end
            if skip
                continue;
            end
        end
        
        
        %Next Link Selected and Inserted
        %Updates template with the Chain's current Progress
        ChainProgress = cat(1,Chain,Link_List(i,:));

        %Checks the Chain Length
        Chain_Length = size(ChainProgress,1);
        
        %Finds the minimum radix for the minimum Chain cases
        minChainLength = 0;
        if ~isempty(CL{2})
            minChainLength = min(cellfun('size',CL{2},1));
        end
        
        if EquivFil && Chain_Length > radix - minChainLength && ~isempty(List{1})
            %In-process equivalence filter framework (doesn't do anything)
            
            %Halfway through the chain, if we notice that it's basically a
            %pre-existing chain, but backwards, skip.
            
            %The process is relatively straightforward. Just check the
            %first two columns (how to handle larger cases then?).
            %Checking only for each Links (i.e. 1 3; 2 4). Then just check
            %whether similar patterns occur.
            %The real challenge is doing that for all entries in the list
            %without needing to iterate through it every time.
            
            %That was the intent, at least. It had not worked as intended.
            %As such, the "continue" line is never reached, but to avoid
            %bugs, this section was left in.
            
            if length(sizeList)<3 || sizeList(3) < 2
                equiv = [ismember(ChainProgress(:,[1 2]),...
                    List{1}(:,[1 2]),'rows');
                    ismember(Tail,List{1}(:,2))];
            else
                %currently brute force solution
                equiv = zeros(2,sizeList(3));
                for eqIdx = 1:sizeList(3)
%                     ChainProgress(:,[1 2])
%                     List{1}(:,[1 2],eqIdx)
%                     equiv(:,eqIdx) = [ismember(ChainProgress(:,[1 2]),...
%                         List{1}(:,[1 2],eqIdx),'rows');
%                         ismember(Tail,List{1}(:,2))];
                end
            end
            
            if any(all(equiv))
                continue
            end
            
        end
        
        if Chain_Length < radix
            %Feeds the Chain template into the recursive system.
            [CL,filter_meta] = ChainNext2(dL,radix,CL,ChainProgress,filter,filter_meta);
        else
            %If we've reached or surpassed the limit of the radix
            if Link_List(i,3) == ChainProgress(1,2)
                %Case of Complete List, where the last Tail and the first
                %Head matches up
                CL{1} = cat(3,CL{1},ChainProgress);
                
                %Disables mismatched case because we know matched exists.
                Disable_Mismatch = true;
                Mismatch = [];
            elseif ~Disable_Mismatch
                Mismatch = cat(3,Mismatch,ChainProgress);
            end
        end
    end
end