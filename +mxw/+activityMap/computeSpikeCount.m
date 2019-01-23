function [ values ] = computeSpikeCount( fileManagerObj )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

% values = cellfun('length', fileManagerObj.processedMap.spikes.amplitude);

nFiles = fileManagerObj.nFiles;
values = zeros(length(fileManagerObj.processedMap.electrode), 1);

for iFile = 1:nFiles
    values = values + cellfun('length', fileManagerObj.extractedSpikes(iFile).amplitude);
end
end

