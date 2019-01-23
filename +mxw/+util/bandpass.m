classdef bandpass
    
    %  This class contains all the properties and methods for processing the
    %  files.
    %
    %  Improvements to be done:
    %  -Check hdf5 version
    %  -Check hdf5 writing
    %  -Change name from "spikeTimes" to "spikes" in recording software
    %
    %  Maxwell Biosystems. Last update: October 16th, 2017
    %  Miguel Veloso. miguel.veloso@mxwbio.com
    
    %% Properties

    properties
        fs;
        lowcut;
        highcut;
        order;
        nyq;
        low;
        high;
        a;
        b;
    end
    % End of properties
    
    %% Methods
    methods
        
        %% Constructor
        function f = bandpass(lowcut, highcut, order)
            % To build an object with this constructor, input the path
            % "lowcut" and "highcut" frequencies, and the "order" of the
            % filter.
            f.fs = 20000;  % Sampling frequency
            f.lowcut = lowcut;
            f.highcut = highcut;
            f.order = order;
            f.nyq = 0.5 * f.fs;
            f.low = lowcut   / f.nyq;
            f.high = highcut / f.nyq;
            
            [b, a] = butter(order, [f.low, f.high], 'bandpass');
            f.b = b;
            f.a = a;
        end
        
        %% Apply causal filter
        function Y = filterCausal(obj, X)
            % Returns the data "X" filtered by the filter object "obj".
            % This filtering introduce phase-shift, in order to avoid it
            % use the method "filter"
            
            Y = filter(obj.b, obj.a, X);
        end
        
        %% Apply filter twice to remove pahse-shift
        function Y = filter(obj, X)
            % Returns the data "X" filtered by the filter object "obj".
            % This filtering does not introduce phase-shift
            
            Y = filtfilt(obj.b, obj.a, X);
        end
    end
    
    % End of methods
end

