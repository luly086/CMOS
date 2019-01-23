%% Visualize Traces

p = uigetdir;
d = mxw.fileManager(p);
bestElectrodes = 4;

% initial point of data extraction
load_position_frame = 1; 
% time of the data you want to extract
data_chunk_size_in_seconds = 5;

Fs = d.fileObj.samplingFreq; % this is the sampling frequency of the MEA
[data, filesArray, electrodesArray] = d.extractBPFData(load_position_frame, data_chunk_size_in_seconds*Fs);
% x y cooridnates
x = d.processedMap.xpos; 
y = d.processedMap.ypos;

std_data = std(data);

arrayBestElectrodes = [];
minValues = min(data);
std_data = std(data);

c = 0;
while c<bestElectrodes+1
    
    [M,I] = min(minValues);
    minValues(I) = NaN;
    if std_data(I)<median(std_data)
    arrayBestElectrodes(end+1) = I;    
    c = c+1;
    end
end
arrayBestElectrodes(end) = [];

% Plotting best electrodes
figure('color','w','position',[50 50 1000 700]);

for i = 1:bestElectrodes
    ax(i) = subplot(bestElectrodes-1,2,i);
    plot(data(:,arrayBestElectrodes(i)));
    ylabel('\muV');
    xlabel('Time [s]');
    set(gca,'tickdir','out','xtick',[0:2:data_chunk_size_in_seconds]*20000,'xticklabel',[0:2:data_chunk_size_in_seconds]);
    legend(['Electrode = ',num2str(d.rawMap.map.electrode(arrayBestElectrodes(i)))],'location','southeast')
    box off
    ylim([round(min(data(:,arrayBestElectrodes(i)))*3) 80])
end
linkaxes(ax, 'x')

subplot(bestElectrodes-1,2,((bestElectrodes-1)*2)-1);
plot(d.rawMap.map.x,d.rawMap.map.y,'yo');
hold on;
plot(d.rawMap.map.x(arrayBestElectrodes),d.rawMap.map.y(arrayBestElectrodes),'r.','markersize',15);
hold on;xlabel('\mum');ylabel('\mum');axis equal;axis ij;
xlim([min(d.rawMap.map.x)-20 max(d.rawMap.map.x)+20]);
ylim([[min(d.rawMap.map.y)-20 max(d.rawMap.map.y)+20]]);
for i = 1:bestElectrodes
     text(d.rawMap.map.x(arrayBestElectrodes(i))+2, ...
	d.rawMap.map.y(arrayBestElectrodes(i))+2, num2str(d.rawMap.map.electrode(arrayBestElectrodes(i))) );
end
xlim([-200 4100]);ylim([-100 2200])

subplot(bestElectrodes-1,2,((bestElectrodes-1)*2));
h = histogram(std(data));box off;
h.FaceColor = 'k'; h.EdgeColor = 'k'; h.FaceAlpha = 1;
xlabel('Electrode SD [\muV]');
ylabel('Counts')
legend(['Mean SD= ',num2str(mean(std(data)),'%.2f'),' \muV'])

clearvars -except x y data datainfo

