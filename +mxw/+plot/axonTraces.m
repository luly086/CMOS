function axonTraces(xpos, ypos, waveforms, varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if ~isrow(xpos)
    xpos = xpos';
end

if ~isrow(ypos)
    ypos = ypos';
end

if (size(waveforms, 2) ~= size(xpos, 2))
    waveforms = waveforms';
end

axisMin = prctile(min(waveforms), 1);
axisMax = prctile(min(waveforms), 99);

p = inputParser;

p.addParameter('Figure', true);
p.addParameter('PlotFullArea', true);

p.addParameter('PlotHeatMap', true);
p.addParameter('PointSize', 100);
p.addParameter('Interpolate', false);
p.addParameter('ColorMap', parula);
p.addParameter('RevertColorMap', false);
p.addParameter('CaxisLim', [axisMin axisMax]);

% p.addParameter('PlotContours', true);

p.addParameter('PlotWaveforms', false);
p.addParameter('NormalizeByLocalMax', false);
p.addParameter('WaveformSize', 16);
p.addParameter('WaveformColor', [0.5 0.5 0.5]);
p.addParameter('uVolts2uMetersScale', 10);
p.addParameter('Title', 'title');
p.addParameter('Ylabel', 'ylabel');

p.parse(varargin{:});
args = p.Results;

if args.Figure
    figure('color','w');
end

hold on;

if args.PlotHeatMap
    if args.Interpolate
        F = scatteredInterpolant(xpos', ypos', min(waveforms)', 'nearest');
        [x, y] = meshgrid(unique(xpos), unique(ypos));
        qz = F(x, y);
        
        imagesc([min(xpos), max(xpos)], [min(ypos), max(ypos)], qz)
        
    else
        
        scatter(xpos, ypos, args.PointSize, min(waveforms), 'filled', 's');
    end
    
    colormap(args.ColorMap);
    
    if args.RevertColorMap
        colormap(flipud(args.ColorMap));
    end
    
    c = colorbar;
    caxis(args.CaxisLim);
    ylabel(c, args.Ylabel);
end

% if args.PlotContours
%     contour(xpos, ypos, min(waveforms), [min(min(waveforms)) * 0.5, min(min(waveforms)) * 0.5], 'k', 'linewidth', 1);
% end

if args.PlotWaveforms
    normalizedWaveforms = waveforms ./ max(max(abs(waveforms)));
    
    if args.NormalizeByLocalMax
        normalizedWaveforms = waveforms ./ repmat(max(abs(waveforms)), size(waveforms, 1), 1);
    end
    
    step = args.WaveformSize / size(normalizedWaveforms, 1);
    left = (xpos - args.WaveformSize/2)';
    
    waveforms2Plot = (-normalizedWaveforms * args.uVolts2uMetersScale) + repmat(ypos, size(normalizedWaveforms,1), 1);
    
    tempStep = cumsum(repmat(step, size(normalizedWaveforms, 1) + 1, size(normalizedWaveforms, 2)), 1);
    left2Rigth = repmat(left', size(normalizedWaveforms, 1), 1) + tempStep(1:end-1, :);
    
    plot(left2Rigth, waveforms2Plot, 'color', args.WaveformColor, 'Linewidth', 1)
end

hold off;

axis ij;
axis equal;

if args.PlotFullArea
    xlim([165 4010]);
    ylim([155 2250]);
end

title(args.Title, 'fontsize', 12);
end

