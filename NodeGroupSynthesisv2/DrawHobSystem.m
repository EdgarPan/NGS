function DrawHobSystem (N, Selected, ActiveTopology, HOBLabel, Common)
    if nargin < 5
        DrawHobNetwork(N,Selected,[])
    else
        DrawHobNetwork(N,Selected,Common)
    end
    for i = 1:size(Selected,3)
        figure('Position',[270 400 250 250])
        hold on
        axis([-5 5 -5 5])
        DrawHobSwitch(Selected(:,:,i),0,ActiveTopology)
        if HOBLabel
            title(['H' num2str(i)])
        end
        hold off
    end
end