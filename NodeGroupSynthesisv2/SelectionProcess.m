function [FinalSelection, SelectedIndex] = SelectionProcess(CL, Nec, ForceTol)
%SelectionProcess Selects Node Groups based on their similarity
%   INPUT
%       CL - Chain Lists from which data will be extracted.
%       Nec - List of Necessary Connections
%       ForceTol - OPTIONAL A setting to force a certain tolerance setting.
%       Faster, but may not give complete solution.
%   OUTPUT
%       FinalSelection - List of the GPs selected
%       SelectedIndex - Index of the selected GPs in the CL list.
    
    if nargin < 3
        ForceTol = [];
    end
    
    %Get Group Relations
    [GR, RelData] = GetGroupRelation(CL{1});
    
    %Get Potential Tolerance Levels
    tolLvls = unique([0;GR{1}(:)]);
    
    %Start Acquiring Indices Selection based on tolerance
    if ~isempty(ForceTol)
        if ForceTol < 0
            %lower cap
            tolerance = 0;
        elseif ForceTol > length(tolLvls) - 2
            %upper cap
            tolerance = length(tolLvls) - 2; 
            % -2 to prevent self-connection
        else
            tolerance = ForceTol;
        end
        
        SelectedIndex = GroupRelationSelection(GR{1},tolerance);
        FinalSelection = CL{1}(:,:,SelectedIndex);
        if ~isempty(FindMissing(Nec,FinalSelection))
            disp('SelectionProcess.m Warning: ')
            disp('Forced Tolerance Selection yielded incomplete solution.')
        end
    else
        for tolerance = 0:length(tolLvls)-2
            SelectedIndex = GroupRelationSelection(GR{1},tolerance);
            Selected = CL{1}(:,:,SelectedIndex);
            
            stillMissing = FindMissing(Nec,Selected);
            
            if isempty(stillMissing)
                break;
            elseif tolerance == 0
                disp('SelectionProcess.m: Zero tolerance failed.')
            end
        end
        
        if ~isempty(stillMissing)
            %Extracting Link Data
            Links = RelData{1,1};
            RelLength = length(GR);
            for g = 2:RelLength
                Links(:,:,g) = RelData{g,g};
            end
            
            while ~isempty(stillMissing)
                %Preallocate contribution count memory,
                %clear out NewIndex selection in case of new iteration.
                contribution = zeros(RelLength,1);
                NewIndex = [];
                
                %Scans through for number of potential link contributions
                %in each GroupPairs.
                for c = 1:RelLength
                    intersection = intersect(stillMissing,Links(:,:,c),'rows');
                    contribution(c) = size(intersection,1);
                    if contribution(c) == size(stillMissing,1)
                        %If a GroupPair has all links missing, just pick
                        %this quick.
                        NewIndex = c;
                        break;
                    end
                end
                if isempty(NewIndex)
                    %If no single GroupPair has all missing links, then
                    %pick the one that contributes the most, then ready for
                    %new iteration.
                    NewIndex = find(contribution == max(contribution));
                end
                NewSelectedIndex = [SelectedIndex NewIndex];
                
                %Updates
                Selected = CL{1}(:,:,NewSelectedIndex);
                stillMissing = FindMissing(Nec,Selected);
            end
            SelectedIndex = NewSelectedIndex;
        end
        FinalSelection = Selected;
    end
    
    
end