function [XCORR_Coef,XCORR_Coef_norm] = xcorr_net(TS,params)

XCORR_Coef = NaN(length(TS),length(TS));

% Run the all-to-all cross-correlation
for i = 1:length(TS)
    times1 = (TS{i})./params.fs;
    for j = 1:length(TS)
        if j ~= i
            times2 = (TS{j})./params.fs;
            time_window = [times1(1) times2(1); times1(end) times2(end)];
            [y,y_norm] = LIF_xcorr_v190718MS(times1,times2,params.bin_win,time_window,params.max_lag);
            XCORR_Coef(i,j) = nanmean(y(1:(length(y)-1)));
            XCORR_Coef_norm(i,j) = nanmean(y_norm(1:(length(y)-1)));
        end
    end
end

end