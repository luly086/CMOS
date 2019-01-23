function [ os ] = detect()
%DETECT Summary of this function goes here
%   Detailed explanation goes here

if ismac
    % Code to run on Mac plaform
    os.delete = 'rm ';
    os.copy = 'cp ';
    
elseif isunix
    % On Linux plaform
    os.delete = 'rm ';
    os.copy = 'cp ';
    
elseif ispc
    % On Windows platform
    os.delete = 'del ';
    os.copy = 'copy ';
    
else
    disp('Platform not supported')
end

end

