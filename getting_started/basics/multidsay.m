%% PLOT DATA AT DIFFERENT DAYS

clc;clear;
main_path = '/net/bs-filesvr02/export/group/hierlemann/recordings/Mea1k/nleary/';

%% SCAN

exp_type = '28x6x6';
dates = {'170509','170512','170516','170519'};
MEAs_id = 1414; 

ylim_Hz = 0.1; %in Hz, for plotting

for chip_id = MEAs_id

    
    files = {};
    for i = 1:length(dates)
        files{i} = [dates{i},'/',num2str(chip_id),'/',exp_type];
    end

    
    figure('color','w','position',[0 0 1500 1500]);c = 0;
    for i = 1:length(files)
        
        p = [main_path,files{i}];
        
        if exist(p,'dir')==7
            cd(p)
            f = dir;
            if length(f)>2
                fullScanFolder = mxw.fileManager(p);
                spikeRate = mxw.activityMap.computeSpikeRate(fullScanFolder);
                %c = c+1;subplot(2,4,c)
                subplot(ceil(sqrt(length(dates))),ceil(sqrt(length(dates))),i)
                mxw.plot.activityMap(fullScanFolder, spikeRate, 'Ylabel', 'Spike Rate (Hz)', 'CaxisLim', [0 ylim_Hz],'Figure',false,'Title','Spike Frequency');
                xlabel('\mum');ylabel('\mum');xlim([-200 4100]);ylim([-100 2200])
                title([files{i}])
            end
        end
        
    end
    
end

%% NETWORK
    
main_path = '/net/bs-filesvr02/export/group/hierlemann/recordings/Mea1k/vsivaraj/';

exp_type = 'network';
dates = {'180904','180907','180911'};
MEAs_id = 1812;
ylim_Hz = 3000; %in Hz, for plotting

for chip_id = MEAs_id
    
    files = {};
    for i = 1:length(dates)
        files{i} = [dates{i},'/',num2str(chip_id),'/',exp_type];
    end
    
    
    figure('color','w','position',[0 0 1500 1500]);c = 0;
    for i = 1:length(files)
        
        p = [main_path,files{i}];
        
        if exist(p,'dir')==7
            cd(p);
            f = dir;
            if length(f)>2
                networkAnalysisFile = mxw.fileManager([p,'/',f(end).name]);
                networkAct = mxw.networkActivity.computeNetworkAct(networkAnalysisFile, 'BinSize', 0.02, 'file', 5,'GaussianSigma', 0.2);
                %c = c+1;subplot(2,4,c)
                subplot(ceil(sqrt(length(dates))),ceil(sqrt(length(dates))),i)
                mxw.plot.networkActivity(networkAct, 'Threshold', 1.1, 'Figure', false);box off;ylim([0 ylim_Hz])
                title([files{i}])
            end
        end
        
    end
    
    
    
     % els
    
    
    figure('color','w','position',[0 0 1500 1500]);c = 0;
    for i = 1:length(files)
        
        p = [main_path,files{i}];
        
        if exist(p,'dir')==7
            cd(p);
            f = dir;
            if length(f)>2
                networkAnalysisFile = mxw.fileManager([p,'/',f(end).name]);
                subplot(ceil(sqrt(length(dates))),ceil(sqrt(length(dates))),i)
                plot(networkAnalysisFile.rawMap.map.x,networkAnalysisFile.rawMap.map.y,'.k');axis ij;axis equal
                title([files{i}]);xlim([0 4000]);ylim([0 2000])
                xlabel('\mum');ylabel('\mum');
            end
        end
        
    end
    
    
    
    
    
    
end

