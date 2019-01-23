classdef fileInterface < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        filePath;
        extension;
        dataFormat;
        info;
        version;
        startTime;
        stopTime;
        samplingFreq;
        dataLenSamples;
        dataLenTime;
        firstFrameNum;
        lsb;
        nChannels;
        pointerToData;
        map;
        spikes;
        dynamicDataStorge;
    end
    
    methods
        
        function this = fileInterface(filePath)
            
            if nargin > 0
                this.filePath = filePath;
                
                this.extractExtension();
                this.defineDataFormat;
                
                this.extractVersion();
                this.extractTime();
                this.extractSamplingFreq();
                this.definePointerToData();
                this.extractLenSamples();
                this.extractFirstFrameNum();
                this.extractLsb();
                this.extractNChannels();
                this.extractMap();
                this.extractSpikes();
            end
        end
        
        function extractExtension(this)
            
            dotPosition = strfind(this.filePath, '.');
            this.extension = this.filePath(dotPosition(1):end);
        end
        
        function defineDataFormat(this)
            
            switch this.extension
                case '.raw.h5'
                    this.dataFormat = mxw.dataFunctions.HDF5();
                otherwise
                    error('This data format can not be handled')
            end
        end
        
        function extractVersion(this)
            
            defaultValue = false;
            
            try
                this.dataFormat.extractDataVersion(this);
            catch
                defaultValue = true;
            end
            
            if defaultValue
                this.dataFormat.version = 'no version extracted';
            else
                this.dataFormat.checkVersionCompatibility();
            end
            
            this.version = this.dataFormat.version;
        end
        
        function extractTime(this)
            
            defaultValue = false;
            
            try
                this.dataFormat.extractDataTime(this);
            catch
                defaultValue = true;
            end
            
            if defaultValue
                this.dataFormat.startTime = 'no time extracted';
                this.dataFormat.stopTime = 'no time extracted';
            else
                this.dataFormat.checkTimeCompatibility();
            end
            
            this.startTime = this.dataFormat.startTime;
            this.stopTime = this.dataFormat.stopTime;
        end
        
        function extractSamplingFreq(this)
            
            defaultValue = false;
            
            try
                this.dataFormat.extractDataSamplingFreq(this);
            catch
                defaultValue = true;
            end
            
            if defaultValue
                this.dataFormat.samplingFreq = 'no sampling frequency extracted';
            else
                this.dataFormat.checkSamplingFreqCompatibility();
            end
            
            this.samplingFreq = this.dataFormat.samplingFreq;
        end
        
        function extractLenSamples(this)
            
            defaultValue = false;
            
            try
                this.dataFormat.extractDataLenSamples(this);
            catch
                defaultValue = true;
            end
            
            if defaultValue
                this.dataFormat.dataLenSamples = 'no length extracted';
            else
                this.dataFormat.checkLenSamplesCompatibility();
            end
            
            this.dataLenSamples = this.dataFormat.dataLenSamples;
        end
        
        function definePointerToData(this)
            
            defaultValue = false;
            
            try
                this.dataFormat.defineDataPointerToData(this);
            catch
                defaultValue = true;
            end
            
            if defaultValue
                this.dataFormat.pointerToData = 'no pointer extracted';
            else
                this.dataFormat.checkPointerToDataCompatibility();
            end
            
            this.pointerToData = this.dataFormat.pointerToData;
        end
        
        function extractFirstFrameNum(this)
            
            defaultValue = false;
            
            try
                this.dataFormat.extractFirstFrameNum(this);
            catch
                defaultValue = true;
            end
            
            if defaultValue
                this.dataFormat.firstFrameNum = 'no first frame number extracted';
            else
                this.dataFormat.checkFirstFrameNumCompatibility();
            end
            
            this.firstFrameNum = this.dataFormat.firstFrameNum;
        end
        
        function extractMap(this)
            
            defaultValue = false;
            
            try
                this.dataFormat.extractDataMap(this);
            catch
                defaultValue = true;
            end
            
            if defaultValue
                this.dataFormat.map = 'no map extracted';
            else
                this.dataFormat.checkMapCompatibility();
            end
            
            this.map = this.dataFormat.map;
        end
        
        function extractSpikes(this)
            
            defaultValue = false;
            
            try
            this.dataFormat.extractDataSpikes(this);
            catch
                defaultValue = true;
            end
            
            if defaultValue
                this.dataFormat.spikes = 'no spikes extracted';
            else
                this.dataFormat.checkSpikesCompatibility();
            end
            
            this.spikes = this.dataFormat.spikes;
        end
        
        function data = extractFullRawData(this, start, len)
            
            data = this.dataFormat.extractDataFullRawData(this, start, len);
        end
        
        function data = extractRawData(this, start, len, electrodes)
            
            data = this.dataFormat.extractDataRawData(this, start, len, electrodes);
        end
        
        function extractLsb(this)
            
            defaultValue = false;
            
            try
                this.dataFormat.extractDataLsb(this);
            catch
                defaultValue = true;
            end
            
            if defaultValue
                this.dataFormat.lsb = 'no lsb extracted';
            else
                this.dataFormat.checkLsbCompatibility();
            end
            
            this.lsb = this.dataFormat.lsb;
        end
        
        function extractNChannels(this)
            
            defaultValue = false;
            
            try
                this.dataFormat.extractDataNChannels(this);
            catch
                defaultValue = true;
            end
            
            if defaultValue
                this.dataFormat.nChannels = 'no number of channels extracted';
            else
                this.dataFormat.checkNChannelsCompatibility();
            end
            
            this.nChannels = this.dataFormat.nChannels;
        end
    end
end

