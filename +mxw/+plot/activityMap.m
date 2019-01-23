function activityMap( fileManagerObj, value, varargin )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

axisMin = prctile(value, 10);
axisMax = prctile(value, 95);

p = inputParser;

p.addRequired('obj', @(x) isobject(x));
p.addRequired('value', @(x) isvector(x));
p.addParameter('Figure', true);
p.addParameter('ColorMap', parula);
p.addParameter('RevertColorMap', false);
p.addParameter('CaxisLim', [axisMin axisMax]);
p.addParameter('Interpolate', true);
p.addParameter('PlotFullArea', true);
p.addParameter('PointSize', 100);
p.addParameter('Ylabel', 'ylabel');
p.addParameter('Title', 'Activity Map');

p.parse(fileManagerObj, value, varargin{:});
args = p.Results;

if args.Figure
    figure('color','w');
end

if args.Interpolate
    F = scatteredInterpolant(args.obj.processedMap.xpos, args.obj.processedMap.ypos, args.value, 'nearest');
    [x, y] = meshgrid(unique(args.obj.processedMap.xpos), unique(args.obj.processedMap.ypos));
    qz = F(x, y);
    
    imagesc([min(args.obj.processedMap.xpos), max(args.obj.processedMap.xpos)], [min(args.obj.processedMap.ypos), max(args.obj.processedMap.ypos)], qz)
    
else
    
    scatter(args.obj.processedMap.xpos, args.obj.processedMap.ypos, args.PointSize, args.value, 'filled', 's');
end

axis ij;
axis equal;

colormap(args.ColorMap);
c = colorbar;

if args.RevertColorMap
    colormap(flipud(args.ColorMap));
end

if args.PlotFullArea
    xlim([165 4010]);
    ylim([155 2250]);
end

caxis(args.CaxisLim);
ylabel(c, args.Ylabel);
box off; 
title(args.Title, 'fontsize', 12);
end