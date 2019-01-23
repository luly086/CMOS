function waveforms(x, y, templates, varargin )

p = inputParser;

p.addRequired('x');
p.addRequired('y');
p.addRequired('templates');

XScale_ =  1 / (size(templates,1) );
YScale_ = -1 / (min(templates(:))) * 17.5 ;

%p.addParamValue('XScale',   6,  @(x)isnumeric(x) && x>0 && x<=1000);
%p.addParamValue('YScale',   6,  @(x)isnumeric(x) && x>0 && x<=1000);
p.addParameter('XScale',    1,  @(x)isnumeric(x) );
p.addParameter('YScale',    1,  @(x)isnumeric(x) );
p.addParameter('XRange',    [] );
p.addParameter('Color',     [0 0 0]);
p.addParameter('ColorMap',  []);
p.addParameter('LineWidth', 1);
p.addParameter('idx',       []);

axis ij

p.parse( x, y, templates, varargin{:});
args = p.Results;

if isempty(args.XRange)
    args.XRange = ( (-size(templates,1)/2):(size(templates,1)/2-1) ) * 16 * args.XScale * XScale_;
end

t = templates * -1 * args.YScale ;

if ~isempty(args.idx)
    x = x(args.idx);
    y = y(args.idx);
    t = templates(:,args.idx) * -1 * args.YScale ;
end


% the space between two electrodes is 17 um i.e. the max range
% for a template is 17....

if ~isempty( args.ColorMap )

    hold on;
    for i=1:length(x)
        line ( x(i) + args.XRange , y(i) + t(:,i) , ...
            'LineWidth' , args.LineWidth, ...
            'Color',      args.ColorMap(i,:) );
    end
    hold off;
    
else

    hold on;
    %%THIS FUNCTION IS PLOTTING THE NON-USED ELECTRODES IN THE LEFT-UPPER
    %%CORNER OF THE GRAPH AREA...TO SOLVE THIS ISSUE I'M RESTRICTING THE
    %%PLOTTING TO X AND Y COORDINATES THAT ARE LARGER THAN ZERO   
    for i=1:length(x)
        if( x(i) && y(i) > 0)
            line ( x(i) + args.XRange , y(i) + t(:,i) , ...
                'LineWidth' , args.LineWidth, ...
                'Color',      args.Color );
        end
    end
    hold off;

end
