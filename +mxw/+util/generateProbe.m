function generateProbe( fname , fileManagerObj , group , radius )
% GENERATEPROBE    generates a .prb file, compatible with 'phy' and 'spyking-circus'
% 
%     generateprobe( fname , mapping , group , radius )
% 
%     fname   : name of the generated probe file
%     mapping : mapping structure, as read from an h5 file
%     group   : list of electrodes
%     radius  : parameter for spyking-circus, what to consider activity from the same cell
%
%     See also MXW.UTIL.ELECTRODEGROUPS

originalElectrode = fileManagerObj.rawMap.map.electrode;
originalChannel = fileManagerObj.rawMap.map.channel;
originalX = fileManagerObj.rawMap.map.x;
originalY = fileManagerObj.rawMap.map.y;

geometry = [];
channels = [];

x = [];
y = [];
chs = [];

for el_idx = 1:length(group)
    
    idx = find(originalElectrode == group(el_idx));

    x = [x, originalX(idx)];
    y = [y, originalY(idx)];
    chs = [chs, originalChannel(idx)];
end    

% Python expects 0-based channel indexes
chs = chs -1; 

for idx = 1:length(x)
    if x(idx) >= 0
        geometry = [geometry ; chs(idx) , x(idx) , y(idx) ];
        channels = [channels , chs(idx)];
    end
end

% def writeProbeFile(h5file, fname):
fid = fopen(fname,'w');
fprintf(fid, 'total_nb_channels = %d\n', length(channels) );
fprintf(fid, 'radius = %f\n', radius );

fprintf(fid, 'channel_groups = {\n 1: {\n    ''channels'': [');
for ch_idx = 1:length(channels)
    fprintf(fid, '%d,' , channels(ch_idx));
end
fprintf(fid, '],\n');
fprintf(fid, '''graph'' : [],\n');
fprintf(fid, '''geometry'': {\n');

for ch_idx = 1:size(geometry,1)
    fprintf(fid, '      %d: [%f,%f],\n' , geometry(ch_idx,1), geometry(ch_idx,2), geometry(ch_idx,3) );
end

fprintf(fid, '}  }  }\n');
fclose(fid)
end
