function [ axonTraces, electrodeGroups, ts, w, s ] = computeAxonTraces( fileManagerObj, axonTrackElec, varargin )

p = inputParser;

p.addParameter('SpikeDetThreshold', 6);
p.addParameter('SecondsToLoadPerIteration', 20);
p.addParameter('TotalSecondsToLoad', 'full');
p.addParameter('MaxDistClustering', 20);
p.addParameter('PrePointsSpike', 20);
p.addParameter('PostPointsSpike', 30);

p.parse(varargin{:});
args = p.Results;

if ~(strcmp(args.TotalSecondsToLoad, 'full'))
    if args.SecondsToLoadPerIteration > args.TotalSecondsToLoad
        error('SecondsToLoadPerIteration has to be equal or less than TotalSecondsToLoad')
    end
end

nFiles = fileManagerObj.nFiles;
sampFreq = fileManagerObj.fileObj(1).samplingFreq;
secondsToLoadPerIteration = args.SecondsToLoadPerIteration;
temporalAxonTraces = cell(nFiles,1);

[~, ~, ~, electrodeGroups] = clusterXYpoints([axonTrackElec.xpos axonTrackElec.ypos], args.MaxDistClustering, 1);

for iFile = 1:nFiles
    disp(iFile)
    
    if strcmp(args.TotalSecondsToLoad, 'full')
        totalLengthSamples = fileManagerObj.fileObj(iFile).dataLenSamples;
    else
        totalLengthSamples = args.TotalSecondsToLoad * sampFreq;
    end
    
    chunkSize = 1:sampFreq*secondsToLoadPerIteration:totalLengthSamples;
    fullWaveforms = cell(size(electrodeGroups));
    waveformCount = zeros(size(electrodeGroups));
    
    timestamps{iFile} = cell(size(electrodeGroups));
    waveforms_ums{iFile} = cell(size(electrodeGroups));
    std_ums{iFile} = cell(size(electrodeGroups));
    
    for iChunk = 1:length(chunkSize)
        startPoint = chunkSize(iChunk);
        endPoint = min(sampFreq*secondsToLoadPerIteration, totalLengthSamples - startPoint + 1);
        
        [completeData, filesArray, electrodesArray] = fileManagerObj.extractBPFData(startPoint, endPoint, 'files', iFile);
        normCompleteData = bsxfun(@minus, completeData, round(mean(completeData)));
        
        for iElecGroup = 1:size(electrodeGroups,1)
            currentElectrodes = axonTrackElec.electrodes(electrodeGroups{iElecGroup})';
            
            index = mod(find(cell2mat(electrodesArray)' == currentElectrodes), length(cell2mat(electrodesArray)));
            index(index == 0) = length(cell2mat(electrodesArray));
            dataCommonElec = completeData(:,index);
            
            spikes = ss_default_params(sampFreq);
            spikes.params.thresh = args.SpikeDetThreshold;
            disp(std(dataCommonElec)*spikes.params.thresh);
            spikes = ss_detect({dataCommonElec}, spikes);

            
            detectedSpikes = round(spikes.spiketimes*sampFreq);
            detectedSpikes = sort(detectedSpikes);
            detectedSpikes(detectedSpikes < 150) = [];
            detectedSpikes(detectedSpikes > length(dataCommonElec)-200) = [];
            
            timestamps{iFile}{iElecGroup} = [timestamps{iFile}{iElecGroup} spikes.spiketimes+startPoint/20000];
            waveforms_ums{iFile}{iElecGroup} = [waveforms_ums{iFile}{iElecGroup}; spikes.waveforms];
            std_ums{iFile}{iElecGroup} = [std_ums{iFile}{iElecGroup};  spikes.info.detect.thresh];
            
            prePointsSpike = args.PrePointsSpike;
            postPointsSpike = args.PostPointsSpike;
            
            if isempty(fullWaveforms{iElecGroup})
                fullWaveforms{iElecGroup}(:, :) = zeros(prePointsSpike + postPointsSpike +1, length(electrodesArray{1,1}));
            end
            
            for iSpike = 1:length(detectedSpikes)
                waveforms = single(normCompleteData(detectedSpikes(iSpike) - prePointsSpike : detectedSpikes(iSpike) + postPointsSpike, :));
%                 normWaveforms = bsxfun(@minus, waveforms, round(mean(waveforms)));
                
                fullWaveforms{iElecGroup}(:, :) = fullWaveforms{iElecGroup}(:, :) + waveforms;
                waveformCount(iElecGroup) = waveformCount(iElecGroup) + 1;
            end
        end
    end
    
    averagedFullWaveforms = fullWaveforms;
    waveformCount(waveformCount == 0) = 1;
    
    for i = 1:length(electrodeGroups)
        averagedFullWaveforms{i} = fullWaveforms{i}/waveformCount(i);
    end
    
    temporalAxonTraces{iFile} = averagedFullWaveforms;
end

axonTraces.map = [];
axonTraces.traces = [];

temporalTotalElectrodes = cell(nFiles,1);
temporalTotalX = cell(nFiles,1);
temporalTotalY = cell(nFiles,1);

for iFile = 1:nFiles
    temporalTotalElectrodes{iFile} = double(fileManagerObj.rawMap(iFile).map.electrode);
    temporalTotalX{iFile} = fileManagerObj.rawMap(iFile).map.x;
    temporalTotalY{iFile} = fileManagerObj.rawMap(iFile).map.y;
end

totalElectrodes = cell2mat(temporalTotalElectrodes);
totalX = cell2mat(temporalTotalX);
totalY = cell2mat(temporalTotalY);

[~, indicesFinalElec, ~] = unique(totalElectrodes);

electrode = totalElectrodes(indicesFinalElec);
x = totalX(indicesFinalElec);
y = totalY(indicesFinalElec);

axonTraces.map.electrode = electrode;
axonTraces.map.x = x;
axonTraces.map.y = y;

temporalTotalTraces = cell(length(temporalAxonTraces),1)';
traces = cell(length(temporalAxonTraces{1,1}),1);

for i = 1:length(temporalAxonTraces{1,1})
    for j = 1:length(temporalAxonTraces)
        temporalTotalTraces{1,j} = temporalAxonTraces{j,1}{i,1};
    end
    
    totalTraces = cell2mat(temporalTotalTraces);
    traces{i,1} = totalTraces(:,indicesFinalElec);
end

axonTraces.traces = traces;
ts = timestamps;
w = waveforms_ums;
s = std_ums;

end
