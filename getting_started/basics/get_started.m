%% folder example -> red trinagles, spikes only

% folder path with scan
%pathFolderFullScan = '~/Desktop/mxwbio/data/scan2/';
pathFolderFullScan = '/Users/linyinglu/Downloads/CMOS/Trace_20181109_10_49_49_longAxon4_potentialSynCoup.raw.h5';

% loads all recording info 
fullScanFolder = mxw.fileManager(pathFolderFullScan);

i = 1; % index of scan file of interest

% xy coordinates, electrodes and channels
x = fullScanFolder.fileObj(i).map.x;
y = fullScanFolder.fileObj(i).map.y;
electrodes_id = fullScanFolder.fileObj(i).map.electrode;
channels_id = fullScanFolder.fileObj(i).map.channel;
% plot xy
figure('color','w');
subplot(211);
plot(x,y,'.r');hold on
axis ij;axis equal;
xlabel('\mum');

% find x and y of a given time stamps
% e.g. channel id of the first time stamp
j = 1;
ch_id = fullScanFolder.fileObj(i).spikes.channel(j);
idx = find(fullScanFolder.fileObj(i).map.channel==ch_id);
x1 = fullScanFolder.fileObj(i).map.x(idx);
y1 = fullScanFolder.fileObj(i).map.y(idx);
plot(x1,y1,'ob');
xlim([0 4000]);ylim([0 2000]);
title('electrode configuration')

% sampling frequency
Fs = fullScanFolder.fileObj(i).samplingFreq;
% find time stamps detected during recording (red triangles)
ts = (double(fullScanFolder.fileObj(i).spikes.frameno)/Fs) - (double(fullScanFolder.fileObj(i).spikes.frameno(1))/Fs);
% channel list, where spike time stamps where detected
ch = fullScanFolder.fileObj(i).spikes.channel;
% raster plot
subplot(212);plot(ts, ch,'.k');box off; xlabel('time [s]');ylabel('channel')
title('raster plot')


%% single file example

%load single file, full data
%pathFolderFullScan ='~/Desktop/mxwbio/data/network/popconf_1581.raw.h5';
pathFolderFullScan = '/Users/linyinglu/Downloads/CMOS/Trace_20181109_10_49_49_longAxon4_potentialSynCoup.raw.h5';
% loads all recording info info of the recording
fullScanFolder = mxw.fileManager(pathFolderFullScan);

% sampling frequency
Fs = fullScanFolder.fileObj.samplingFreq;
% find time stamps detected during recording (red triangles)
ts = double(fullScanFolder.fileObj.spikes.frameno - fullScanFolder.fileObj.firstFrameNum)/Fs;
% channel list, where spike time stamps where detected
ch = fullScanFolder.fileObj.spikes.channel;
%plot raster
figure('color','w');subplot(311);plot(ts, ch,'.k');box off; xlabel('time [s]');ylabel('channel')
title('raster plot')



% load data
load_position_frame = 1; % initial point of data extraction
data_chunk_size_in_seconds = 10; % time of the data you want to extract
[data, filesArray, electrodesArray] = fullScanFolder.extractBPFData(load_position_frame, data_chunk_size_in_seconds*Fs);

% find electrodes with biggest spike
[val, ind] = min(min(data));
subplot(312);plot( data(:,ind));
xlabel('frames');ylabel('\muV')
box off

% plot electrode std
subplot(313);histogram(std(data,[],1),0:.5:25)
xlabel('std [\muV]');ylabel('counts');box off