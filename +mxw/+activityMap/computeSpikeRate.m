function [ values ] = computeSpikeRate( fileManagerObj )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

% values = cellfun('length', fileManagerObj.processedMap.spikes.amplitude);

nFiles = fileManagerObj.nFiles;
values = zeros(length(fileManagerObj.processedMap.electrode), 1);

for iFile = 1:nFiles
    
    if fileManagerObj.fileObj(iFile).dataLenSamples>0
    values = values + ( (cellfun('length', fileManagerObj.extractedSpikes(iFile).amplitude))/(fileManagerObj.fileObj(iFile).dataLenSamples/fileManagerObj.fileObj(iFile).samplingFreq) );
    else
        fileManagerObj.fileObj(iFile).dataLenSamples = double(fileManagerObj.fileObj(iFile).spikes.frameno(end)-fileManagerObj.fileObj(iFile).spikes.frameno(1));
        values = values + ( (cellfun('length', fileManagerObj.extractedSpikes(iFile).amplitude))/(fileManagerObj.fileObj(iFile).dataLenSamples/fileManagerObj.fileObj(iFile).samplingFreq) );
    end
end
end

