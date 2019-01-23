function savePNG( varargin )
%  This function saves plots as png files.
%
%  Inputs:
%
%  "Directory": Path and name of image to be saved, e.g:
%  '/home/Desktop/test.png'
%
%  "Resolution": Sets resolution of image to be saved
%
%  Improvements to be done:
%  -Add a default "fileName"
%
%  Maxwell Biosystems. Last update: October 17th, 2017
%  Miguel Veloso. miguel.veloso@mxwbio.com

p = inputParser;

p.addParameter('Directory', '.');
p.addParameter('Resolution', 500);
p.addParameter('FileName', []);

p.parse(varargin{:});
args = p.Results;

mkdir(args.Directory);

if isempty(strfind(args.FileName, '.png'))
    ext = '.png';
end

fullPath = fullfile(args.Directory, [args.FileName, ext]);
set(gcf, 'PaperPositionMode', 'auto');
print('-dpng', ['-r' num2str(args.Resolution)], fullPath);
end
