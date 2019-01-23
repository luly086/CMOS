
%%
clear all
[FileName,PathName,FilterIndex] = uigetfile('*.mat');

load([PathName FileName])



%%


title = 'Axonal Movie Generator';
prompt = 'Enter neuron number:';
answer = inputdlg(prompt,title);

neuron_id = str2num(answer{1})

%%
%% make axon movie
map=recording.processedMap;

xlm=min(map.xpos);
xlma=max(map.xpos);
ylm=min(map.ypos);
ylma=max(map.ypos);

close all;

firstSample = 1;
lastSample = 71;
str = date;
%adjust minimum and maximum values of the colorbar (in uV)
mini = 20;
maxi = 20;

for p = neuron_id
    
    load('cmap_bluered.mat')
    
        xx = 0;
    dirName = [PathName, 'MovieNeuron', num2str(p)];
    
    mkdir(dirName)
    for j=firstSample:lastSample
        
        xx=xx+1;
        
        clims=[-mini,maxi];
        colormap(mycmap./256)
        plot_2D_map_clean(axonTraces.map.x, axonTraces.map.y, axonTraces.traces{p,1}(j,:), clims, 'nearest');
        xlabel('\mum');ylabel('\mum');axis equal;

        colorbar
        
%         set(gca,'XTickLabel', '')
%         set(gca,'YTickLabel', '')
        hold all
        
        
        xline = [max(axonTraces.map.x)-200,max(axonTraces.map.x)-100]; % 0.2 mm scale bar
        yline = [max(axonTraces.map.y)-10,max(axonTraces.map.y)-10];
        
        pl = line (xline,yline,'Color','w','LineWidth',5); % show scale bar
        txt = sprintf('%3.3f ms', (round((j-firstSample)/0.020)/1000));
%         txt = sprintf('%d ms', round((j-firstSample)/20));
        text(xlm+100,ylm+100,txt,'Color','w','FontSize',14); %show time
        hold off
        xlim([xlm xlma])
        ylim([ylm ylma])
        
        pictureName = [sprintf('%03d',xx)];
        
        savepng( 'Directory', dirName , 'FileName' , pictureName );
        
        
    end
    
    close(gcf)
end

%%

clear myVideo

myVideo = VideoWriter([dirName '/Neuron_' neuron_id '.avi'])
myVideo.FrameRate = 15;  % Default 30

open(myVideo);

for m= 1:71
   
    if m < 10
        mm1=strcat('00',int2str(m));
    elseif m < 100
        mm1=strcat('0',int2str(m));
%     else
%         mm1=strcat(m);
    end
    disp([mm1 '.png'])
    A = imread([dirName '/' mm1 '.png']);
    
    writeVideo(myVideo,A)
    
end

close(myVideo);

