function networkStats( networkStatsStruct, varargin )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

p = inputParser;

p.addRequired('struct', @(x) isstruct(x));
p.addParameter('Option', []);
p.addParameter('Figure', true);
p.addParameter('Bins', 30);
p.addParameter('Color', 30);
p.addParameter('Axis', true);
p.addParameter('Xlimits', []);
p.addParameter('Ylimits', []);
p.addParameter('Title', 'Network Activity statistics');
p.addParameter('Ylabel', 'ylable');
p.addParameter('Xlabel', 'xlable');

p.parse(networkStatsStruct, varargin{:});
args = p.Results;

if isempty(args.Option)
    %errorMsg = sprintf(Please select a network statistics option to plot:\n *'maxAmplitude' \n *'maxAmplitudeTimeDiff'); 
    errorMsg = 'error';
    error(errorMsg);
    
elseif strcmp(args.Option, 'maxAmplitude')
    currentValue = networkStatsStruct.maxAmplitudesValues;
    
elseif strcmp(args.Option, 'maxAmplitudeTimeDiff')
    currentValue = networkStatsStruct.maxAmplitudeTimeDiff;

else
    %errorMsg = sprintf(Please select a network statistics option to plot:\n *'maxAmplitude' \n *'maxAmplitudeTimeDiff'); 
    errorMsg = 'error';
    error(errorMsg);
end

if args.Figure
    figure;
end

h = histogram(currentValue, args.Bins);
h.FaceColor = args.Color; h.EdgeColor = args.Color; h.FaceAlpha = 1;

if ~(args.Axis)
    axis off;
end

if ~isempty(args.Xlimits)
    xlim(args.Xlimits)
end

if ~isempty(args.Ylimits)
    ylim(args.Ylimits)
end

title(args.Title);
xlabel(args.Xlabel);
ylabel(args.Ylabel);
end