function networkActivity( networkActivityStruct, varargin )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

p = inputParser;

p.addRequired('struct', @(x) isstruct(x));
p.addParameter('Figure', true);
p.addParameter('Threshold', []);
p.addParameter('Axis', true);
p.addParameter('Xlimits', []);
p.addParameter('Ylimits', []);
p.addParameter('Title', 'Network Activity');
p.addParameter('Ylabel', 'Spike Rate [Hz]');
p.addParameter('Xlabel', 'Time [s]');

p.parse(networkActivityStruct, varargin{:});
args = p.Results;

if args.Figure
    figure;
end

plot(networkActivityStruct.time, networkActivityStruct.firingRate)

if ~isempty(args.Threshold)
    hold
    rmsFiringRate = rms(networkActivityStruct.firingRate);
    plot(args.Threshold*rmsFiringRate*ones(ceil(networkActivityStruct.time(end)),1))
end

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