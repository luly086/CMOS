classdef dataCompatibilityInterface < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
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
    end
    
    methods
        
        function checkVersionCompatibility(this)
            
            if ~(ischar(this.version) || isnumeric(this.version) || iscell(this.version))
                errorMsg1 = sprintf('Data compatibility issue: Incorrect "version" format. This could lead to problems later on when running analysis'); 
                errorMsg2 = sprintf('Please make sure "version" is a string, number, or cell');
                error([errorMsg1, newline, errorMsg2]);
            end                           
        end
                
        function checkTimeCompatibility(this)
            if ~(ischar(this.startTime) || ischar(this.stopTime))
                errorMsg1 = sprintf('Data compatibility issue: Incorrect "startTime" or "stopTime" format. This could lead to problems later on when running analysis'); 
                errorMsg2 = sprintf('Please make sure the time is a string');
                error([errorMsg1, newline, errorMsg2]);
            end     
        end
        
        function checkSamplingFreqCompatibility(this)
            if ~(isnumeric(this.samplingFreq) && (this.samplingFreq > 0))
                errorMsg1 = sprintf('Data compatibility issue: Incorrect "samplingFreq" format. This could lead to problems later on when running analysis'); 
                errorMsg2 = sprintf('Please make sure the sampling frequency is a positive integer');
                error([errorMsg1, newline, errorMsg2]);
            end     
        end
        
        function checkLenSamplesCompatibility(this)
            if ~(isnumeric(this.dataLenSamples) && (this.dataLenSamples >= 0))
                errorMsg1 = sprintf('Data compatibility issue: Incorrect "dataLenSamples" format. This could lead to problems later on when running analysis'); 
                errorMsg2 = sprintf('Please make sure the data length in samples is a positive integer');
                error([errorMsg1, newline, errorMsg2]);
            end     
        end
        
        function checkPointerToDataCompatibility(this)
            if ~(ischar(this.pointerToData))
                errorMsg1 = sprintf('Data compatibility issue: Incorrect "pointerToData" format. This could lead to problems later on when running analysis'); 
                errorMsg2 = sprintf('Please make sure the pointer to data is a valid string');
                error([errorMsg1, newline, errorMsg2]);
            end     
        end
        
        function checkFirstFrameNumCompatibility(this)
            if ~(ischar(this.firstFrameNum) || isnumeric(this.firstFrameNum) || iscell(this.firstFrameNum))
                errorMsg1 = sprintf('Data compatibility issue: Incorrect "firstFrameNum" format. This could lead to problems later on when running analysis');
                errorMsg2 = sprintf('Please make sure the first frame number is valid');
                error([errorMsg1, newline, errorMsg2]);
            end
        end
        
        function checkMapCompatibility(this)
            if isstruct(this.map)
                if ~(isfield(this.map, 'channel') && isfield(this.map, 'electrode') && isfield(this.map, 'x') && isfield(this.map, 'y'))
                    errorMsg1 = sprintf('Data compatibility issue: Incorrect "map" format. This could lead to problems later on when running analysis');
                    errorMsg2 = sprintf('Please make sure "map" contains the following fields: "channel", "electrode", "x", and "y"');
                    error([errorMsg1, newline, errorMsg2]);
                end
                
                if any(this.map.channel <= 0)
                    error('Channel numbers should be larger than zero');
                end
                
                if any(this.map.electrode <= 0)
                    error('Electrode numbers should be larger than zero');
                end
                
                if any(this.map.x < 0)
                    error('x coordinates should be all positive');
                end
                
                if any(this.map.y < 0)
                    error('y coordinates should be all positive');
                end
                
            else
                errorMsg1 = sprintf('Data compatibility issue: Incorrect "map" format. This could lead to problems later on when running analysis');
                errorMsg2 = sprintf('Please make sure the map is a valid struct');
                error([errorMsg1, newline, errorMsg2]);
            end
        end
        
        function checkSpikesCompatibility(this)
            if isstruct(this.spikes)
                if ~(isfield(this.spikes, 'frameno') && isfield(this.spikes, 'channel') && isfield(this.spikes, 'amplitude'))
                    errorMsg1 = sprintf('Data compatibility issue: Incorrect "spikes" format. This could lead to problems later on when running analysis');
                    errorMsg2 = sprintf('Please make sure "spikes" contains the following fields: "frameno", "channel", and "amplitude"');
                    error([errorMsg1, newline, errorMsg2]);
                end
                
                if any(this.spikes.channel <= 0)
                    error('Channel numbers should be larger than zero');
                end
                
            else
                errorMsg1 = sprintf('Data compatibility issue: Incorrect "spikes" format. This could lead to problems later on when running analysis');
                errorMsg2 = sprintf('Please make sure the spikes is a valid struct');
                error([errorMsg1, newline, errorMsg2]);
            end
        end
        
        function checkLsbCompatibility(this)
            if ~(isnumeric(this.lsb) && (this.lsb > 0))
                errorMsg1 = sprintf('Data compatibility issue: Incorrect "lsb" format. This could lead to problems later on when running analysis'); 
                errorMsg2 = sprintf('Please make sure the lsb is a positive number');
                error([errorMsg1, newline, errorMsg2]);
            end     
        end

        function checkNChannelsCompatibility(this)
            if ~(isnumeric(this.nChannels) && (this.nChannels > 0))
                errorMsg1 = sprintf('Data compatibility issue: Incorrect "nChannels" format. This could lead to problems later on when running analysis'); 
                errorMsg2 = sprintf('Please make sure the number of channels is a positive number');
                error([errorMsg1, newline, errorMsg2]);
            end     
        end
    end
end

