%%
clear all

[FileName,PathName,FilterIndex] = uigetfile('*.mat');

load([PathName FileName])
axonTraces.traces;

pp_thr = [10 10 8 6];

close all

figure('color','w','position',[20 50 1400 700]);

xmin = 0-50;
xmax = 2000;
ymin = 1200;
ymax = 2000+50;
 

for i= 1:4%length(axonTraces.traces)

    
map= axonTraces.map;
aa=max(axonTraces.traces{i})-min(axonTraces.traces{i});
% figure;
% hist(aa,50)

% sel = find(aa>prctile(aa,92))
sel = find(aa>pp_thr(i));

neur.traces=axonTraces.traces{i};

% second selection
tr_tmp =neur.traces(:,sel);
tr_tmp=resample(tr_tmp,4,1);
[va inn] = min(tr_tmp);
sel2 = [find(inn>prctile(inn,95)) find(inn<prctile(inn,5))];
sel(sel2)=[];


neur.traces=neur.traces(:,sel);
neur.traces=resample(neur.traces,4,1);




%

% figure;plot(neur.traces)




rec = recording;

map.electrode= map.electrode(sel);
map.x= map.x(sel);
map.y= map.y(sel);


rec.processedMap.electrode=map.electrode;
rec.processedMap.xpos= map.x;
rec.processedMap.ypos= map.y;

[va, inn] = min(neur.traces);
[va2, first_el] = min(va);

neur.x = map.x;
neur.y = map.y;
neur.lat = (inn-min(inn))/20/4;
neur.first_el = first_el;
neur.first_el_pos = [neur.x(first_el) neur.y(first_el)];
neur.dist_to_first_el = pdist2(neur.first_el_pos,[neur.x neur.y]);

% compute distaces to first el
% velocity plot
x2 = neur.lat';
y2 = neur.dist_to_first_el';


% 3rd selection: 
if i == 3
   slope = (360 - 210) ./ (0.8 - 0.3125);
   sel3 = [];
   for j= 1:length(x2)
       if x2(j)>0.3125
            dx=x2(j)-0.3125;
            
            if y2(j)<(dx*slope+210)
                sel3(end+1)=j;
            end
            
       end
   end
    
    map.electrode(sel3)=[];
map.x(sel3)=[];
map.y(sel3)=[];
rec.processedMap.electrode=map.electrode;
rec.processedMap.xpos= map.x;
rec.processedMap.ypos= map.y;
neur.lat(sel3)=[];
neur.dist_to_first_el(sel3)=[];
end
% 3rd selection: 
if i == 4
   slope = (250 - 35) ./ (0.15 - 0);
   sel3 = [];
   for j= 1:length(x2)
%        if x2(j)>0.3125
            dx=x2(j)-0;
            
            if y2(j)>(dx*slope+35)
                sel3(end+1)=j;
            end
            
%        end
   end
       for j= 1:length(x2)
        if x2(j)>0.35 && y2(j)<180
                sel3(end+1)=j;
            
        end
   end
    map.electrode(sel3)=[];
map.x(sel3)=[];
map.y(sel3)=[];
rec.processedMap.electrode=map.electrode;
rec.processedMap.xpos= map.x;
rec.processedMap.ypos= map.y;
neur.lat(sel3)=[];
neur.dist_to_first_el(sel3)=[];
end


% figure

subplot(3,4,1+(i-1));
mxw.plot.axonTraces(axonTraces.map.x, axonTraces.map.y, axonTraces.traces{i}, 'PlotFullArea', false, 'PointSize', 150, 'PlotHeatMap', true, 'PlotWaveforms', false,'Figure', false,'Title','Amplitude','Ylabel', '\muV');
xlabel('\mum');ylabel('\mum');axis equal;
xlim([xmin xmax])
ylim([ymin ymax])
box on
% colorbar off
        
subplot(3,4,5+(i-1));

value=neur.lat;
axisMin = min(value);
axisMax = max(value);

mxw.plot.activityMap(rec, value,'PlotFullArea',false, 'Ylabel', '[ms]', 'Figure',false,'Interpolate',false,'PointSize',20,'CaxisLim', [axisMin axisMax]);
xlabel('\mum');ylabel('\mum');axis equal;
axis on
hold on
box on
title('Latency')
xlim([xmin xmax])
ylim([ymin ymax])
% colormap jet

% velocity plot
x = neur.lat';
y = neur.dist_to_first_el';

b1=x\y; % regression coefficioent (velocity)

yCalc1 = b1*x; % slope

Rsq1 = 1 - sum((y - yCalc1).^2)/sum((y - mean(y)).^2);

vel(i)=round(b1);
Rs(i)=Rsq1;

subplot(3,4,9+(i-1));

scatter(x,y,'o')
xlabel('Latency [ms]')
ylabel('Distance [\mum]')
hold on
plot(x,yCalc1,'r')
title({['Velocity = ' num2str(round(b1)) 'm/s'], ['R = ' num2str(Rsq1)]})
box on
end

%% summary

figure('color','w','position',[200 50 800 400]);

subplot(1,2,1)
bar(vel)
title('Axonal Velocity')
ylabel('[m/s]')
xlabel('Neuron No.')

subplot(1,2,2)
bar(Rs)

title('Coefficient of Determination (R^{2})')
xlabel('Neuron No.')
ylim([0 1])






