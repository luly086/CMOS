function electrodeSelection( fileManagerObj, map, selectedElectrodes,  varargin )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

electrodes = selectedElectrodes.electrodes;

mxw.plot.activityMap(fileManagerObj, map, varargin{:});
hold
plot(fileManagerObj.processedMap.xpos(electrodes), fileManagerObj.processedMap.ypos(electrodes),'ro');
end