function DrawHobSwitch( GroupPair, shift, topoSet )
%DrawHobSwitch Draws the internal configuration of the individual switches
%   Author: Edgar Pan (edgar.pan@mail.mcgill.ca)
    %%
    %Initialization
    sizeGP = size(GroupPair);
    radix = sizeGP(1);
    
    if nargin < 2 || isempty(shift)
        shift = [0 0];
        disp(topoSet)
    end
    %%
    %Drawing the Base Rectangle, representing the Physical Case.
    boxCorn = [-1.5 -2.5] + shift;
    boxSize = [3 5];
    rectangle('Position', [boxCorn boxSize])
    
    %%
    %Setting the Vertical Coordinates for the Ports
    portGap = boxSize(2)/(radix+1);
    portVert = boxCorn(2):portGap:(boxCorn(2)+boxSize(2)-portGap);
    portVert = flip(portVert(2:length(portVert)));
    
    portCoordL = [ones(radix,1)*boxCorn(1) portVert'];
    portCoordR = [ones(radix,1)*(boxCorn(1)+boxSize(1)) portVert'];
    
    %%
    %Draws out the ports and labels them.
    portSize = [min(portGap/6, 1) min(portGap/2,1)];
    portLabelL = GroupPair(:,1);
    portLabelR = GroupPair(:,2);
    %Left
    for L = 1:radix
        rectangle('Position', [portCoordL(L,1)-portSize(1) ...
            portCoordL(L,2)-portSize(2)/2 portSize])
        text(portCoordL(L,1)-portSize(1)-0.2,portCoordL(L,2),...
            ['S' num2str(portLabelL(L))],'Color','G',...
            'FontSize',12,'FontWeight','b','HorizontalAlignment','Right')
    end
    for R = 1:radix
        rectangle('Position', [portCoordR(R,1) ...
            portCoordR(R,2)-portSize(2)/2 portSize])
        text(portCoordR(R,1)+0.5,portCoordR(R,2),...
            ['S' num2str(portLabelR(R))],'Color','G',...
            'FontSize',12,'FontWeight','b')
    end
    
    %%
    %Goes through the GroupPair list and draws out each links
    RGB = [0 0 0];
    for j = 2:sizeGP(2)
        available = true(radix,1);
        if j == 2
            RGB = [0 0 1]; %Blue
        elseif j == 3
            RGB = [1 0 0]; %Red
        end
        if topoSet + 1 == j
            style = '-';
        else
            style = '--';
        end
        for i = 1:sizeGP(1)
            %Connecting GP(i,1) to GP(i,j)
            Source = portCoordL(i,:);
            DestPotentIndex = (portLabelR == GroupPair(i,j)) & available;
            selectedDest = find(DestPotentIndex,1);
            available(selectedDest) = 0;
            Destination = portCoordR(selectedDest,:);
            
            plot([Source(1) Destination(1)],...
                [Source(2) Destination(2)],style,'Color',RGB)
        end
    end
end

