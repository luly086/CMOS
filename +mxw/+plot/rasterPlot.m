function relativeSpikeTimes =rasterPlot( fileManagerORspikeTimes, varargin )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% example 
%this_data = mxw.fileManager('/Users/linyinglu/Downloads/CMOS/Trace_20181109_10_49_49_longAxon4_potentialSynCoup.raw.h5');
%relativeSpikeTimes = mxw.plot.rasterPlot(this_data, 'file', 6, 'Figure', false);

p = inputParser;

p.addRequired('struct', @(x) isobject(x) || isstruct(x));
p.addParameter('file', []);
p.addParameter('Figure', true);
p.addParameter('MarkerSize', 2);
p.addParameter('Axis', true);
p.addParameter('Title', 'Raster plot');
p.addParameter('Ylabel', 'Channels');
p.addParameter('Xlabel', 'Time [s]');

p.parse(fileManagerORspikeTimes, varargin{:});
args = p.Results;

if isa(fileManagerORspikeTimes, 'mxw.fileManager')
    relativeSpikeTimes = mxw.util.computeRelativeSpikeTimes(fileManagerORspikeTimes, 'file', args.file);

else
    relativeSpikeTimes = fileManagerORspikeTimes;
end

if args.Figure
    figure;
end

plot(relativeSpikeTimes.time, relativeSpikeTimes.channel, '.k', 'MarkerSize', args.MarkerSize)

if ~(args.Axis)
    axis off;
else

title(args.Title);
xlabel(args.Xlabel);
ylabel(args.Ylabel);
end