function [ groups ] = electrodeGroups( fileManagerObj, radius )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

groups = {};
takenElectrodes = [];

xpos = fileManagerObj.processedMap.xpos;
ypos = fileManagerObj.processedMap.ypos;
electrode = fileManagerObj.processedMap.electrode;

figure;
hold on;

while ~isempty(electrode)

    [~, index] = sort(sqrt(xpos.^2 + ypos.^2));

    topPointX = xpos(index(1));
    topPointY = ypos(index(1));

    diffCloseElec = sqrt((topPointX - xpos).^2 + (topPointY - ypos).^2);
    
    closeElectrodes = diffCloseElec < radius;

    scatter(xpos(closeElectrodes), ypos(closeElectrodes), 'filled')

    groups{end+1} = double(electrode(closeElectrodes));
    takenElectrodes = [takenElectrodes ; electrode(closeElectrodes)];
    
    xpos(closeElectrodes) = [];
    ypos(closeElectrodes) = [];
    electrode(closeElectrodes) = [];
end

