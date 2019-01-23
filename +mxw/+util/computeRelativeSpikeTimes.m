function [ values ] = computeRelativeSpikeTimes( fileManagerObj, varargin )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

p = inputParser;

p.addParameter('file', [])

p.parse(varargin{:});
args = p.Results;

if fileManagerObj.nFiles > 1
    if isempty(args.file)
        error('Please specify the file to use, or use a fileManager object containing only one file')
    else
        spikeTimes = double(fileManagerObj.rawMap(args.file).spikes.frameno) / double(fileManagerObj.fileObj(args.file).samplingFreq);
        
        if ischar(fileManagerObj.fileObj(args.file).firstFrameNum)
            firstFrameTime = min(spikeTimes);
        else
            firstFrameTime = double(fileManagerObj.fileObj(args.file).firstFrameNum) / double(fileManagerObj.fileObj(args.file).samplingFreq);
        end
        
        relativeSpikeTimes = spikeTimes - firstFrameTime;
        channel = fileManagerObj.rawMap(args.file).spikes.channel;
    end
else
    spikeTimes = double(fileManagerObj.rawMap.spikes.frameno) / double(fileManagerObj.fileObj.samplingFreq);
    
    if ischar(fileManagerObj.fileObj.firstFrameNum)
        firstFrameTime = min(spikeTimes);
    else
        firstFrameTime = double(fileManagerObj.fileObj.firstFrameNum) / double(fileManagerObj.fileObj.samplingFreq);
    end
    
    relativeSpikeTimes = spikeTimes - firstFrameTime;
    channel = fileManagerObj.rawMap.spikes.channel;
end

values.time = relativeSpikeTimes;
values.channel = channel;
end