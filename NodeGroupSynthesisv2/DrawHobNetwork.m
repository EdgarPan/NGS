function DrawHobNetwork( N, GroupPairs, inCommon, varargin )
%DrawHobNetwork Draws in a circle a network system interconnected via HOB
%switches.
%   Author: Edgar Pan (edgar.pan@mail.mcgill.ca)
    
    %%
    %CONSTANTS
    Radius_Outer = 10;
    
    %%
    %Graph Parameters
    params = struct();
    for var = 1:2:length(varargin)-1
        params.(varargin{var}) = varargin{var+1};
    end
    
    if isempty(inCommon)
        Common = zeros(N);
    else
        Common = inCommon;
    end
    
    %%
    %Reads the Numbers of Nodes present and draws out their coordinates
    
    V = 2*pi/N*(0:N-1);
    XY_N = Radius_Outer*[cos(V); sin(V)]';
    
    %Analyzes the Group Pairs data.
    sizeGP = [size(GroupPairs,1), size(GroupPairs,2), size(GroupPairs,3)];
    U_init = 2*pi/sizeGP(3)*(0:sizeGP(3)-1);
    
    %Breaks alignment of nodes between Servers and HOBs
    divisor = 1;
    limit = 100;
    U_shift = U_init;
    while any(ismember(U_shift,V)) && divisor < limit
        U_shift = U_init + pi/divisor;
        divisor = divisor + 1;
    end
    U = U_shift;
    
    XY_H = Radius_Outer*1/2*[cos(U); sin(U)]';
    
    %Unifies the coordinate lists of Servers and HOBs
    W = cat(2,V,U); %list of angles
    XY = cat(1,XY_N,XY_H); %list of XY coordinates
    
%     disp(W)
    
    %%
    %Generates the Matrix Data
    A = zeros(N+sizeGP(3));
        %The first N nodes represents the Server Nodes
        %The additional sizeGP(3) nodes represents the HOB blocks.
    A(1:N,1:N) = eye(N);
        %Marks the Servers as Self Connecting.
        %This is just a notation in order to ID and distinguish Servers
        %from HOBs
    for i = 1:sizeGP(3)
        for r = 1:sizeGP(1)
            A(N+i,GroupPairs(r,1,i)) = A(N+i,GroupPairs(r,1,i)) + 1;
            A(GroupPairs(r,2,i),N+i) = A(GroupPairs(r,2,i),N+i) + 1;
        end
    end
    
    %%
    %Parsing the Matrix Data
    
    %Self-connecting edges.
    Serv = diag(diag(A));
    HOBs = diag(~diag(A));
    
    %Stores HOBs only links. Remove the self-connection.
    hA = A - diag(diag(A));
        
    %Stores the Adjacency Matrices for "left" and "right" side of HOB for
    %infrastructure purposes. Not really used. Potential for future
    %expansion.
    HOB_In = tril(hA,-1);
    HOB_Out = triu(hA,1);
    
    %Permanent Connections
    %Creates a larger Adjacency matrix and inserts the Common Links in.
    Perm = zeros(N+sizeGP(3));
    Perm(1:N,1:N) = Common;
    
    %Compile the full Adjacency matrix between the Server nodes and the
    %HOB nodes.
    Full = hA + Perm;
    
    %%
    %Splitting the thicker connections into separate matrices
    hiBWs = hA + hA' > 1;
    
    
    %%
    %Convert to Plot form
    [hiBWX,hiBWY] = makeXY(hiBWs,XY);
    [ServX,ServY] = makeXY(Serv,XY);
    [HOBsX,HOBsY] = makeXY(HOBs,XY);
    [PermX,PermY] = makeXY(tril(Perm,0),XY); %Permanent Connection coord
    [HOBIX,HOBIY] = makeXY(HOB_In,XY);
    [HOBOX,HOBOY] = makeXY(HOB_Out,XY);
    
    
    %%
    %Initialization of the figures
    figure
    hold on
    
    %%
    %With the Servers and HOBs marked, now it's just a matter of drawing
    %the lines representing the connections.
    %Note: The earlier line is plotted, the lower in layer it is.
    
    plot(PermX,PermY,'-','Color',[0.8 0.8 0.8],params)
    
    plot(hiBWX,hiBWY,'-','Color',[0.75 0.75 0.75],'Linewidth',2.5,params)
    
%     plot(HOBIX,HOBIY,'-','Color',[0.9 0.5 0.7],params)
%     plot(HOBOX,HOBOY,'-','Color',[0.4 0.8 0.8],params)
    plot(HOBIX,HOBIY,'-','Color',[0.4 0.4 0.4],params)
    plot(HOBOX,HOBOY,'-','Color',[0.4 0.4 0.4],params)
%     plot(HOBIX,HOBIY,'-','Color','K',params)
%     plot(HOBOX,HOBOY,'-','Color','K',params)
    
    %%
    %With the Coordinates set, now it's a matter of marking them on a map.
    plot(ServX,ServY,'o','Color',[.3 0 0],params)
    plot(HOBsX,HOBsY,'s','Color',[.3 0 0],params)
    
        
    %%
    %Labeling
    for G = 1:N
     text(XY_N(G,1),XY_N(G,2),['  S' num2str(G)],'Color','G','FontSize',12,'FontWeight','b')
    end
    for G = 1:sizeGP(3)
     text(XY_H(G,1),XY_H(G,2),['  H' num2str(G)],'Color','C','FontSize',10,'FontWeight','b')
    end  
    hold off
    
    %%
    function [x,y] = makeXY(A,xy)
        if any(A(:))
            [J,I] = find(A');
            m = length(I);
            xmat = [xy(I,1) xy(J,1) NaN(m,1)]';
            ymat = [xy(I,2) xy(J,2) NaN(m,1)]';
            x = xmat(:);
            y = ymat(:);
        else
            x = NaN;
            y = NaN;
        end
    end
end

