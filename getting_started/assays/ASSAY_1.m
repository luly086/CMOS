% ASSAY 1 
% WHOLE SAMPLE ELECTRICAL ACTIVITY QUANTIFICATION

%% variables

% Path
folder_name = uigetdir;
fullScanFolder = mxw.fileManager(folder_name);

% Thresholds
thr_spike_rate = 0.05;
thr_amp = 15;

% Compute spikes features
spikeRate = mxw.activityMap.computeSpikeRate(fullScanFolder);
amplitude90perc = abs(mxw.activityMap.computeAmplitude90percentile(fullScanFolder));

%% Plot

% firing rate
figure('color',[1 1 1],'position',[100 100 1300 700]);
subplot(2,3,1);
mxw.plot.activityMap(fullScanFolder, spikeRate, 'Ylabel', 'Hz', 'CaxisLim', [0.2 max(spikeRate/5)],'Figure',false,'Title','Whole-Sample Mean Firing Rate','colormap','parula');
line([300 800],[2000+400 2000+400],'Color','k','LineWidth',5); axis off;
text(340,2100+500,'0.5 mm','color','k');xlim([200 3750]);ylim([150 2500])
% amplitude
subplot(2,3,2);
mxw.plot.activityMap(fullScanFolder, amplitude90perc,  'CaxisLim', [ 20 max(amplitude90perc)/4], 'Ylabel', 'Amplitude \muV','Figure',false,'Title','Whole-Sample Spike Amplitude','RevertColorMap', true ,'colormap','parula' );
line([300 800],[2000+400 2000+400],'Color','k','LineWidth',5); axis off;
text(340,2100+500,'0.5 mm','color','k');xlim([200 3750]);ylim([150 2500])

% active area
idx = (spikeRate>thr_spike_rate & amplitude90perc>thr_amp);
% active electrodes
subplot(2,3,3);
mxw.plot.activityMap(fullScanFolder, double(idx), 'Ylabel', '','Figure',false,'Title',['Active Electrodes = ',num2str((sum(idx)/length(idx))*100,'%.2f'),' %'],'colormap','parula');
line([300 800],[2000+400 2000+400],'Color','k','LineWidth',5); axis off; cbh=colorbar;set(cbh,'YTick',[0 1])
text(340,2100+500,'0.5 mm','color','k');xlim([200 3750]);ylim([150 2500])

%idx = (amplitude90perc>thr_amp);
% firing rate distribution
subplot(2,3,4);h = histogram(spikeRate(idx),0:.05:ceil(max(spikeRate)));
ylabel('Counts');xlabel('Mean Firing Rate [Hz]');box off;
h.FaceColor = 'b'; h.EdgeColor = 'b'; h.FaceAlpha = 1;
legend(['MFR = ',num2str(mean(spikeRate(idx)),'%.2f'),' Hz,  sd = ',num2str(std(spikeRate(idx)),'%.2f')])
xlim([0 prctile(spikeRate,99)])

idx = (spikeRate>thr_spike_rate);
% amplitude distribution
subplot(2,3,5);h = histogram(amplitude90perc(idx),ceil(0:1:max(amplitude90perc)));ylabel('counts');
ylabel('Counts');xlabel('Mean Spike Amplitude [\muV]');box off;
h.FaceColor = [0 0.8 0]; h.EdgeColor = [0 0.8 0]; h.FaceAlpha = 1;
legend(['MSA = ',num2str(mean(amplitude90perc(idx)),'%.2f'),' \muV,  sd = ',num2str(std(amplitude90perc(idx)),'%.2f')])

% Electrode Percentage with MFA and MSA
subplot(2,3,6); hold on
x = [0 0.5 1 10 100];
y = histcounts(spikeRate(spikeRate>thr_spike_rate),x);
y = y/sum(y)*100;
c = [0 0 1;0 0 0.7;0 0 0.5;0 0 0.3];
for i = 1:length(y)
bar(i,y(i), 'FaceColor',c(i,:));
end

x = [0 30 100 1000];
y = histcounts(abs(amplitude90perc),x);
y = y/sum(y)*100;
c = [0 1 0;0 0.7 0;0 0.5 0;0 0.3 0];
for i = 1:length(y)
bar(i+6,y(i), 'FaceColor',c(i,:));
end

set(gca,'XTick',[1:4 7:9],'XTicklabel',[{'0-0.5'},{'0.5-1'},{'1-10'},{'>10'},{'0-30'},{'30-100'},{'>100'}],'fontsize',7)


xlabel('MFR [Hz]                           MSA [\muV]','fontsize',10)
ylabel(['Electrodes Percentage'],'fontsize',10)

clear