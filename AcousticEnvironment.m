classdef AcousticEnvironment
% AcousticEnvironment class hasall info for Acoustic Toolbox runs
% 
% Environments consist of basic options, a surface layer, profiles for
% each media, a bottom layer, sources, and recievers. 
% 
% Russell Shomberg
% rshomberg@uri.edu

    properties
        % TODO validation
        % https://www.mathworks.com/help/matlab/matlab_oop/property-validator-functions.html

        % Options
        name(1,:) char = 'Acoustic Environment';% Name used for outputs
        freq(1,1) double = 50.0;        % Source frequency (Hz)
        range(1,1) double = 10e3;    % meters
        cLimit(1,2) double = [0.0 2000.0] % m/s
        
        % Acoustic surface definition
        surfaceBdry(1,1) AcousticBoundary = AcousticBoundary(0);

        % Layer definition of media. First layer is water column.
        media(:,1) AcousticLayer = AcousticLayer('canonical',6000);
        
        % Acoustic bottom definition
        bottomBdry(1,1) AcousticBoundary = AcousticBoundary(6000);

        % Sources
        sources(:,1) AcousticSource = AcousticSource(1000);
        
        % Recievers
        recievers(:,1) AcousticReciever = AcousticReciever(10e3,[1:6000]);
        
    end
    
    properties (Dependent)

    end
    
    methods(Access=public)

        function obj = AcousticEnvironment(name,freq,range,cLimit, ...
                                            surfaceBdry,media,bottomBdry, ...
                                            sources,recievers)
            % AcousticEnvironment builds the acoustic environment.
            
            obj.name = name;
            obj.freq = freq;
            obj.cLimit = cLimit;
            obj.surfaceBdry = surfaceBdry;
            obj.media = media;
            obj.bottomBdry = bottomBdry;
            obj.sources = sources;
            obj.recievers = reciervers;
            
        end
        
    end
    
end

