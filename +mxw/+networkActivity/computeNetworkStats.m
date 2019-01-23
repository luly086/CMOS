function [ values ] = computeNetworkStats( networkActivityVector, varargin )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

p = inputParser;

p.addRequired('struct', @(x) isstruct(x));
p.addParameter('Threshold', 1.35);

p.parse(networkActivityVector, varargin{:});
args = p.Results;

rmsFiringRate = rms(networkActivityVector.firingRate);
[maxAmplitudesValues, maxAmplitudesTimes] = findpeaks(networkActivityVector.firingRate,...
    networkActivityVector.time, 'MinPeakHeight', args.Threshold * rmsFiringRate);

values.maxAmplitudesValues = maxAmplitudesValues;

maxAmplitudeTimeDiff = diff(maxAmplitudesTimes);
values.maxAmplitudeTimeDiff = maxAmplitudeTimeDiff;
values.maxAmplitudesTimes = maxAmplitudesTimes;
values.maxAmplitudesValues = maxAmplitudesValues;


end