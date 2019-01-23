classdef HDF5 < mxw.dataFunctions.dataCompatibilityInterface
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        
        function gobj = HDF5()
        end
        
        function extractDataVersion(this, fileObj)
            
            try
                this.version = h5read(fileObj.filePath, '/version');
            catch
                this.version = cellstr('no version information');
            end
        end
        
        function extractDataTime(this, fileObj)
            
            timeStr = h5read(fileObj.filePath, '/time');
            timeStrTemp = strrep(timeStr{1}, '\n', '');
            timeStrTemp = strsplit(timeStrTemp, ';\n');           
            this.startTime = strrep(timeStrTemp{1}, 'start: ', '');
            this.stopTime = strrep(timeStrTemp{2}, 'stop: ', '');
        end
        
        function extractDataSamplingFreq(this, fileObj)
            
%             disp('Data sampling frequency to be defined');
            this.samplingFreq = 20000;
        end
        
        function extractDataLenSamples(this, fileObj)
            
            dataInfo = h5info(fileObj.filePath, fileObj.pointerToData);
            this.dataLenSamples = dataInfo.Dataspace.Size(1);
        end
        
        function defineDataPointerToData(this, fileObj)
            
            this.pointerToData = '/sig';
        end
        
        function extractFirstFrameNum(this, fileObj)
        
            rawFrameNum = h5read(fileObj.filePath, fileObj.pointerToData, [1 1027], [1, 2]);
            this.firstFrameNum = bitor(bitshift(double(rawFrameNum(:,2)), 16), double(rawFrameNum(:,1)));
        end
            
        function extractDataLsb(this, fileObj)
            
%             disp('lsb to be defined');
            this.lsb = 6.2;
        end
        
        function extractDataNChannels(this, fileObj)
            
%             disp('Number of channels to be defined');
            this.nChannels = 1024;
        end
        
        function extractDataMap(this, fileObj)
            
            map = h5read(fileObj.filePath, '/mapping');
            map.channel = map.channel(map.electrode >= 0);
            map.channel = map.channel + int32(ones(size(map.channel)));
            map.x = map.x(map.electrode >= 0);
            map.y = map.y(map.electrode >= 0);
            map.electrode = map.electrode(map.electrode >= 0);
            map.electrode = map.electrode + int32(ones(size(map.electrode)));
            
            this.map = map;
        end
        
        function extractDataSpikes(this, fileObj)
            
            this.spikes = h5read(fileObj.filePath, '/proc0/spikeTimes');
            this.spikes.channel = this.spikes.channel + int32(ones(size(this.spikes.channel)));
            this.spikes.amplitude = this.spikes.amplitude * fileObj.lsb;
            
            spikesFromRoutedChannels = true(length(this.spikes.channel), 1);
            
            for i = 1:length(this.spikes.channel)
                if ~any(this.spikes.channel(i) == this.map.channel)
                    spikesFromRoutedChannels(i) = false;
                end
            end
            
            this.spikes.frameno = this.spikes.frameno(spikesFromRoutedChannels);
            this.spikes.channel = this.spikes.channel(spikesFromRoutedChannels);
            this.spikes.amplitude = this.spikes.amplitude(spikesFromRoutedChannels);
        end
        
        function data = extractDataFullRawData(this, fileObj, start, len)
            
            data = double(h5read(fileObj.filePath, fileObj.pointerToData, [start 1], [len, fileObj.nChannels])) * fileObj.lsb;
            data = data(:,fileObj.map.channel);
        end
        
        function data = extractDataRawData(this, fileObj, start, len, electrodes)
                       
            index = mod(find(fileObj.map.electrode == electrodes), length(fileObj.map.electrode));
            index(index == 0) = length(fileObj.map.electrode);
            channels = double(fileObj.map.channel(index));
                      
            if isscalar(channels)
                channelsData = double(h5read(fileObj.filePath, fileObj.pointerToData, [start channels], [len, 1])) * fileObj.lsb;
            
            elseif isvector(channels)
                channelsData = zeros(len, length(channels));
                
                for i = 1:length(channels)
                    channelsData(:,i) = double(h5read(fileObj.filePath, fileObj.pointerToData, [start channels(i)], [len, 1])) * fileObj.lsb;
                end
            end
            
            data = channelsData;
        end
    end
end
