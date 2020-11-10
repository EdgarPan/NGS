function [CLComp] = CreateCompGP(minChains,radix,filters)
%CreateCompGP Compiles Minimum Chains into composite GP blocks
%   Author: Edgar Pan (edgar.pan@mail.mcgill.ca)
%   Basically, this function checks every combination of minimal GPs and
%   records every resulting composite GP that fills up a switch of the
%   indicated radix.
%   Input:
%       minChains - Full list of minimal chains. Essentially GPs that were
%       complete before reaching the desired radix.
%       radix - The radix we want these GPs on.
%       filters - Default ON. Settings for filter. Function only uses the
%       Overlap filter which checks for any instance of redundant links in
%       the generated compGP.
%   Output:
%       CLComp - Chain List Composite
%           The compiled list of Composite Group Pairs.
%
%   ASSUMPTION: Minimal Chains creates can also compose higher order
%   minimum chains as well, hence only deal with Minimal (lowest radix).
%   Only keeps primes.
    
    %Filter Settings
    if nargin < 3
        OverlapFil = true;
    else
        OverlapFil = filters(2);
    end
    
    %Finds the list of sizes
    GPlengths = cellfun('size',minChains,1);
    

    %Finds the types of lengths in list
    LengthTypes = unique(GPlengths);
    
    keepTypes = true(1,length(LengthTypes));
    %Keeping only Prime Radices
    for L = 1:length(LengthTypes)-1
        if ~keepTypes(L)
            continue;
        end
        for J = L+1:length(LengthTypes)
            if keepTypes(J)
                f = factor(LengthTypes(J));
                if ismember(LengthTypes(L),f)
                    keepTypes(J) = false;
                end
            end
        end
        if ~any(keepTypes(L+1:end))
            break;
        end
        
        nextIdx = find(keepTypes(L+1:end),1) + L;
        if ~isempty(nextIdx)
            if nextIdx > length(LengthTypes)-1
                break;
            end
            L = nextIdx - 2;
        end
    end
    
    %Acquires Reduced List
    KeepIdx = ismember(GPlengths,LengthTypes(keepTypes));
    
    ReducedList = minChains(KeepIdx);
    RedGPLength = GPlengths(KeepIdx);
    
    %Gonna brute force the solution
    maxIdx = length(ReducedList);
    
    %Creates an array of binary numbers counting from 1 to however many
    %minimum Chains combos there are, representing the use of a particular
    %minChain on a switch block (HOB in context of creation) iteration.
    a = mat2cell([false(1,maxIdx);true(1,maxIdx)],2,ones(1,maxIdx));
    iteration = setprodcell(a);
    
    ptnlIte = size(iteration,1); %List of potential iterations
    keepIte = false(ptnlIte,1); %Pre-allocation of valid iteration space
    
    for i = 1:ptnlIte
        ite = iteration(i,:);
        iteLength = sum(RedGPLength(ite));
        if iteLength == radix
            keepIte(i) = true;
        else
            keepIte(i) = false;
        end
    end
    
    keptIte = iteration(keepIte,:);
    nkeptIte = length(keptIte);
    
    %Preallocating
    unfiltCLComp = cell(1,nkeptIte);
    for c = 1:nkeptIte
        CellBlocks = ReducedList(keptIte(c,:));
        CellBlocks = reshape(CellBlocks,[],1);
        unfiltCLComp{c} = cell2mat(CellBlocks);
    end
    
    if OverlapFil
        %number of unfiltered Composite Blocks
        nComp = length(unfiltCLComp);
        
        %number of topological configuration
        modes = size(minChains{1},2);
        overlapIdx = false(1,nComp);
        for f = 1:nComp
            for m = 2:modes
                ovlpcheck = unfiltCLComp{f}(:,[1 m]);
                
                %Finds indices where for proper IDing of Links, flip the
                %node designations
                flipIdx = ovlpcheck(:,1)>ovlpcheck(:,2);
                ovlpcheck(flipIdx,:) = fliplr(ovlpcheck(flipIdx,:));
                
                ovlptest = unique(ovlpcheck,'rows');
                if size(ovlptest,1) ~= radix
                    overlapIdx(f) = true;
                end
            end
        end
        CLComp = unfiltCLComp(~overlapIdx);
    else
        CLComp = unfiltCLComp;
    end
end

