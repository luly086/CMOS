%% ASSAY 5

% CORRELATION ASSAY, STTC and XCORR

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STTC and XCORR on IPSC spike trains
% STTC function provided by Tim Sit / Cutts et al. (2015)
% XCORR function by Mark Humphries / Dayan, P & Abbott, L. F. (2001)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% variables

p = uigetdir;
d = mxw.fileManager(p);

thr_spikerate = 3;
thr_amplitude90perc = 100;
thr_amplitudestd = 1;
thr_isiV = 1;
lag = 0.01; % seconds
shuffle_time = 1000; % in frames

%% exec
spikeRate = mxw.activityMap.computeSpikeRate(d);
amplitude90perc = abs(mxw.activityMap.computeAmplitude90percentile(d));
amplitudestd = mxw.activityMap.computeAmplitudestd(d);
isiv = mxw.activityMap.computeISIv(d);

idx = spikeRate>thr_spikerate & amplitude90perc>thr_amplitude90perc & amplitudestd>thr_amplitudestd & isiv<0.5;
disp(sum(idx))

if 1
figure('color','w','position',[100 100 1300 800]);hold on
subplot(241);histogram(spikeRate,100);line([thr_spikerate thr_spikerate],[0 100],'Color','r');box off;xlabel(['spike rate [Hz]'])
subplot(242);histogram(amplitude90perc,100);line([thr_amplitude90perc thr_amplitude90perc],[0 100],'Color','r');box off;xlabel(['amplitude 90perc [\muV]'])
subplot(243);histogram(amplitudestd,100);line([thr_amplitudestd thr_amplitudestd],[0 100],'Color','r');box off;xlabel(['amplitude std [\muV]'])
subplot(244);histogram(isiv,100);line([thr_isiV thr_isiV],[0 100],'Color','r');box off;xlabel(['isi violations 0-2 ms [%]'])

subplot(2,4,[5 6]);
plot(d.fileObj.map.x,d.fileObj.map.y,'.k')
hold on;plot(d.fileObj.map.x(idx),d.fileObj.map.y(idx),'og')
hold on;xlabel('\mum');ylabel('\mum');axis equal;axis ij;

subplot(2,4,[7 8]);
ch = d.fileObj.map.channel(idx);
idx2 = ismember(d.fileObj.spikes.channel,ch);

Fs = d.fileObj.samplingFreq;
% find time stamps detected during recording (red triangles)
ts = double(d.fileObj.spikes.frameno - d.fileObj.firstFrameNum)/Fs;
% channel list, where spike time stamps where detected
ch = d.fileObj.spikes.channel;
%plot raster
plot(ts, ch,'.k');hold on;
plot(ts(idx2),ch(idx2),'+g')
box off; xlabel('time [s]');ylabel('channel')
title('raster plot')

end





x = d.fileObj.map.x(idx);
y = d.fileObj.map.y(idx);
ts = d.extractedSpikes.frameno(idx)';

TS = [];
TS_shuffled = [];
for i = 1:length(ts)
    TS{i} = single(ts{i} - (d.fileObj.firstFrameNum));
    TS_shuffled{i} = single((single(ts{i})+round(-shuffle_time+(shuffle_time+shuffle_time)*rand(1,length(ts{i})))) - (d.fileObj.firstFrameNum));
end
centers = [x y];
D = squareform(pdist(centers,'euclidean'));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate STTC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 1
tic
sttc_params.fs = 20000; % sampling rate
sttc_params.max_lag = lag; % in seconds, the delay time to look for conincidental spikes
sttc_params.duration = d.fileObj.dataLenSamples/20000; % recording duration
sttc_params.time = [1/20000,((sttc_params.duration*20000)/20000)];
STTC_Coef = sttc_net(TS,sttc_params);
STTC_Coef_shuffled = sttc_net(TS_shuffled,sttc_params);
toc
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate XCORR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 0
tic
% Some parameters
sttc_params.fs = 20000;
sttc_params.bin_win = 0.001; % binning 1ms
sttc_params.max_lag = lag;  % max lag to calculate the xcorr for 10 ms
[XCORR_Coef,STTC_Coef] = xcorr_net(TS,sttc_params);
[XCORR_Coef,STTC_Coef_shuffled] = xcorr_net(TS_shuffled,sttc_params);
toc
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure('Position',[100 100 1200 600],'color','w');

STTC_Coef = tril(STTC_Coef);
STTC_Coef_shuffled = tril(STTC_Coef_shuffled);

D = tril(D);

% Plot STTC
subplot(231); imagesc(STTC_Coef);
axis square
ylabel('neuron idx','Fontsize',12);
xlabel('neuron idx','Fontsize',12);
c = colorbar;ylabel(c, 'STTC');caxis([0 0.5])
title(['STTC (with ', num2str(sttc_params.max_lag*1000),' ms lag)'])


% Plot distance
subplot(232); imagesc(D);
axis square
ylabel('neuron idx','Fontsize',12);
xlabel('neuron idx','Fontsize',12);
c = colorbar;ylabel(c, '\mum');
title('Distance')


% Plot distance to sttc
dd = D(:);
ss = STTC_Coef(:);
idx = ss==0 | isnan(ss);
dd(idx) = [];
ss(idx) = [];

ss_shuff = STTC_Coef_shuffled(:);
idx = ss_shuff==0 | isnan(ss_shuff);

ss_shuff(idx) = [];


subplot(233); 
hold on; plot(dd,ss,'.','MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','white');
set(gca, 'Box', 'off','TickDir', 'out','TickLength', [.02 .02]);
axis square
ylabel('STTC','Fontsize',12);
xlabel('Distance [um]','Fontsize',12);
ylim([-0.1 1])

subplot(234); 
boxplot([ss ss_shuff])
box off
set(gca,'xtick',[1,2],'xticklabel',[{'Real'},{'Shuffled'}])
ylabel('STTC')

subplot(235)
input_matrix = tril(STTC_Coef);
idx = input_matrix>median(ss_shuff)*1.5;
mxw.networkActivity.plot_network_connectivity(idx,centers)
xlim([0 4000]);ylim([0 2200]);xlabel(['\mum']);ylabel(['\mum']);
xlabel('\mum');ylabel('\mum');

subplot(236)
connect_per_neuron = sum(idx,1)+sum(idx,2)';
connect_per_neuron(connect_per_neuron==0) = [];
h = histogram(connect_per_neuron,20);
h.FaceColor = 'k'; h.EdgeColor = 'k'; h.FaceAlpha = 1;
box off;ylabel('Counts');xlabel('Number of Connections per Neuron')
legend(['Mean Connections = ',num2str(mean(connect_per_neuron),'%.2f'), ' s sd = ',num2str(std(connect_per_neuron),'%.2f')])

%imagesc(idx)
axis square
ylabel('Counts','Fontsize',12);
xlabel('Number of Connections','Fontsize',12);


clear