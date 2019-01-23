function commonElectrodes = findCommonElectrodes( fileManagerObj )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

electrodes = fileManagerObj.processedMap.electrode(...
    cellfun('length', fileManagerObj.processedMap.fileIndex) == fileManagerObj.nFiles);
index = mod(find(fileManagerObj.processedMap.electrode == electrodes'), ...
    length(fileManagerObj.processedMap.electrode));
index(index == 0) = length(fileManagerObj.processedMap.electrode);

xpos = fileManagerObj.processedMap.xpos(index);
ypos = fileManagerObj.processedMap.ypos(index);

commonElectrodes.electrodes = electrodes;
commonElectrodes.xpos = xpos;
commonElectrodes.ypos = ypos;
end

