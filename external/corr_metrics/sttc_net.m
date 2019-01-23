function STTC_Coef = sttc_net(TS,params)

STTC_Coef = NaN(length(TS),length(TS));

for i = 1:length(TS)
        spike_times_1 = TS{i}/params.fs;
        N1v = length(spike_times_1);
        for j = 1:length(TS)
            if j ~= i
                spike_times_2 = TS{j}/params.fs;
                N2v = length(spike_times_2);
                STTC_Coef(i,j) = sttc(N1v, N2v, params.max_lag, params.time, spike_times_1, spike_times_2);
            end
        end
end
