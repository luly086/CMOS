classdef fileManager < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        referencePath;
        isFolder;
        nFiles;
        fileNameList;
        fileObj;
        rawMap;
        processedMap;
        extractedSpikes;
        bandPassFilter;
    end
    
    methods
        
        function this = fileManager(referencePath)
            
            if nargin > 0
                this.referencePath = referencePath;
                
                this.determineIfFolder();
                this.calculateNumFiles();
                this.createFileNameList();
                this.createFileObj();
                this.compileRawMaps();
                this.computeMap();
                this.compileSpikes();
                this.cleanNonRoutedElec();
                [lowCut, highCut, order] = this.defaultBPF();
                this.createBPFilter(lowCut, highCut, order);
            end
        end
        
        function determineIfFolder(this)
            
            if isdir(this.referencePath)
                this.isFolder = true;
                
            else
                this.isFolder = false;
            end
        end
        
        function calculateNumFiles(this)
            
            if this.isFolder
                info = dir(this.referencePath);
                info = info(3:end,:);
                this.nFiles = size(info,1);
                
            else
                this.nFiles = 1;
            end
        end
        
        function createFileNameList(this)
            
            if this.isFolder
                filesList = cell(this.nFiles,1);
                info = dir(this.referencePath);
                info = info(3:end,:);
                
                for iFile = 1:this.nFiles
                    filesList(iFile,:) = cellstr([this.referencePath, filesep, info(iFile).name]);
                end
                
                this.fileNameList = filesList;
                
            else
                this.fileNameList = cellstr(this.referencePath);
            end
        end
        
        function createFileObj(this)
            
            fileObjects(this.nFiles,1) = mxw.dataFunctions.fileInterface();
            
            for iFile = 1:this.nFiles
                fileObjects(iFile) = mxw.dataFunctions.fileInterface(char(this.fileNameList(iFile)));
            end
            
            this.fileObj = fileObjects;
        end
        
        function compileRawMaps(this)
            
            rawMaps(this.nFiles).map = [];
            rawMaps(this.nFiles).spikes = [];
            
            for iFile = 1:this.nFiles
                rawMaps(iFile).map = this.fileObj(iFile).map;
                rawMaps(iFile).spikes = this.fileObj(iFile).spikes;
            end
            
            this.rawMap = rawMaps;
        end
        
        function computeMap(this)
            
            mapSize = 26400; %%Add this as a parameter
            
            procMaps.xpos = NaN(mapSize, 1);
            procMaps.ypos = NaN(mapSize, 1);
            procMaps.electrode = NaN(mapSize, 1);
            procMaps.fileIndex = cell(mapSize, 1);
                                              
            for iFile = 1:this.nFiles
                for i = 1:length(this.rawMap(iFile).map.channel)
                    electrode = this.rawMap(iFile).map.electrode(i);
                    procMaps.electrode(electrode) = electrode;
                    procMaps.xpos(electrode) = this.rawMap(iFile).map.x(i);
                    procMaps.ypos(electrode) = this.rawMap(iFile).map.y(i);
                    procMaps.fileIndex{electrode} = [procMaps.fileIndex{electrode}, iFile];
                end
            end
            
            procMaps.nonRoutedElec = find(isnan(procMaps.electrode));
            this.processedMap = procMaps;
        end

        function compileSpikes(this)
            
            mapSize = 26400; %%Add this as a parameter

            spikes.frameno = cell(mapSize, 1);
            spikes.amplitude = cell(mapSize, 1);
            allSpikes(this.nFiles) = spikes;
            
            for iFile = 1:this.nFiles
                spikes.frameno = cell(mapSize, 1);
                spikes.amplitude = cell(mapSize, 1);
                
                for i = 1:length(this.rawMap(iFile).map.channel)
                    electrode = this.rawMap(iFile).map.electrode(i);
                    channel = this.rawMap(iFile).map.channel(i);
                    idx = find(this.rawMap(iFile).spikes.channel == channel);
                    
                    if ~isempty(idx)
                        spikes.frameno{electrode} = this.rawMap(iFile).spikes.frameno(idx)';
                        spikes.amplitude{electrode} = this.rawMap(iFile).spikes.amplitude(idx)';
                    end
                end
                
                allSpikes(iFile) = spikes;
            end
            
            this.extractedSpikes = allSpikes;
        end
        
        function cleanNonRoutedElec(this)
            
            this.processedMap.xpos(this.processedMap.nonRoutedElec) = [];
            this.processedMap.ypos(this.processedMap.nonRoutedElec) = [];
            this.processedMap.fileIndex(this.processedMap.nonRoutedElec) = [];
            this.processedMap.electrode(this.processedMap.nonRoutedElec) = [];
            
            for iFile = 1:this.nFiles
                this.extractedSpikes(iFile).frameno(this.processedMap.nonRoutedElec) = [];
                this.extractedSpikes(iFile).amplitude(this.processedMap.nonRoutedElec) = [];
            end
        end

        function [data, filesArray, electrodesArray] = extractRawData(this, start, len, varargin)
            
            p = inputParser;
            
            p.addParameter('electrodes', []);
            p.addParameter('files', 1:this.nFiles);
            p.parse(varargin{:});
            args = p.Results;
            
            if isempty(args.electrodes)
                if this.nFiles == 1
                    tempFilesArray = this.filesArrays(this.fileObj.map.electrode');
                    [electrodesArray, filesArray] = mxw.util.electrodes2Files(this.fileObj.map.electrode', tempFilesArray);
                    data = this.fileObj.extractFullRawData(start, len);
                    
                elseif (length(args.files) == 1)
                    tempFilesArray = this.filesArrays(this.fileObj(args.files).map.electrode');
                    [electrodesArray, filesArray] = mxw.util.electrodes2Files(this.fileObj(args.files).map.electrode', tempFilesArray);
                    index = mod(find(filesArray' == args.files), length(filesArray));
                    index(index == 0) = length(filesArray);
                    filesArray = filesArray(index');
                    electrodesArray = electrodesArray(index');
                    data = this.fileObj(filesArray).extractFullRawData(start, len);
                    
                else
                    error('only one complete file can be extracted at once');
                end
                
            else
                nonRouted = any(this.processedMap.nonRoutedElec == args.electrodes);
                
                if any(nonRouted)
                    error('electrode(s) %s is(are) not routed', num2str(args.electrodes(nonRouted)));
                end
                
                tempFilesArray = this.filesArrays(args.electrodes);
                [electrodesArray, filesArray] = util.electrodes2Files(args.electrodes, tempFilesArray);
                index = mod(find(filesArray' == args.files), length(filesArray));
                index(index == 0) = length(filesArray);
                filesArray = filesArray(index');
                electrodesArray = electrodesArray(index');
                data = zeros(len, sum(cellfun('length', electrodesArray)));
                dataIndexStart = 1;
                
                for iFile = 1:length(filesArray)
                    dataIndexEnd = length(electrodesArray{iFile});
                    data(:, dataIndexStart:dataIndexStart + dataIndexEnd - 1) = ...
                        this.fileObj(filesArray(iFile)).extractRawData(start, len, electrodesArray{iFile});
                    dataIndexStart = dataIndexStart + dataIndexEnd;
                end
            end
        end
        
        function [waveformCutOuts, electrodesArray] = extractCutOuts(this, spikesTimePoints, prePointsSpike, postPointsSpike, varargin)
            
            p = inputParser;
            
            p.addParameter('files', 1:this.nFiles);
            p.parse(varargin{:});
            args = p.Results;
            
            if this.nFiles == 1
                nChannels = length(this.fileObj.map.channel);
                
            elseif (length(args.files) == 1)
                nChannels = length(this.fileObj(args.files).map.channel);
                
            else
                error('choose one file to extract the cutouts');
            end
            dim1 = (prePointsSpike + postPointsSpike) * nChannels;
            waveformCutOuts = zeros(dim1, length(spikesTimePoints));
            
            for i = 1:length(spikesTimePoints)
                [waveforms, ~, electrodesArray] = this.extractBPFData(spikesTimePoints(i) - prePointsSpike, prePointsSpike + postPointsSpike, varargin{:});
                waveformCutOuts(:, i) = reshape(waveforms, dim1, 1);
            end
        end
        
        function [filesArray] = filesArrays(this, electrodes)
            
            index = mod(find(this.processedMap.electrode == electrodes), length(this.processedMap.electrode));
            index(index == 0) = length(this.processedMap.electrode);
            filesArray = this.processedMap.fileIndex(index)';
        end

        function [data, filesArray, electrodesArray] = extractBPFData(this, start, len, varargin)
            
            [data, filesArray, electrodesArray] = this.extractRawData(start, len, varargin{:});
            data = this.bandPassFilter.filter(data);
        end

        function createBPFilter(this, lowCut, highCut, order)
       
            this.bandPassFilter = mxw.util.bandpass(lowCut, highCut, order);
        end
        
    end
    
    methods (Access = private, Static)
        
        function [lowCut, highCut, order] = defaultBPF()
            
            lowCut = 300;
            highCut = 7000;
            order = 4;
        end
        
    end
end

