function [ Links ] = GetGroupLinks( GP )
%GetGroupLinks Extracts the information on what Links are provided by a set
%of Group Pairs
%   Output
%       Links - List of All Links provided by the Group Pairs inputed
%   Input
%       GP - Group Pairs
    %%
    %Extracts essential data from Groups
    [radix, topoLength, HOBs] = size(GP);
    
    List = permute(GP,[1 3 2]);
    List = reshape(List,[],topoLength,1);
    
    Links = [];
    for i = 2:topoLength
        %Creates a list of all links established by kept GPs
        Links = cat(1,Links,List(:,[1 i]));
    end
    %Re-orders links such that smaller number comes first.
    %i.e. [2 1] becomes [1 2]
    Links(Links(:,1)>Links(:,2),:) = fliplr(Links(Links(:,1)>Links(:,2),:));
    
    %%
    %Verifies the values of Links
    uLinks = unique(Links,'rows','stable');
    
    if (size(uLinks,1)~= radix*(topoLength-1)*HOBs)
        disp('GetGroupLinks WARNING: Link Overlap has occurred')
        disp('Recommend verify Group Pair List.')
    end
end

