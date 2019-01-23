%% load selected channels
clear; clc

%file_name = '~/Desktop/mxwbio/data/retina/Trace_20180619_03_47_05.raw.h5';
file_name = '/Users/linyinglu/Downloads/CMOS/Trace_20181109_10_49_49_longAxon4_potentialSynCoup.raw.h5';
fullScanFolder = mxw.fileManager(file_name);

%output_dir  = '~/Desktop/output';
output_dir = '/Users/linyinglu/Desktop/output';

% This is the path to the hdf52many conversion tool
conversionTool = '~/MaxLab/bin/hdf52many';

mkdir(output_dir)
cd (output_dir)

%% Thresholds for selecting electrodes

thr_spike_rate = 10; % in Hz
thr_amp = 40; % in uV
radius = 100; % in um

%% Compute spikes features

spikeRate = mxw.activityMap.computeSpikeRate(fullScanFolder);
amplitude90perc = abs(mxw.activityMap.computeAmplitude90percentile(fullScanFolder));

% indices to select electrodes with spikes
idx = (spikeRate>thr_spike_rate & amplitude90perc>thr_amp);

%% Extract the mapping from the recording file
mapping = h5read(file_name, '/mapping');

mapping.channel = mapping.channel(idx);
mapping.electrode = mapping.electrode(idx);
mapping.x = mapping.x(idx);
mapping.y = mapping.y(idx);

% Compute the electrode groups
[electrode_groups, channel_groups] = circus.electrodeGroups( mapping, radius );


%% Visualize  electrode groups

figure('color','w');subplot(211);hold on
for group = 1:length(electrode_groups)
    scatter( mapping.x(ismember( mapping.electrode, electrode_groups{group})) , mapping.y(ismember( mapping.electrode, electrode_groups{group})) , 'filled' )
end
hold off;
axis ij;
xlim([-100 4000]);ylim([-100 2000])
xlabel('[\mum]');ylabel('[\mum]');

%% create data files for each electrode group

tic
circus.saveElectrodeGroupsToFile( channel_groups , [output_dir '/channel_groups.dat'] );
cmd = [conversionTool ' -i ' file_name ' -c ' output_dir '/channel_groups.dat' ];
system( cmd )
toc


%% load data from one electrode group

group_idx = 5;

% load data
lsb = h5read( file_name, '/settings/lsb')*10e5;
s = dir([ file_name '.',num2str(group_idx-1, '%03d') ,'.dat']);
the_size=s.bytes;
n_channels = length(channel_groups{group_idx});
n_samples = the_size / 2 / n_channels;
fid = fopen([ file_name '.',num2str(group_idx-1, '%03d') ,'.dat']);
X = fread(fid, [n_channels n_samples] , 'uint16' );
X = X' / 60 * lsb; % this data needs to be divided by 60. Spyking Circus needs the 60x larger values.
fclose(fid);

% filter data
lowCut = 300;
highCut = 3000;
order = 4;
bandPassFilter = mxw.util.bandpass(lowCut, highCut, order);

Y = bandPassFilter.filter(X);

% plot data
subplot(212);hold on
for i = 1:size(Y,2)
    plot(Y(:,i)+(i-1)*400);
end
xlabel('frames');ylabel('\muV')

%find x and y coordinates for the selelcted electrode group
idx_els = ismember(mapping.electrode, electrode_groups{group_idx});
x = mapping.x(idx_els);
y = mapping.y(idx_els);

