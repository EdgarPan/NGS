% Test Script for Node Group Synthesis Algorithm
% Edgar Pan

%%
%Settings - ONLY CHANGE VALUES HERE

%Topology Data
H4D = GenHND(4);
T2D = GENTor(4,4);

M(:,:,1) = H4D;
M(:,:,2) = T2D;

%ChainPairs Setting
radix = 2; %Be aware that increasing this increases runtime exponentially
filters = [1 1 1]; %Not recommended to deactivate in higher radix

%Selection Process
ForceTolerance = 0;
tolerance = 0;

%Drawing Process
DrawGraphs = 1;
DrawCommon = 1;
ActiveTopology = 0;
HOBLabel = 1;

%Run Profiler
RunProfiler = 1;

%%
%Start Timer
if RunProfiler
    profile on
end
tic

%%
%Generates Connectivity (Link Delta) List

[dL,Nec,Common] = GenConnList(M);

%%
%ChainPairs
if radix > 0
    [CL,filt_met] = ChainPairs2(dL, radix, filters);
else
    [CL2,filt_met2] = ChainPairs2(dL, 2, filters);
    [CL4,filt_met4] = ChainPairs2(dL, 4, filters);
    [CL6,filt_met6] = ChainPairs2(dL, 6, filters);
    [CL8,filt_met8] = ChainPairs2(dL, 8, filters);
    [CL10,filt_met10] = ChainPairs2(dL, 10, filters);
    [CL12,filt_met12] = ChainPairs2(dL, 12, filters);
    [CL16,filt_met16] = ChainPairs2(dL, 16, filters);
end

%%
%Selection Process
if ForceTolerance
    tol = tolerance;
else
    tol = [];
end
if radix > 0
    [Selected,SelectedIndex] = SelectionProcess(CL,Nec,tol);
else
    [Selected2,SelectedIndex2] = SelectionProcess(CL2,Nec,tol);
    [Selected4,SelectedIndex4] = SelectionProcess(CL4,Nec,tol);
    [Selected6,SelectedIndex6] = SelectionProcess(CL6,Nec,tol);
    [Selected8,SelectedIndex8] = SelectionProcess(CL8,Nec,tol);
    [Selected10,SelectedIndex10] = SelectionProcess(CL10,Nec,tol);
    [Selected12,SelectedIndex12] = SelectionProcess(CL12,Nec,tol);
end

    
%%
%Find Missing Links
if radix > 0
    Missing = FindMissing(Nec,Selected);
    
    if ~isempty(Missing)
    %     CL = FillMissing(CL,Missing);
        disp('Warning: Not all Necessary Links have been completed.')
        disp('Recommend not forcing the tolerance.')
    end
end


%%
%Drawing Process
if DrawGraphs && radix > 0
    GraphOrder = size(M,1);
    if DrawCommon
        DrawHobSystem(GraphOrder,Selected,ActiveTopology,HOBLabel,Common)
    else
        DrawHobSystem(GraphOrder,Selected,ActiveTopology,HOBLabel)
    end
end

%%
%Measure Elapsed Time
ElapsedTime = toc;
if RunProfiler
    p = profile('info');
    profile viewer
end
