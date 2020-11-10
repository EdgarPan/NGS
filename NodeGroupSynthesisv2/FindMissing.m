function [ Missing ] = FindMissing( Nec, SelectedGroups )
%FindMissing Finds any Links not provided by the so-far selected Groups.
%   Author: Edgar Pan, McGill University. edgar.pan@mail.mcgill.ca
    
    %%
    %Early catch for Empty SelectedGroup
    if isempty(SelectedGroups) | ~any(SelectedGroups)
        Missing = Nec;
        return;
    end
    
    %%
    %Extracts essential data from Groups
    Links = GetGroupLinks(SelectedGroups);
    
    %%
    %The actual list comparison
    Missing = setdiff(Nec,Links,'rows');
    
    if isempty(Missing)
        Missing = []; %turns any empty row matrix into simple empty value.
    end
    
end

