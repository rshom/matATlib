classdef AcousticSource
% AcousticSource array for an AcousticEnvironment.

    properties
        freq(1,1) double;               % Output frequencies
        z(:,1) double;                  % Depth array in meters
        beams(:,1) double;              % Beam angles (deg
    end
    
    properties(Dependent)
        depthString(1,:) char;
    end
    
    methods(Access=public)
        function obj = AcousticSource(freq,z)
        % Construct AcousticSouce array.
            obj.freq = freq;
            obj.z = z;
        end
        
    end
    
    methods
        function value = get.depthString(obj)
        % Getter for depth string for env file
            value = sprintf('%d \t %0.6f \\ \t ! NSD SD(1:NSD) (m)',...
                            length(obj.z), obj.z);            
        end
    end    

end
